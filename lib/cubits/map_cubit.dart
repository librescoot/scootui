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

import '../config.dart';
import '../map/mbtiles_provider.dart';
import '../repositories/tiles_repository.dart';
import '../routing/brouter.dart';
import '../routing/models.dart';
import '../routing/route_helpers.dart';
import '../state/gps.dart';
import '../state/navigation.dart';
import 'mdb_cubits.dart';
import 'theme_cubit.dart';

part 'map_cubit.freezed.dart';
part 'map_state.dart';

final distanceCalculator = Distance();
const defaultCoordinates = LatLng(52.52437, 13.41053);

class MapCubit extends Cubit<MapState> {
  late final StreamSubscription<GpsData> _gpsSub;
  late final StreamSubscription<ThemeState> _themeSub;
  late final StreamSubscription<NavigationData> _navigationSub;
  final NavigationSync _navigationSync;
  final TilesRepository _tilesRepository;
  static const double _offRouteTolerance = 5.0; // 5 meters
  static const double _maxZoom = 19.0;
  static const double _minZoom = 16.5;
  static const double _zoomInStart = 220.0;
  static const double _zoomInEnd = 30.0;
  static const Offset _navigationOffset = Offset(0, 120);
  DateTime? _lastReroute;
  AnimatedMapController? _animatedController;
  Future<void>? _currentAnimation;
  LatLng? _pendingDestination;

  bool _mapLocked = false;

  static MapCubit create(BuildContext context) => MapCubit(
        context.read<GpsSync>().stream,
        context.read<ThemeCubit>().stream,
        context.read<NavigationSync>(),
        context.read<TilesRepository>(),
      )
        .._onGpsData(context.read<GpsSync>().state)
        .._loadMap(context.read<ThemeCubit>().state);

  MapCubit(Stream<GpsData> gpsStream, Stream<ThemeState> themeUpdates,
      NavigationSync navigationSync, TilesRepository tilesRepository)
      : _tilesRepository = tilesRepository,
        _navigationSync = navigationSync,
        super(MapLoading(
            controller: MapController(), position: defaultCoordinates)) {
    _gpsSub = gpsStream.listen(_onGpsData);
    _themeSub = themeUpdates.listen(_onThemeUpdate);
    _navigationSub = navigationSync.stream.listen(_onNavigationData);
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
    _navigationSub.cancel();
    return super.close();
  }

  void _updateRoute(Route route) {
    final current = state;

    emit(switch (current) {
      MapOnline() => current.copyWith(route: route),
      MapOffline() => current.copyWith(route: route),
      _ => current,
    });
  }

