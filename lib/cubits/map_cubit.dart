import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

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

  // ============================================================================
  // Dead Reckoning Configuration
  // ============================================================================

  static const double _drUpdateHz = 30.0; // Update rate for position interpolation
  static const Duration _drUpdateInterval = Duration(milliseconds: 33); // 1000ms / 30Hz ≈ 33ms
  static const double _drGpsLatencySeconds = 0.15; // Reduced latency compensation for slight undershoot
  static const double _drSpeedFactor = 0.95; // Slightly underpredict to avoid overshooting
  static const double _drCorrectionBlendRate = 2.0; // How fast to blend toward GPS (per second)
  static const double _drMaxErrorBeforeReset = 15.0; // If error exceeds this (meters), use fast correction
  static const double _drFastCorrectionBlendRate = 5.0; // Faster blend when resetting (per second)
  static const double _drSnapErrorThreshold = 50.0; // If error exceeds this (meters), snap with 1s animation
  static const double _drSnapAnimationSeconds = 1.0; // Duration for snap animation
  static const double _drImmediateResetThreshold = 500.0; // If error exceeds this (meters), immediately reset position
  static const double _drMinSpeedMs = 0.1; // Minimum speed to apply dead reckoning (m/s)

  // Dead reckoning runtime state
  Timer? _drTimer;
  GpsData? _lastGpsData;
  LatLng? _estimatedPosition; // Continuous position estimate (moves every frame)
  LatLng? _gpsCorrectionTarget; // GPS position projected forward for latency compensation
  DateTime? _lastFrameTime;
  int _lastRouteSegment = 0; // Track which route segment we're on to prevent jumping

  // Smoothed rotation and zoom (interpolated each frame)
  double _currentRotation = 0.0; // Current smoothed rotation
  double _targetRotation = 0.0; // Target rotation from GPS
  double _currentZoom = 16.0; // Current smoothed zoom
  double _targetZoom = 16.0; // Target zoom from navigation
  static const double _rotationMaxRate = 110.0; // Max degrees per second for large rotations
  static const double _rotationAnimationDuration = 1.0; // Seconds for rotations <= 110 degrees
  static const double _rotationHysteresis = 5.0; // Only change target rotation if difference > this (degrees)
  static const double _zoomSmoothingRate = 1.0; // Zoom levels per second
  static const double _zoomHysteresis = 0.3; // Only change target zoom if difference > this

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

    // Stop dead reckoning timer
    _stopDrTimer();

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
    _stopDrTimer();
    try {
      _transformAnimator?.stopAnimations();
      _transformAnimator?.dispose();
      _transformAnimator = null;
    } catch (e) {
      print("MapCubit: Error disposing animator: $e");
    }
  }

  Future<void> _onShutdownStateChange(ShutdownState shutdownState) async {
    if (shutdownState.status == ShutdownStatus.shuttingDown) {
      // Map state adjustments during shutdown handled by NavigationCubit
    }
  }

  void _onNavigationStateChanged(NavigationState navState) {
    // Reset route segment tracking if route changed
    final oldRoute = _currentNavigationState?.route;
    final newRoute = navState.route;
    if (oldRoute != newRoute) {
      _lastRouteSegment = 0;
    }

    // Store the current navigation state
    _currentNavigationState = navState;

    // Update target zoom with hysteresis - only change if significant difference
    final newTargetZoom = _calculateDynamicZoom();
    if ((newTargetZoom - _targetZoom).abs() > _zoomHysteresis) {
      _targetZoom = newTargetZoom;
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

  void _moveAndRotate(LatLng center, double course, {Duration? duration, Curve? curve}) {
    if (_mapLocked) return;

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
      animator.animateTo(targetTransform, animationDuration: duration, animationCurve: curve);
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
    final lastGps = _lastGpsData;
    final positionChanged = lastGps == null ||
        (data.latitude - lastGps.latitude).abs() > 0.000001 ||
        (data.longitude - lastGps.longitude).abs() > 0.000001;

    _lastGpsData = data;

    if (positionChanged) {
      // Calculate GPS correction target: project GPS forward to account for latency
      // GPS tells us where we WERE ~300ms ago, so project forward to where we ARE now
      final ecuSpeedKmh = _engineSync.state.speed.toDouble();
      final speedMs = ecuSpeedKmh / 3.6;
      final latencyDistance = speedMs * _drGpsLatencySeconds;

      final courseRadians = data.courseRadians;
      final dLat = latencyDistance * math.cos(courseRadians) / 111320.0;
      final dLng = latencyDistance * math.sin(courseRadians) / (111320.0 * math.cos(data.latitude * math.pi / 180));

      _gpsCorrectionTarget = LatLng(data.latitude + dLat, data.longitude + dLng);

      // Initialize estimated position if this is first GPS
      _estimatedPosition ??= _gpsCorrectionTarget;
    }

    // Update orientation in state (marker rotation)
    final current = state;
    emit(current.copyWith(orientation: data.course));
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
      curve: Curves.linear,
    );

    // Start dead reckoning timer for smooth position updates
    _startDrTimer();

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
  // Dead Reckoning - Smooth position interpolation between GPS updates
  // ============================================================================

  /// Result of projecting along a route - includes position and heading
  /// Projects a position forward along a route by the given distance (meters)
  /// Only searches forward from _lastRouteSegment to prevent jumping backwards
  /// Returns both the new position and the heading (course) along the route segment
  ({LatLng position, double heading}) _projectAlongRoute(LatLng currentPos, List<LatLng> waypoints, double distanceM) {
    if (waypoints.isEmpty) return (position: currentPos, heading: _lastGpsData?.course ?? 0);
    if (waypoints.length == 1) return (position: waypoints.first, heading: _lastGpsData?.course ?? 0);

    // Clamp last segment to valid range
    if (_lastRouteSegment >= waypoints.length - 1) {
      _lastRouteSegment = waypoints.length - 2;
    }

    // Search for nearest segment, but only forward from last known position
    // Allow looking back by 2 segments max (in case of GPS correction)
    final searchStart = (_lastRouteSegment - 2).clamp(0, waypoints.length - 2);
    final searchEnd = (waypoints.length - 1).clamp(0, waypoints.length - 1);

    int nearestSegment = _lastRouteSegment;
    double minDist = double.infinity;
    LatLng nearestPoint = waypoints[_lastRouteSegment];

    for (int i = searchStart; i < searchEnd; i++) {
      final segStart = waypoints[i];
      final segEnd = waypoints[i + 1];
      final projected = _projectPointOnSegment(currentPos, segStart, segEnd);
      final dist = distanceCalculator.distance(currentPos, projected);

      if (dist < minDist) {
        minDist = dist;
        nearestSegment = i;
        nearestPoint = projected;
      }
    }

    // Update last segment (only allow moving forward, or back by 1 for corrections)
    if (nearestSegment >= _lastRouteSegment || nearestSegment == _lastRouteSegment - 1) {
      _lastRouteSegment = nearestSegment;
    }

    // Now advance along the route from nearestPoint by distanceM
    double remaining = distanceM;
    LatLng pos = nearestPoint;
    int currentSegment = nearestSegment;

    for (int i = nearestSegment; i < waypoints.length - 1 && remaining > 0; i++) {
      final segEnd = waypoints[i + 1];
      final distToEnd = distanceCalculator.distance(pos, segEnd);
      currentSegment = i;

      if (distToEnd <= remaining) {
        // Move to end of this segment and continue
        remaining -= distToEnd;
        pos = segEnd;
        _lastRouteSegment = i + 1; // Update segment as we pass it
      } else {
        // Interpolate within this segment
        final fraction = remaining / distToEnd;
        pos = LatLng(
          pos.latitude + (segEnd.latitude - pos.latitude) * fraction,
          pos.longitude + (segEnd.longitude - pos.longitude) * fraction,
        );
        remaining = 0;
      }
    }

    // Calculate heading from current route segment direction
    double heading = _lastGpsData?.course ?? 0;
    if (currentSegment < waypoints.length - 1) {
      final segStart = waypoints[currentSegment];
      final segEnd = waypoints[currentSegment + 1];
      final dLat = segEnd.latitude - segStart.latitude;
      final dLng = segEnd.longitude - segStart.longitude;
      // atan2 gives angle from positive x-axis (east), we need from north
      // heading = 90 - atan2(dLat, dLng) in degrees, normalized to [0, 360)
      heading = (90 - math.atan2(dLat, dLng) * 180 / math.pi) % 360;
    }

    return (position: pos, heading: heading);
  }

  /// Projects a point onto a line segment, returning the closest point on the segment
  LatLng _projectPointOnSegment(LatLng point, LatLng segStart, LatLng segEnd) {
    final dx = segEnd.longitude - segStart.longitude;
    final dy = segEnd.latitude - segStart.latitude;

    if (dx == 0 && dy == 0) return segStart;

    final t = ((point.longitude - segStart.longitude) * dx +
            (point.latitude - segStart.latitude) * dy) /
        (dx * dx + dy * dy);

    final tClamped = t.clamp(0.0, 1.0);

    return LatLng(
      segStart.latitude + tClamped * dy,
      segStart.longitude + tClamped * dx,
    );
  }

  /// Starts the dead reckoning timer for smooth map movement
  void _startDrTimer() {
    _stopDrTimer();
    _drTimer = Timer.periodic(_drUpdateInterval, _onDrTick);
  }

  /// Stops the dead reckoning timer
  void _stopDrTimer() {
    _drTimer?.cancel();
    _drTimer = null;
  }

  /// Called at 30Hz by the timer for smooth position updates
  void _onDrTick(Timer timer) {
    final now = DateTime.now();

    // Calculate dt since last frame
    final dt = _lastFrameTime != null
        ? now.difference(_lastFrameTime!).inMicroseconds / 1000000.0
        : 1.0 / _drUpdateHz;
    _lastFrameTime = now;

    // Clamp dt to reasonable range (skip negative, cap at 150ms to prevent jumps)
    final clampedDt = dt.clamp(0.001, 0.15);
    if (dt <= 0) return;

    // Check preconditions
    final gpsData = _lastGpsData;
    if (gpsData == null || !gpsData.hasRecentFix || _estimatedPosition == null) {
      return;
    }

    // Step 1: Calculate what we want to show
    final prediction = _calculatePrediction(clampedDt, gpsData);

    // Step 2: Apply prediction with smoothing
    _applyPrediction(prediction, clampedDt);
  }

  // ============================================================================
  // Prediction Calculation - determines target position, heading, zoom
  // ============================================================================

  /// Calculates the prediction for this frame based on:
  /// - Dead reckoning from ECU speed
  /// - GPS correction blending
  /// - Route-based heading (when navigating)
  /// - Navigation-based zoom
  ({
    LatLng position,
    double heading,
    double zoom,
    bool isOffRoute,
    bool immediateReset,
  }) _calculatePrediction(double dt, GpsData gpsData) {
    final navState = _currentNavigationState;
    final route = navState?.route;
    final isOffRoute = navState?.isOffRoute ?? false;
    final isNavigating = navState?.isNavigating == true && route != null && route.waypoints.length >= 2;

    // Get current velocity from ECU
    final ecuSpeedKmh = _engineSync.state.speed.toDouble();
    final speedMs = ecuSpeedKmh / 3.6;

    // Start with current estimated position
    var estLat = _estimatedPosition!.latitude;
    var estLng = _estimatedPosition!.longitude;
    var heading = gpsData.course; // Default to GPS heading
    var immediateReset = false;

    // Dead reckon forward using ECU speed
    if (speedMs > _drMinSpeedMs) {
      final distance = speedMs * dt * _drSpeedFactor;

      if (isNavigating && !isOffRoute) {
        // Follow route - get position AND heading from route geometry
        final projection = _projectAlongRoute(LatLng(estLat, estLng), route.waypoints, distance);
        estLat = projection.position.latitude;
        estLng = projection.position.longitude;
        heading = projection.heading;
      } else {
        // Straight-line projection using GPS course
        final courseRadians = gpsData.courseRadians;
        final dLat = distance * math.cos(courseRadians) / 111320.0;
        final dLng = distance * math.sin(courseRadians) / (111320.0 * math.cos(estLat * math.pi / 180));
        estLat += dLat;
        estLng += dLng;
      }
    }

    // Blend toward GPS correction target
    if (_gpsCorrectionTarget != null) {
      final target = _gpsCorrectionTarget!;
      final currentPos = LatLng(estLat, estLng);
      final errorM = distanceCalculator.distance(currentPos, target);

      if (errorM > _drImmediateResetThreshold) {
        // Extremely large error: immediate reset, skip smoothing
        estLat = target.latitude;
        estLng = target.longitude;
        heading = gpsData.course;
        immediateReset = true;
        _lastRouteSegment = 0;
      } else {
        // Gradual correction with adaptive blend rate
        double blendRate;
        double maxBlend;

        if (errorM > _drSnapErrorThreshold) {
          blendRate = 1.0 / _drSnapAnimationSeconds;
          maxBlend = 1.0;
        } else if (errorM > _drMaxErrorBeforeReset) {
          blendRate = _drFastCorrectionBlendRate;
          maxBlend = 0.4;
        } else {
          blendRate = _drCorrectionBlendRate;
          maxBlend = 0.15;
        }

        final blend = (blendRate * dt).clamp(0.0, maxBlend);
        estLat += (target.latitude - estLat) * blend;
        estLng += (target.longitude - estLng) * blend;
      }
    }

    // Update internal estimated position
    _estimatedPosition = LatLng(estLat, estLng);

    // Calculate target zoom from navigation state
    final zoom = _calculateDynamicZoom();

    return (
      position: LatLng(estLat, estLng),
      heading: heading,
      zoom: zoom,
      isOffRoute: isOffRoute,
      immediateReset: immediateReset,
    );
  }

  // ============================================================================
  // Prediction Application - smoothly applies prediction to camera
  // ============================================================================

  /// Applies the prediction to the map camera with appropriate smoothing.
  /// Handles rotation/zoom interpolation and offset calculations.
  void _applyPrediction(
    ({
      LatLng position,
      double heading,
      double zoom,
      bool isOffRoute,
      bool immediateReset,
    }) prediction,
    double dt,
  ) {
    final current = state;

    // Check if map is ready
    final isReady = switch (current) {
      MapOffline(:final isReady) => isReady,
      MapOnline(:final isReady) => isReady,
      _ => false,
    };
    if (!isReady || isClosed) return;

    // Update state with position (for vehicle marker)
    emit(current.copyWith(position: prediction.position));

    final controller = current.controller;
    final camera = controller.camera;
    final offset = prediction.isOffRoute ? Offset.zero : mapCenterOffset;

    // === Rotation smoothing ===
    final targetRotation = prediction.isOffRoute ? 0.0 : -prediction.heading;

    if (prediction.immediateReset) {
      // Immediate reset: snap to target
      _currentRotation = targetRotation;
      _targetRotation = targetRotation;
    } else {
      // Apply hysteresis to target rotation
      double rotationDiff = targetRotation - _targetRotation;
      if (rotationDiff > 180) rotationDiff -= 360;
      if (rotationDiff < -180) rotationDiff += 360;
      if (rotationDiff.abs() > _rotationHysteresis) {
        _targetRotation = targetRotation;
      }

      // Smooth rotation with duration-based interpolation
      double rotationDelta = _targetRotation - _currentRotation;
      if (rotationDelta > 180) rotationDelta -= 360;
      if (rotationDelta < -180) rotationDelta += 360;

      final absDelta = rotationDelta.abs();
      final rotationRate = absDelta <= _rotationMaxRate
          ? absDelta / _rotationAnimationDuration
          : _rotationMaxRate;

      final rotationStep = rotationRate * dt;
      if (absDelta <= rotationStep || rotationRate == 0) {
        _currentRotation = _targetRotation;
      } else {
        _currentRotation += rotationStep * rotationDelta.sign;
      }

      // Normalize to [-180, 180]
      if (_currentRotation > 180) _currentRotation -= 360;
      if (_currentRotation < -180) _currentRotation += 360;
    }

    // === Zoom smoothing ===
    if (prediction.immediateReset) {
      _currentZoom = prediction.zoom;
      _targetZoom = prediction.zoom;
    } else {
      // Apply hysteresis to target zoom
      if ((prediction.zoom - _targetZoom).abs() > _zoomHysteresis) {
        _targetZoom = prediction.zoom;
      }

      // Smooth zoom with linear interpolation
      final zoomDelta = _targetZoom - _currentZoom;
      final zoomStep = _zoomSmoothingRate * dt;
      if (zoomDelta.abs() <= zoomStep) {
        _currentZoom = _targetZoom;
      } else {
        _currentZoom += zoomStep * zoomDelta.sign;
      }
    }

    // === Apply to camera ===
    final rotation = _currentRotation;
    final zoom = _currentZoom;

    // Calculate center position with vehicle offset
    LatLng centerPosition = prediction.position;
    if (offset != Offset.zero) {
      final gpsPixel = camera.project(prediction.position, zoom);
      final rotationRad = rotation * math.pi / 180.0;
      final centerPixel = math.Point(
        gpsPixel.x - offset.dy * math.sin(rotationRad),
        gpsPixel.y - offset.dy * math.cos(rotationRad),
      );
      centerPosition = camera.unproject(centerPixel, zoom);
    }

    try {
      controller.moveAndRotate(centerPosition, camera.clampZoom(zoom), rotation);
    } catch (e) {
      // Silently ignore - widget likely disposed during animation
    }
  }
}
