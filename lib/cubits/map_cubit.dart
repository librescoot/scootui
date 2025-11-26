import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../map/mbtiles_provider.dart';
import '../repositories/mdb_repository.dart';
import '../repositories/tiles_repository.dart';
import '../routing/models.dart';
import '../state/enums.dart';
import '../state/gps.dart';
import '../state/settings.dart';
import '../utils/map_transform_animator.dart';
import 'mdb_cubits.dart';
import 'navigation_cubit.dart';
import 'navigation_state.dart';
import 'shutdown_cubit.dart';
import 'theme_cubit.dart';

part 'map_cubit.freezed.dart';
part 'map_state.dart';

final distanceCalculator = Distance();
const defaultCoordinates = LatLng(52.52437, 13.41053);

class MapCubit extends Cubit<MapState> {
  late final StreamSubscription<GpsData> _gpsSub;
  late final StreamSubscription<ThemeState> _themeSub;
  late final StreamSubscription<ShutdownState> _shutdownSub;
  late final StreamSubscription<NavigationState> _navigationStateSub;
  late final StreamSubscription<SettingsData> _settingsSub;
  final TilesRepository _tilesRepository;
  final EngineSync _engineSync;

  // Dynamic zoom constants based on navigation context
  static const double _zoomLongStraight = 15.0; // Long straight sections (~1000m look-ahead)
  static const double _zoomDefault = 16.0; // Default navigation zoom (~500m look-ahead)
  static const double _zoomMax = 17.5; // Maximum zoom for complex turns (~150m look-ahead)

  // Vehicle positioning - public so VehicleIndicator can use the same value
  static const Offset mapCenterOffset = Offset(0, 120); // Vehicle positioned toward bottom for better look-ahead (reduced for street name display)

  MapTransformAnimator? _transformAnimator;
  final bool _mapLocked = false;
  NavigationState? _currentNavigationState; // Store current navigation state for zoom logic
  SettingsData? _currentSettings; // Store current settings for map type and render mode
  ThemeState? _currentTheme; // Store current theme state

  // GPS interpolation state
  Ticker? _interpolationTicker;
  GpsData? _lastGpsData; // Last received GPS data for interpolation
  DateTime? _lastGpsTime; // When the last GPS update was received
  LatLng? _lastInterpolatedPosition; // Last interpolated position to detect actual changes

  static MapCubit create(BuildContext context) {
    final cubit = MapCubit(
      gpsStream: context.read<GpsSync>().stream,
      themeUpdates: context.read<ThemeCubit>().stream,
      shutdownStream: context.read<ShutdownCubit>().stream,
      navigationStateStream: context.read<NavigationCubit>().stream,
      settingsStream: context.read<SettingsSync>().stream,
      tilesRepository: context.read<TilesRepository>(),
      mdbRepository: RepositoryProvider.of<MDBRepository>(context),
      engineSync: context.read<EngineSync>(),
    );
    cubit._currentTheme = context.read<ThemeCubit>().state;
    cubit._onGpsData(context.read<GpsSync>().state);
    cubit._loadMap(context.read<ThemeCubit>().state, context.read<SettingsSync>().state);
    return cubit;
  }

  MapCubit({
    required Stream<GpsData> gpsStream,
    required Stream<ThemeState> themeUpdates,
    required Stream<ShutdownState> shutdownStream,
    required Stream<NavigationState> navigationStateStream,
    required Stream<SettingsData> settingsStream,
    required TilesRepository tilesRepository,
    required MDBRepository mdbRepository,
    required EngineSync engineSync,
  })  : _tilesRepository = tilesRepository,
        _engineSync = engineSync,
        super(MapLoading(controller: MapController(), position: defaultCoordinates)) {
    _gpsSub = gpsStream.listen(_onGpsData);
    _themeSub = themeUpdates.listen(_onThemeUpdate);
    _shutdownSub = shutdownStream.listen(_onShutdownStateChange);
    _navigationStateSub = navigationStateStream.listen(_onNavigationStateChanged);
    _settingsSub = settingsStream.listen(_onSettingsChanged);
  }

