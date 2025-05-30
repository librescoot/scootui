import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../map/mbtiles_provider.dart';
import '../repositories/tiles_repository.dart';
import '../state/gps.dart';
import '../repositories/mdb_repository.dart';
import 'mdb_cubits.dart'; // Added GpsSync
import 'shutdown_cubit.dart';
import 'theme_cubit.dart';
import 'navigation_cubit.dart'; // Added for NavigationCubit
import 'navigation_state.dart'; // Added for NavigationState

part 'map_cubit.freezed.dart';
part 'map_state.dart';

final distanceCalculator = Distance(); // Consider moving if only used by NavigationCubit
const defaultCoordinates = LatLng(52.52437, 13.41053);

class MapCubit extends Cubit<MapState> {
  late final StreamSubscription<GpsData> _gpsSub;
  late final StreamSubscription<ThemeState> _themeSub;
  late final StreamSubscription<ShutdownState> _shutdownSub;
  late final StreamSubscription<NavigationState> _navigationStateSub; // Added
  final TilesRepository _tilesRepository;
  final MDBRepository _mdbRepository; // Keep if used for other map features

  static const double _maxZoom = 19.0;
  static const double _minZoom = 16.5;
  // static const double _zoomInStart = 220.0; // Moved to NavigationCubit
  // static const double _zoomInEnd = 30.0; // Moved to NavigationCubit
  static const Offset _mapCenterOffset = Offset(0, 120); // Restored original offset Y value

  AnimatedMapController? _animatedController;
  bool _mapLocked = false; // Keep if map interactions need locking

  static MapCubit create(BuildContext context) => MapCubit(
        gpsStream: context.read<GpsSync>().stream,
        themeUpdates: context.read<ThemeCubit>().stream,
        shutdownStream: context.read<ShutdownCubit>().stream,
        navigationStateStream: context.read<NavigationCubit>().stream, // Added
        tilesRepository: context.read<TilesRepository>(),
        mdbRepository: RepositoryProvider.of<MDBRepository>(context),
      )
        .._onGpsData(context.read<GpsSync>().state)
        .._loadMap(context.read<ThemeCubit>().state);

  MapCubit({
    required Stream<GpsData> gpsStream,
    required Stream<ThemeState> themeUpdates,
    required Stream<ShutdownState> shutdownStream,
    required Stream<NavigationState> navigationStateStream, // Added
    required TilesRepository tilesRepository,
    required MDBRepository mdbRepository,
  })  : _tilesRepository = tilesRepository,
        _mdbRepository = mdbRepository,
        super(MapLoading(controller: MapController(), position: defaultCoordinates)) {
    _gpsSub = gpsStream.listen(_onGpsData);
    _themeSub = themeUpdates.listen(_onThemeUpdate);
    _shutdownSub = shutdownStream.listen(_onShutdownStateChange);
    _navigationStateSub = navigationStateStream.listen(_onNavigationStateChanged); // Added
  }

  @override
  Future<void> close() {
    final current = state;
    current.controller.dispose();
    switch (current) {
      case MapOffline():
        final tiles = current.tiles;
        if (tiles is AsyncMbTilesProvider) {
          tiles.dispose();
        }
        break;
      default:
    }
    _themeSub.cancel();
    _gpsSub.cancel();
    _shutdownSub.cancel();
    _navigationStateSub.cancel(); // Added
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
    // Potentially update map display based on navigation state
    // e.g., show/hide route, update markers, etc.
    // For now, this cubit will primarily focus on camera and position.
    // Route drawing will be handled by a widget listening to NavigationCubit.
    if (navState.isNavigating && navState.hasDestination) {
      // Example: if map should follow user during navigation
      // _moveAndRotate(state.position, state.orientation);
    }
  }

  void _moveAndRotate(LatLng center, double course, {Duration? duration}) {
    if (_mapLocked) {
      print("MapCubit: Map is locked, skipping _moveAndRotate.");
      return;
    }
    final ctrl = _animatedController;
    if (ctrl == null) {
      print("MapCubit: AnimatedMapController is null in _moveAndRotate. Map not ready or not initialized yet.");
      return;
    }

    // Simplified zoom logic, or make it dependent on NavigationState if needed
    double zoom = _minZoom;
    // Potentially adjust zoom based on navState.nextInstruction.distance if that info is passed here
    // or if MapCubit directly listens to NavigationCubit for zoom adjustments.

    ctrl.mapController.move(center, zoom, offset: _mapCenterOffset);

    final baseMapController = ctrl.mapController; // AnimatedMapController.mapController is the base MapController
    // For heading-up: rotate map so travel direction points up on screen
    // GPS course 0° = North, 90° = East, 180° = South, 270° = West
    // MapController.rotate() expects degrees, where 0° = North pointing up
    // To make course direction point up, rotate map by -course
    final rotationInDegrees = -course;
    baseMapController.rotate(rotationInDegrees);

    final currentRotationInDegrees = baseMapController.camera.rotation * (180 / math.pi);
  }

  void _onGpsData(GpsData data) {
    final current = state;

    // Map should rotate by the vehicle's actual course.
    final courseForMapRotation = data.course;

    // Marker should counter-rotate by the same amount to stay screen-upright.
    final orientationForMarker = data.course;

    final position = LatLng(data.latitude, data.longitude);

    emit(current.copyWith(
      position: position,
      orientation: orientationForMarker,
    ));
    _moveAndRotate(position, courseForMapRotation);
  }

  void _onThemeUpdate(ThemeState event) {
    final current = state;
    emit(MapState.loading(controller: state.controller, position: state.position));
    _getTheme(event.isDark).then((theme) => emit(switch (current) {
          MapOffline() => current.copyWith(theme: theme),
          _ => current, // Should not happen if map is loaded
        }));
  }

  Future<void> _onMapReady(TickerProvider vsync) async {
    final current = state;
    _animatedController = AnimatedMapController(
        vsync: vsync,
        mapController: current.controller,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);

    emit(switch (current) {
      MapOffline() => current.copyWith(isReady: true),
      MapOnline() => current.copyWith(isReady: true),
      MapLoading(:final position, :final controller) => MapOffline(
          // Default to offline if was loading
          position: position,
          orientation: 0,
          controller: controller,
          tiles: AsyncMbTilesProvider(_tilesRepository), // Re-init or ensure it's available
          theme: await _getTheme(false), // Default theme
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

  Future<void> _loadMap(ThemeState themeState) async {
    _animatedController = null;
    emit(MapState.loading(controller: state.controller, position: state.position));
    final theme = await _getTheme(themeState.isDark);
    final ctrl = MapController();

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
          onReady: _onMapReady,
        ));
      case InitError(:final message):
        emit(MapState.unavailable(message, controller: ctrl, position: state.position));
    }
  }
}