  Future<void> startNavigation(LatLng destination) async {
    // if the map is locked during animation, don't do anything
    if (_mapLocked) return;

    if (state.destination == destination) {
      return;
    }

    await setDestination(destination);

    final current = state;
    final route = current.route;
    if (route == null) {
      return;
    }

    // play an animation that first shows the destination, then the whole route,
    // then the current position
    _mapLocked = true;
    final lastWaypoint = route.waypoints.last;

    // if the destination is more than 10 meters away from the last waypoint,
    // show both the destination and the last waypoint, otherwise just center
    // on the destination
    if (distanceCalculator.as(LengthUnit.Meter, lastWaypoint, destination) >
        15) {
      _animatedController?.mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [lastWaypoint, destination],
          padding: const EdgeInsets.all(100),
        ),
      );
    } else {
      _animatedController?.mapController.moveAndRotate(
        destination,
        _minZoom,
        0,
      );
    }
    await Future.delayed(const Duration(milliseconds: 5000));
    await _animatedController?.animatedFitCamera(
      cameraFit: CameraFit.coordinates(
          coordinates: [current.position, destination],
          padding: const EdgeInsets.all(50)),
      rotation: 0,
      cancelPreviousAnimations: true,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 2000),
    );
    await Future.delayed(const Duration(milliseconds: 4000));
    _mapLocked = false;

    _moveAndRotate(current.position, current.orientation,
        duration: const Duration(milliseconds: 2000));
  }

  Future<void> setDestination(LatLng destination) async {
    if (state is! MapOffline && state is! MapOnline) {
      return;
    }

    emit(state.copyWith(destination: destination));

    final brouter = BRouterService(serverURL: AppConfig.routerEndpoint);
    final route = await brouter.getRoute(
      BRouterRequest(
        waypoints: [state.position, destination],
      ),
    );

    emit(state.copyWith(
        route: route,
        nextInstruction: _nextInstruction(route, state.position)));
  }

  void _moveAndRotate(LatLng center, double course, {Duration? duration}) {
    if (_mapLocked) return;
    final ctrl = _animatedController;

    if (ctrl == null) return;

    final route = state.route;
    final instruction = state.nextInstruction;
    double bearing = course;
    double zoom = _minZoom;

    if (route != null && route.waypoints.isNotEmpty) {
      // Find the closest point and next point on route
      final (point, segmentIndex, distance) =
          RouteHelpers.findClosestPointOnRoute(
        center,
        route.waypoints,
      );

      // Only use route bearing if we're close enough to the route
      if (distance < _offRouteTolerance) {
        // 5 meters tolerance
        // Get next point to calculate bearing
        final nextPointIndex =
            math.min(segmentIndex + 1, route.waypoints.length - 1);
        if (nextPointIndex > segmentIndex) {
          final currentPoint = route.waypoints[segmentIndex];
          final nextPoint = route.waypoints[nextPointIndex];

          // Calculate bearing between points
          final y = math.sin(nextPoint.longitude - currentPoint.longitude) *
              math.cos(nextPoint.latitude);
          final x =
              math.cos(currentPoint.latitude) * math.sin(nextPoint.latitude) -
                  math.sin(currentPoint.latitude) *
                      math.cos(nextPoint.latitude) *
                      math.cos(nextPoint.longitude - currentPoint.longitude);
          final routeBearing = math.atan2(y, x) * (180 / math.pi);

          // Normalize to 0-360
          bearing = (routeBearing + 360) % 360;
        }

        center = point;
        if (instruction != null) {
          if (instruction.distance >= _zoomInStart) {
            zoom = _minZoom;
          } else if (instruction.distance <= _zoomInEnd) {
            zoom = _maxZoom;
          } else {
            zoom = _minZoom +
                (_maxZoom - _minZoom) *
                    (1 -
                        (instruction.distance - _zoomInEnd) /
                            (_zoomInStart - _zoomInEnd));
          }
        }
      }
    }

    ctrl.mapController.move(center, zoom, offset: _navigationOffset);
    ctrl.mapController.rotateAroundPoint(bearing, offset: _navigationOffset);
  }

  Future<void> _checkRouteDeviation(LatLng position) async {
    final current = state;
    final route = current.route;

    if (route == null || route.waypoints.isEmpty) {
      return;
    }

    final (_, _, distance) = RouteHelpers.findClosestPointOnRoute(
      position,
      route.waypoints,
    );

    // If we're too far from the route and haven't rerouted recently
    if (distance > _offRouteTolerance &&
        (_lastReroute == null ||
            DateTime.now().difference(_lastReroute!) >
                const Duration(seconds: 5))) {
      _lastReroute = DateTime.now();

      if (route.waypoints.isEmpty) {
        return;
      }

      // Find the last instruction point in the route
      final destination = route.waypoints.last;

      // Recalculate route
      await setDestination(destination);
    }
  }

  RouteInstruction? _nextInstruction(Route? route, LatLng position) {
    if (route == null) return null;
    return RouteHelpers.findNextInstruction(position, route);
  }

  void _onNavigationData(NavigationData data) {
    try {
      if (data.destination.isEmpty) {
        print("Skipping empty navigation data");
        _pendingDestination = null; // Clear pending if destination is cleared
        // Optionally, cancel existing navigation if needed
        return;
      }

      final coordinates =
          data.destination.split(",").map(double.parse).toList();
      final destination = LatLng(coordinates[0], coordinates[1]);

      // Check if map is ready before starting navigation
      if (state is MapOffline || state is MapOnline) {
        print("Map ready, starting navigation to $destination");
        startNavigation(destination);
        _pendingDestination = null; // Clear pending once processed
      } else {
        print("Map not ready, pending destination set to $destination");
        _pendingDestination = destination; // Store for later
      }
    } catch (e) {
      print("Error processing navigation data: $e");
      _pendingDestination = null; // Clear pending on error
      // TODO: show error UI
    }
  }

  void _onGpsData(GpsData data) {
    final current = state;
    final course = (360 - data.course);
    final position = LatLng(data.latitude, data.longitude);
    final instruction = _nextInstruction(current.route, position);

    emit(current.copyWith(
      position: position,
      orientation: course,
      nextInstruction: instruction,
    ));
    _moveAndRotate(position, course);
    _checkRouteDeviation(position);
  }

  void _onThemeUpdate(ThemeState event) {
    final current = state;

    emit(MapState.loading(
        controller: state.controller, position: state.position));
    _getTheme(event.isDark).then((theme) => emit(switch (current) {
          MapOffline() => current.copyWith(theme: theme),
          _ => current,
        }));
  }

  Future<void> _onMapReady(TickerProvider vsync) async {
    final current = state;
    // TODO: the animation shouldn't really be in here, because it's a purely
    //  visual thing and not related to the map state. eventually this should
    //  be moved back into the map widget.
    _animatedController = AnimatedMapController(
        vsync: vsync,
        mapController: current.controller,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);

    // Ensure the state is updated correctly even if it was MapLoading
    // when the callback was triggered. Assume offline context based on _loadMap logic.
    emit(switch (current) {
      MapOffline() => current.copyWith(isReady: true),
      MapOnline() => current.copyWith(isReady: true),
      // If it was loading, transition to offline ready state
      MapLoading(
        :final position,
        :final controller,
        :final route,
        :final nextInstruction,
        :final destination
      ) =>
        MapOffline(
          position: position,
          orientation: 0, // Assuming default orientation initially
          controller: controller,
          tiles: state is MapOffline
              ? (state as MapOffline).tiles
              : AsyncMbTilesProvider(
                  _tilesRepository), // Need to handle this better if online is possible
          theme: state is MapOffline
              ? (state as MapOffline).theme
              : await _getTheme(false), // Need to handle this better
          onReady: _onMapReady,
          isReady: true,
          route: route,
          nextInstruction: nextInstruction,
          destination: destination,
        ),
      MapUnavailable() => current, // Stay unavailable if it was unavailable
    });

    // Only move if the map is actually ready now
    final mapIsReady = state is MapOffline || state is MapOnline;
    if (mapIsReady) {
      _moveAndRotate(state.position, state.orientation);

      // Check if there was a pending destination and process it now
      if (_pendingDestination != null) {
        print(
            "Map is ready, processing pending destination: $_pendingDestination");
        startNavigation(_pendingDestination!);
        _pendingDestination = null; // Clear pending once processed
      } else {
        // No pending destination from recent PUBLISH, check initial state
        final initialData = _navigationSync.state;
        if (initialData.destination.isNotEmpty) {
          try {
            final coordinates =
                initialData.destination.split(",").map(double.parse).toList();
            final initialDestination = LatLng(coordinates[0], coordinates[1]);
            print(
                "Map is ready, processing initial destination from Redis: $initialDestination");
            startNavigation(initialDestination);
          } catch (e) {
            print("Error processing initial navigation data: $e");
            // Optionally handle error
          }
        }
      }
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
      // if current position is out of bounds of the map,
      // use the center of the map instead
      return LatLng(
        (bounds.top + bounds.bottom) / 2,
        (bounds.right + bounds.left) / 2,
      );
    }

    // if no bounds are set, just use the coordinates we were given
    return state.position;
  }

  Future<void> _loadMap(ThemeState themeState) async {
    _animatedController = null;
    emit(MapState.loading(
        controller: state.controller, position: state.position));
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
        emit(MapState.unavailable(message,
            controller: ctrl, position: state.position));
    }
  }
}