  @override
  Future<void> close() {
    final current = state;

    // Stop interpolation ticker
    _stopInterpolationTicker();

    // Stop any ongoing animations and dispose MapTransformAnimator
    try {
      _transformAnimator?.stopAnimations();
      _transformAnimator?.dispose();
      _transformAnimator = null;
    } catch (e) {
      print("MapCubit: Error disposing MapTransformAnimator: $e");
    }

    // Then dispose the base map controller
    try {
      current.controller.dispose();
    } catch (e) {
      print("MapCubit: Error disposing MapController: $e");
    }

    switch (current) {
      case MapOffline():
        final tiles = current.tiles;
        if (tiles is AsyncMbTilesProvider) {
          try {
            tiles.dispose();
          } catch (e) {
            print("MapCubit: Error disposing tiles provider: $e");
          }
        }
        break;
      default:
    }

    // Cancel all streams
    _themeSub.cancel();
    _gpsSub.cancel();
    _shutdownSub.cancel();
    _navigationStateSub.cancel();
    _settingsSub.cancel();

    return super.close();
  }

  /// Stops any ongoing map animations - called when map view is being disposed
  void stopAnimations() {
    try {
      _transformAnimator?.stopAnimations();
    } catch (e) {
      print("MapCubit: Error stopping animations: $e");
    }
  }

  /// Disposes the current animator - called when map view is being disposed
  void disposeAnimator() {
    _stopInterpolationTicker();
    try {
      _transformAnimator?.stopAnimations();
      _transformAnimator?.dispose();
      _transformAnimator = null;
    } catch (e) {
      print("MapCubit: Error disposing animator: $e");
    }
  }

  Future<void> _onShutdownStateChange(ShutdownState shutdownState) async {
    // This logic might need to move to NavigationCubit if it's purely about navigation state
    // For now, keeping it here if it affects map display during shutdown
    if (shutdownState.status == ShutdownStatus.shuttingDown) {
      // Potentially clear map-specific route display if NavigationCubit handles clearing the actual route
      print("MapCubit: Scooter shutting down. Consider map state adjustments.");
    }
  }

  void _onNavigationStateChanged(NavigationState navState) {
    // Update dynamic zoom based on navigation context
    // Store the current navigation state for zoom calculations
    _currentNavigationState = navState;

    // Trigger map update with new zoom if currently navigating
    // Use snapped position when available and on-route, otherwise use current position
    if (navState.isNavigating && state.position != defaultCoordinates) {
      final positionToUse = navState.snappedPosition ?? state.position;
      _moveAndRotate(positionToUse, state.orientation);
    }
  }

  void _onSettingsChanged(SettingsData settings) {
    final previous = _currentSettings;
    _currentSettings = settings;

    // Reload map if map type or render mode changed
    if (previous != null &&
        _currentTheme != null &&
        (previous.mapType != settings.mapType || previous.mapRenderMode != settings.mapRenderMode)) {
      // Dispose old animator before reloading to clean up active tickers
      _transformAnimator?.stopAnimations();
      _transformAnimator?.dispose();
      _transformAnimator = null;
      _loadMap(_currentTheme!, settings);
    }
  }

  void _moveAndRotate(LatLng center, double course, {Duration? duration}) {
    if (_mapLocked) {
      print("MapCubit: Map is locked, skipping _moveAndRotate.");
      return;
    }

    // Check if map is ready before trying to animate
    final currentState = state;
    final isReady = switch (currentState) {
      MapOffline(:final isReady) => isReady,
      MapOnline(:final isReady) => isReady,
      _ => false,
    };

    if (!isReady || _transformAnimator == null || isClosed) {
      // Map not ready yet, silently skip (this is normal during initialization)
      return;
    }

    final animator = _transformAnimator!;

    final navState = _currentNavigationState;
    final isOffRoute = navState?.isOffRoute ?? false;

    // Dynamic zoom based on navigation context
    double zoom = _calculateDynamicZoom();

    // When off-route, use north-up orientation and center the vehicle
    double rotation = isOffRoute ? 0.0 : -course;
    Offset offset = isOffRoute ? Offset.zero : mapCenterOffset;

    // Create target transformation and animate to it atomically
    final targetTransform = MapTransform(
      center: center,
      zoom: zoom,
      rotation: rotation,
      offset: offset,
    );

    // Use animator for smooth transitions with all parameters synchronized
    try {
      animator.animateTo(targetTransform);
    } catch (e) {
      // Widget disposed during animation, ignore the error
      print("MapCubit: Animation error (likely disposed): $e");
    }
  }

