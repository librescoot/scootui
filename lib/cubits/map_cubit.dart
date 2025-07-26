import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path/path.dart' as p;
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../map/mbtiles_provider.dart';
import '../repositories/mdb_repository.dart';
import '../repositories/tiles_update_repository.dart';
import '../services/map_service.dart';
import '../services/task_service.dart';
import '../services/toast_service.dart';
import '../services/valhalla_service_controller.dart';
import '../state/gps.dart';
import '../map/download/download_task.dart';
import '../theme_config.dart';
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
  late final StreamSubscription<NavigationState> _navigationStateSub; // Added
  final MapService _mapService;
  final TaskService _taskService;
  final ValhallaServiceController _valhallaServiceController;

  // Dynamic zoom constants based on navigation context
  static const double _zoomLongStraight = 15.5; // Long straight sections (>2km)
  static const double _zoomDefault = 17.0; // Default navigation zoom
  static const double _zoomApproachingTurn = 18.0; // Approaching turn (<500m)
  static const double _zoomComplexTurn =
      19.0; // Complex intersections/roundabouts
  static const Offset _mapCenterOffset =
      Offset(0, 120); // Restored original offset Y value

  AnimatedMapController? _animatedController;
  final bool _mapLocked = false;
  Timer? _updateTimer; // For throttling GPS updates
  NavigationState?
      _currentNavigationState; // Store current navigation state for zoom logic
  ThemeState? _lastThemeState; // Store last theme state for map updates

  static MapCubit create(BuildContext context) => MapCubit(
        gpsStream: context.read<GpsSync>().stream,
        themeUpdates: context.read<ThemeCubit>().stream,
        shutdownStream: context.read<ShutdownCubit>().stream,
        navigationStateStream: context.read<NavigationCubit>().stream, // Added
        mapService: RepositoryProvider.of<MapService>(context),
        taskService: RepositoryProvider.of<TaskService>(context),
        valhallaServiceController:
            RepositoryProvider.of<ValhallaServiceController>(context),
        mdbRepository: RepositoryProvider.of<MDBRepository>(context),
      )
        .._onGpsData(context.read<GpsSync>().state)
        .._lastThemeState =
            context.read<ThemeCubit>().state // Store initial theme state
        .._loadMap(context.read<ThemeCubit>().state);

  MapCubit({
    required Stream<GpsData> gpsStream,
    required Stream<ThemeState> themeUpdates,
    required Stream<ShutdownState> shutdownStream,
    required Stream<NavigationState> navigationStateStream, // Added
    required MapService mapService,
    required TaskService taskService,
    required ValhallaServiceController valhallaServiceController,
    required MDBRepository mdbRepository,
  })  : _mapService = mapService,
        _taskService = taskService,
        _valhallaServiceController = valhallaServiceController,
        super(MapLoading(
            controller: MapController(), position: defaultCoordinates)) {
    _gpsSub = gpsStream.listen(_onGpsData);
    _themeSub = themeUpdates.listen(_onThemeUpdate);
    _shutdownSub = shutdownStream.listen(_onShutdownStateChange);
    _navigationStateSub =
        navigationStateStream.listen(_onNavigationStateChanged); // Added
  }

  @override
  Future<void> close() {
    final current = state;
    current.controller.dispose();
    _themeSub.cancel();
    _gpsSub.cancel();
    _shutdownSub.cancel();
    _navigationStateSub.cancel(); // Added
    _updateTimer?.cancel(); // Cancel GPS throttling timer
    return super.close();
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

  void _moveAndRotate(LatLng center, double course, {Duration? duration}) {
    if (_mapLocked) {
      print("MapCubit: Map is locked, skipping _moveAndRotate.");
      return;
    }
    final ctrl = _animatedController;
    if (ctrl == null) {
      print(
          "MapCubit: AnimatedMapController is null in _moveAndRotate. Map not ready or not initialized yet.");
      return;
    }

    final navState = _currentNavigationState;
    final isOffRoute = navState?.isOffRoute ?? false;

    // Dynamic zoom based on navigation context
    double zoom = _calculateDynamicZoom();

    // When off-route, use north-up orientation and center the vehicle
    double rotation = isOffRoute ? 0.0 : -course;
    Offset offset = isOffRoute ? Offset.zero : _mapCenterOffset;

    // Use animated controller for smooth transitions
    ctrl.animateTo(
      dest: center,
      zoom: zoom,
      rotation: rotation,
      offset: offset,
    );
  }

  double _calculateDynamicZoom() {
    final navState = _currentNavigationState;

    if (navState == null ||
        !navState.isNavigating ||
        navState.upcomingInstructions.isEmpty) {
      return _zoomDefault;
    }

    if (navState.isOffRoute) {
      return _zoomLongStraight;
    }

    final nextInstruction = navState.upcomingInstructions.first;
    final distanceToTurn = nextInstruction.distance; // in meters

    if (distanceToTurn <= 1) {
      return _zoomComplexTurn; // Very close, zoom in fully
    }

    const screenHeight = 480.0;
    const topStatusBarHeight = 30.0;
    const bottomBarHeight = 60.0;
    const vehicleVerticalOffset = 0.75;

    const visibleMapHeight =
        screenHeight - topStatusBarHeight - bottomBarHeight;

    // The point of interest (the turn) should be visible in the upper part of the map.
    // The vehicle is not in the center, it's offset downwards.
    // This means we have more "look-ahead" distance.
    final lookAheadHeight = visibleMapHeight * vehicleVerticalOffset;

    // We want to fit the distanceToTurn within this lookAheadHeight.
    final targetVisibleMeters = distanceToTurn;

    // This formula is a heuristic to convert meters to a zoom level.
    // It's derived from how map scales work (roughly doubles with each zoom level).
    // The constants are tuned to fit the visual layout.
    // C - log2(meters) -> zoom
    // The value 15.6 is a magic number that works well for this screen size and projection.
    double requiredZoom =
        15.6 - math.log(targetVisibleMeters / lookAheadHeight) / math.ln2;

    // Clamp the zoom level to reasonable bounds
    return requiredZoom.clamp(_zoomLongStraight, _zoomComplexTurn);
  }

  void _onGpsData(GpsData data) {
    final current = state;

    // Map should rotate by the vehicle's actual course.
    final courseForMapRotation = data.course;

    // Marker should counter-rotate by the same amount to stay screen-upright.
    final orientationForMarker = data.course;

    final rawPosition = LatLng(data.latitude, data.longitude);

    // Use snapped position when navigating and on-route, otherwise use raw GPS position
    final navState = _currentNavigationState;
    final positionForDisplay =
        (navState?.isNavigating == true && navState?.snappedPosition != null)
            ? navState!.snappedPosition!
            : rawPosition;

    emit(current.copyWith(
      position: positionForDisplay,
      orientation: orientationForMarker,
    ));

    // Throttle map updates to reduce performance impact
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 100), () {
      _moveAndRotate(positionForDisplay, courseForMapRotation);
    });
  }

  void _onThemeUpdate(ThemeState event) {
    _lastThemeState = event; // Store the theme state
    final current = state;
    emit(MapState.loading(
        controller: state.controller, position: state.position));
    _getTheme(event.isDark).then((theme) => emit(switch (current) {
          MapOffline() => current.copyWith(
              theme: theme, themeMode: event.isDark ? 'dark' : 'light'),
          _ => current, // Should not happen if map is loaded
        }));
  }

  Future<void> _onMapReady(TickerProvider vsync) async {
    final current = state;
    if (current is! MapOffline) {
      // This should not happen, but as a safeguard.
      return;
    }
    _animatedController = AnimatedMapController(
        vsync: vsync,
        mapController: current.controller,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);

    // The controller is now ready. Move the map to the correct position
    // BEFORE emitting the final ready state to avoid race conditions.
    _moveAndRotate(current.position, current.orientation);

    // Now, emit the ready state.
    emit(current.copyWith(isReady: true));
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

  /// Fire and forget map download
  void downloadMap(Region region) async {
    try {
      ToastService.showInfo('Starting map download for ${region.name}...');

      final mapsDir = await _mapService.getMapsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final newMapPath = p.join(mapsDir.path, 'map_$timestamp.mbtiles');

      // Create download tasks
      final osmTask = DownloadTask(
        url: region.osmTilesUrl,
        destination: newMapPath,
        description: 'Downloading ${region.name} map data',
      );

      _taskService.addTask(osmTask);
      final osmStatus = await osmTask.wait();

      if (osmStatus is TaskCompleted) {
        await _applyMapUpdate(newMapPath);
      } else if (osmStatus is TaskError) {
        ToastService.showError(
            'Failed to download map data: ${osmStatus.message}');
      }
    } catch (e) {
      ToastService.showError('Map download failed: $e');
    }
  }

  Future<void> _applyMapUpdate(String newMapPath) async {
    try {
      await _mapService.updateMap(newMapPath);

      ToastService.showSuccess('Map updated successfully!');
    } on MapUnavailableException catch (e) {
      ToastService.showError('Update failed: ${e.message}');
      print('Update failed: ${e.toString()}');
    } catch (e) {
      ToastService.showError('An unexpected error occurred: ${e.toString()}');
      print('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (_lastThemeState != null) {
        await _loadMap(_lastThemeState!);
      }
    }
  }

  Future<void> _loadMap(ThemeState themeState) async {
    _animatedController = null;
    emit(MapState.loading(
        controller: state.controller, position: state.position));
    final theme = await _getTheme(themeState.isDark);
    final ctrl = MapController();

    try {
      final metadata = await _mapService.getMetadata();
      final provider = AsyncMbTilesProvider(_mapService, metadata);
      emit(MapState.offline(
        tiles: provider,
        position: _getInitialCoordinates(metadata),
        orientation: 0,
        controller: ctrl,
        theme: theme,
        themeMode: themeState.isDark ? 'dark' : 'light',
        onReady: _onMapReady,
      ));
    } on MapUnavailableException catch (e) {
      emit(MapState.unavailable(e.message,
          controller: ctrl, position: state.position));
    }
  }
}