  double _calculateDynamicZoom() {
    final navState = _currentNavigationState;

    if (navState == null || !navState.isNavigating || navState.upcomingInstructions.isEmpty) {
      return _zoomDefault;
    }

    if (navState.isOffRoute) {
      return _zoomLongStraight;
    }

    final nextInstruction = navState.upcomingInstructions.first;
    final distanceToTurn = nextInstruction.distance; // in meters

    if (distanceToTurn <= 1) {
      return _zoomMax;
    }

    // Don't start zooming in until we're within 300m of the maneuver
    // This prevents premature zoom-in during long straights
    if (distanceToTurn > 300) {
      return _zoomDefault;
    }

    // Look ahead up to 2 more turns (max 3 total) within 150m from current position
    double targetDistance = distanceToTurn;
    int significantTurnsFound = 0;

    // Special handling for roundabouts: always include the exit in the zoom window
    final isApproachingRoundabout = nextInstruction is Roundabout;

    for (int i = 1; i < navState.upcomingInstructions.length && significantTurnsFound < 2; i++) {
      final instruction = navState.upcomingInstructions[i];

      // For roundabouts, extend the look-ahead to include the exit even if beyond 150m
      // For other maneuvers, stop at 150m
      if (!isApproachingRoundabout && instruction.distance > 150) break;

      // Check if this is a significant maneuver
      final isSignificantTurn = switch (instruction) {
        Turn(:final direction) => direction != TurnDirection.slightLeft && direction != TurnDirection.slightRight,
        Exit() => true,
        Roundabout() => true,
        Merge() => false, // Merges are like "keep" instructions
        Keep() => false,
        Other() => false,
      };

      if (isSignificantTurn) {
        // Zoom out to show this turn too
        targetDistance = instruction.distance;
        significantTurnsFound++;

        // If we're approaching a roundabout and found the next significant turn (the exit),
        // we can stop looking - we've included the full roundabout sequence
        if (isApproachingRoundabout && significantTurnsFound >= 1) {
          break;
        }
      }
    }

    const screenHeight = 480.0;
    const topStatusBarHeight = 30.0;
    const bottomBarHeight = 60.0;
    const vehicleVerticalOffset = 0.75;

    const visibleMapHeight = screenHeight - topStatusBarHeight - bottomBarHeight;

    // The point of interest (the turn) should be visible in the upper part of the map.
    // The vehicle is not in the center, it's offset downwards.
    // This means we have more "look-ahead" distance.
    final lookAheadHeight = visibleMapHeight * vehicleVerticalOffset;

    // We want to fit the targetDistance within this lookAheadHeight.
    final targetVisibleMeters = targetDistance;

    // This formula is a heuristic to convert meters to a zoom level.
    // It's derived from how map scales work (roughly doubles with each zoom level).
    // The constants are tuned to fit the visual layout.
    // C - log2(meters) -> zoom
    // The value 15.6 is a magic number that works well for this screen size and projection.
    double requiredZoom = 15.6 - math.log(targetVisibleMeters / lookAheadHeight) / math.ln2;

    // Clamp the zoom level to reasonable bounds
    return requiredZoom.clamp(_zoomLongStraight, _zoomMax);
  }

  void _onGpsData(GpsData data) {
    final current = state;

    // Store GPS data for interpolation
    _lastGpsData = data;
    _lastGpsTime = DateTime.now();

    // Map should rotate by the vehicle's actual course.
    final courseForMapRotation = data.course;

    // Marker should counter-rotate by the same amount to stay screen-upright.
    final orientationForMarker = data.course;

    final rawPosition = LatLng(data.latitude, data.longitude);

    // Use snapped position when navigating and on-route, otherwise use raw GPS position
    final navState = _currentNavigationState;
    final positionForDisplay = (navState?.isNavigating == true && navState?.snappedPosition != null)
        ? navState!.snappedPosition!
        : rawPosition;

    emit(current.copyWith(
      position: positionForDisplay,
      orientation: orientationForMarker,
    ));

    // Snap to real GPS position - this resets interpolation baseline
    _lastInterpolatedPosition = positionForDisplay;
    _moveAndRotate(positionForDisplay, courseForMapRotation);
  }

  void _onThemeUpdate(ThemeState event) {
    _currentTheme = event;
    final current = state;
    emit(MapState.loading(controller: state.controller, position: state.position));
    _getTheme(event.isDark).then((theme) => emit(switch (current) {
          MapOffline() => current.copyWith(theme: theme, themeMode: event.isDark ? 'dark' : 'light'),
          _ => current, // Should not happen if map is loaded
        }));
  }

  Future<void> _onMapReady(TickerProvider vsync) async {
    final current = state;
    _transformAnimator = MapTransformAnimator(
      mapController: current.controller,
      tickerProvider: vsync,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    // Start interpolation ticker using the same TickerProvider
    _startInterpolationTicker(vsync);

    emit(switch (current) {
      MapOffline() => current.copyWith(isReady: true),
      MapOnline() => current.copyWith(isReady: true),
      MapLoading(:final position, :final controller) => MapOffline(
          // Default to offline if was loading
          position: position,
          orientation: 0,
          controller: controller,
          tiles: AsyncMbTilesProvider(_tilesRepository), // Re-init or ensure it's available
          theme: await _getTheme(true), // Default theme
          themeMode: 'dark', // Default to dark
          renderMode: _currentSettings?.mapRenderMode == MapRenderMode.vector ? 'vector' : 'raster',
          onReady: _onMapReady,
          isReady: true,
        ),
      MapUnavailable() => current,
    });

    final mapIsReady = state is MapOffline || state is MapOnline;
    if (mapIsReady) {
      _moveAndRotate(state.position, state.orientation);
    }
  }

  Future<Theme> _getTheme(bool isDark) async {
    final mapTheme = isDark ? 'assets/mapdark.json' : 'assets/maplight.json';
    final themeStr = await rootBundle.loadString(mapTheme);
    return ThemeReader().read(jsonDecode(themeStr));
  }

  LatLng _getInitialCoordinates(MbTilesMetadata meta) {
    final bounds = meta.bounds;
    if (bounds != null &&
        (bounds.left > state.position.longitude ||
            bounds.right < state.position.longitude ||
            bounds.top < state.position.latitude ||
            bounds.bottom > state.position.latitude)) {
      return LatLng(
        (bounds.top + bounds.bottom) / 2,
        (bounds.right + bounds.left) / 2,
      );
    }
    return state.position;
  }

  Future<void> _loadMap(ThemeState themeState, SettingsData settings) async {
    // Dispose old animator before creating new map to clean up active tickers
    _transformAnimator?.stopAnimations();
    _transformAnimator?.dispose();
    _transformAnimator = null;
    _currentSettings = settings;
    emit(MapState.loading(controller: state.controller, position: state.position));
    final ctrl = MapController();

    // Check map type setting
    if (settings.mapType == MapType.online) {
      // Load online map
      emit(MapState.online(
        position: state.position,
        orientation: 0,
        controller: ctrl,
        onReady: _onMapReady,
      ));
    } else {
      // Load offline map
      final theme = await _getTheme(themeState.isDark);
      final provider = AsyncMbTilesProvider(_tilesRepository);
      final tilesInit = await provider.init();

      switch (tilesInit) {
        case InitSuccess(:final metadata):
          emit(MapState.offline(
            tiles: provider,
            position: _getInitialCoordinates(metadata),
            orientation: 0,
            controller: ctrl,
            theme: theme,
            themeMode: themeState.isDark ? 'dark' : 'light',
            renderMode: settings.mapRenderMode == MapRenderMode.vector ? 'vector' : 'raster',
            onReady: _onMapReady,
          ));
        case InitError(:final message):
          emit(MapState.unavailable(message, controller: ctrl, position: state.position));
      }
    }
  }

  // ============================================================================
  // GPS Position Interpolation (Dead Reckoning)
  // ============================================================================

  /// Starts the interpolation ticker for smooth map movement between GPS updates
  void _startInterpolationTicker(TickerProvider vsync) {
    _stopInterpolationTicker();
    _interpolationTicker = vsync.createTicker(_onInterpolationTick);
    _interpolationTicker!.start();
  }

  /// Stops the interpolation ticker
  void _stopInterpolationTicker() {
    _interpolationTicker?.stop();
    _interpolationTicker?.dispose();
    _interpolationTicker = null;
  }

  /// Called at ~60Hz by the ticker; we throttle internally to ~15Hz for position updates
  DateTime? _lastInterpolationTime;
  static const _interpolationInterval = Duration(milliseconds: 66); // ~15Hz

  void _onInterpolationTick(Duration elapsed) {
    final now = DateTime.now();

    // Throttle to ~15Hz
    if (_lastInterpolationTime != null &&
        now.difference(_lastInterpolationTime!) < _interpolationInterval) {
      return;
    }
    _lastInterpolationTime = now;

    // Perform dead reckoning interpolation
    final interpolatedPosition = _calculateInterpolatedPosition();
    if (interpolatedPosition != null) {
      _applyInterpolatedPosition(interpolatedPosition);
    }
  }

  /// Calculates the interpolated position using dead reckoning
  LatLng? _calculateInterpolatedPosition() {
    final gpsData = _lastGpsData;
    final gpsTime = _lastGpsTime;

    // Need GPS data to interpolate from
    if (gpsData == null || gpsTime == null) return null;

    // Only interpolate if GPS fix is recent (<10s old)
    if (!gpsData.hasRecentFix) return null;

    // Get ECU speed (km/h)
    final ecuSpeedKmh = _engineSync.state.speed.toDouble();

    // Only interpolate when ECU speed > 0 (vehicle is moving)
    if (ecuSpeedKmh <= 0) return null;

    // Calculate elapsed time since last GPS update
    final now = DateTime.now();
    final elapsedSeconds = now.difference(gpsTime).inMilliseconds / 1000.0;

    // Don't interpolate too far ahead (max 2 seconds)
    if (elapsedSeconds > 2.0) return null;

    // Convert speed from km/h to m/s
    final speedMs = ecuSpeedKmh / 3.6;

    // Calculate distance traveled since last GPS update
    final distanceM = speedMs * elapsedSeconds;

    // Get course in radians
    final courseRadians = gpsData.courseRadians;

    // Calculate position offset using dead reckoning
    // Note: GPS course is degrees from north, clockwise
    // cos(course) gives the northward component
    // sin(course) gives the eastward component
    final baseLat = gpsData.latitude;
    final baseLng = gpsData.longitude;

    // Meters per degree latitude is roughly constant at 111320m
    // Meters per degree longitude varies with latitude
    final dLat = distanceM * math.cos(courseRadians) / 111320.0;
    final dLng = distanceM * math.sin(courseRadians) / (111320.0 * math.cos(baseLat * math.pi / 180));

    return LatLng(baseLat + dLat, baseLng + dLng);
  }

  /// Applies the interpolated position to the map
  void _applyInterpolatedPosition(LatLng interpolatedPosition) {
    final current = state;

    // Check if map is ready
    final isReady = switch (current) {
      MapOffline(:final isReady) => isReady,
      MapOnline(:final isReady) => isReady,
      _ => false,
    };

    if (!isReady || _transformAnimator == null || isClosed) return;

    // Use snapped position when navigating, otherwise use interpolated
    final navState = _currentNavigationState;
    final positionForDisplay = (navState?.isNavigating == true && navState?.snappedPosition != null)
        ? navState!.snappedPosition!
        : interpolatedPosition;

    // Only update if position has actually changed significantly
    if (_lastInterpolatedPosition != null) {
      final distance = distanceCalculator.distance(
        _lastInterpolatedPosition!,
        positionForDisplay,
      );
      // Skip updates smaller than 0.5 meters to avoid micro-jitter
      if (distance < 0.5) return;
    }

    _lastInterpolatedPosition = positionForDisplay;

    // Update state with interpolated position
    emit(current.copyWith(position: positionForDisplay));

    // Animate map to interpolated position
    final course = _lastGpsData?.course ?? 0;
    _moveAndRotate(positionForDisplay, course);
  }
}
