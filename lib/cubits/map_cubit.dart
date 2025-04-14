import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart'
    hide RouteInstruction;
import 'package:routing_client_dart/src/routing_manager.dart'
    show RoadManagerUtils;
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

import '../routing/brouter.dart';
import '../routing/route_helpers.dart';
import '../state/gps.dart';
import 'mdb_cubits.dart';
import 'theme_cubit.dart';

part 'map_cubit.freezed.dart';
part 'map_state.dart';

const defaultCoordinates = LatLng(52.52437, 13.41053);

class MapCubit extends Cubit<MapState> {
  late final StreamSubscription<GpsData> _gpsSub;
  late final StreamSubscription<ThemeState> _themeSub;
  final RoutingManager _routingManager;
  static const double _offRouteTolerance = 5.0; // 5 meters
  static const double _maxZoom = 19.0;
  static const double _minZoom = 16.5;
  static const double _threshold = 130.0;
  DateTime? _lastReroute;
  AnimatedMapController? _animatedController;
  Future<void>? _currentAnimation;

  static MapCubit create(BuildContext context) => MapCubit(
        context.read<GpsSync>().stream,
        context.read<ThemeCubit>().stream,
      )
        .._onGpsData(context.read<GpsSync>().state)
        .._loadMap(context.read<ThemeCubit>().state);

  MapCubit(Stream<GpsData> stream, Stream<ThemeState> themeUpdates)
      : _routingManager = RoutingManager(),
        super(MapLoading(
            controller: MapController(), position: defaultCoordinates)) {
    _gpsSub = stream.listen(_onGpsData);
    _themeSub = themeUpdates.listen(_onThemeUpdate);
  }

  @override
  Future<void> close() {
    final current = state;
    current.controller.dispose();
    switch (current) {
      case MapOffline():
        current.mbTiles.dispose();
        break;
      default:
    }
    _themeSub.cancel();
    _gpsSub.cancel();
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

  Future<void> setDestination(LatLng destination) async {
    final current = state;
    if (current is! MapOffline && current is! MapOnline) {
      return;
    }

    final brouter = BRouterService();
    final route = await brouter.getRoute(
      BRouterRequest(
        waypoints: [current.position, destination],
      ),
    );

    // final waypoints = [
    //   state.position,
    //   destination,
    // ]
    //     .map((latlng) => LngLat(lng: latlng.longitude, lat: latlng.latitude))
    //     .toList();
    //
    // final route = await _routingManager.getRoute(
    //     request: OSRMRequest.route(
    //   waypoints: waypoints,
    //   geometries: Geometries.polyline,
    //   routingType: RoutingType.car,
    // ));

    emit(current.copyWith(
        route: route,
        nextInstruction: _nextInstruction(route, current.position)));
  }

  void _moveAndRotate(LatLng center, double course,
      [RouteInstruction? instruction]) {
    final ctrl = _animatedController;

    if (ctrl == null) return;

    final route = state.route;
    double bearing = course;
    double zoom = _minZoom;

    if (route != null && route.polyline != null && route.polyline!.isNotEmpty) {
      // Find the closest point and next point on route
      final (point, segmentIndex, distance) =
          RouteHelpers.findClosestPointOnRoute(
        center,
        route.polyline!,
      );

      // Only use route bearing if we're close enough to the route
      if (distance < _offRouteTolerance) {
        // 5 meters tolerance
        // Get next point to calculate bearing
        final nextPointIndex =
            math.min(segmentIndex + 1, route.polyline!.length - 1);
        if (nextPointIndex > segmentIndex) {
          final currentPoint = route.polyline![segmentIndex];
          final nextPoint = route.polyline![nextPointIndex];

          // Calculate bearing between points
          final y = math.sin(nextPoint.lng - currentPoint.lng) *
              math.cos(nextPoint.lat);
          final x = math.cos(currentPoint.lat) * math.sin(nextPoint.lat) -
              math.sin(currentPoint.lat) *
                  math.cos(nextPoint.lat) *
                  math.cos(nextPoint.lng - currentPoint.lng);
          final routeBearing = math.atan2(y, x) * (180 / math.pi);

          // Normalize to 0-360
          bearing = (routeBearing + 360) % 360;
        }

        center = point;
        if (instruction != null) {
          zoom = instruction.distance >= _threshold
              ? _minZoom
              : _minZoom +
                  (_maxZoom - _minZoom) *
                      (1 - instruction.distance / _threshold);
        }
      }
    }

    _animatedController?.animateTo(
        dest: center, zoom: zoom, rotation: bearing, curve: Curves.easeInOut);
  }

  Future<void> _checkRouteDeviation(LatLng position) async {
    final current = state;
    final route = current.route;

    if (route == null || route.polyline == null || route.polyline!.isEmpty) {
      return;
    }

    final (_, _, distance) = RouteHelpers.findClosestPointOnRoute(
      position,
      route.polyline!,
    );

    // If we're too far from the route and haven't rerouted recently
    if (distance > _offRouteTolerance &&
        (_lastReroute == null ||
            DateTime.now().difference(_lastReroute!) >
                const Duration(seconds: 5))) {
      _lastReroute = DateTime.now();

      // Find the last instruction point in the route
      final destination = route.polyline?.last;
      // if the current route does not have a polyline, do nothing
      if (destination == null) {
        return;
      }

      // Recalculate route
      await setDestination(destination.toLatLng());
    }
  }

  RouteInstruction? _nextInstruction(Route? route, LatLng position) {
    if (route == null) return null;
    return RouteHelpers.findNextInstruction(position, route);
  }

  void _onGpsData(GpsData data) {
    final current = state;
    final course = (360 - data.course);
    final position = LatLng(data.latitude, data.longitude);
    final instruction = _nextInstruction(current.route, position);

    _moveAndRotate(position, course, instruction);
    _checkRouteDeviation(position);
    emit(current.copyWith(
      position: position,
      orientation: course,
      nextInstruction: instruction,
    ));
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

  void _onMapReady(TickerProvider vsync) {
    final current = state;
    // TODO: the animation shouldn't really be in here, because it's a purely
    //  visual thing and not related to the map state. eventually this should
    //  be moved back into the map widget.
    _animatedController = AnimatedMapController(
        vsync: vsync,
        mapController: current.controller,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);

    emit(switch (current) {
      MapOffline() => current.copyWith(isReady: true),
      MapOnline() => current.copyWith(isReady: true),
      _ => current,
    });
    _moveAndRotate(current.position, current.orientation);
  }

  Future<Theme> _getTheme(bool isDark) async {
    final mapTheme = isDark ? 'assets/mapdark.json' : 'assets/maplight.json';
    final themeStr = await rootBundle.loadString(mapTheme);

    return ThemeReader().read(jsonDecode(themeStr));
  }

  LatLng _getInitialCoordinates(MbTiles tiles) {
    final meta = tiles.getMetadata();
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

    late final Directory appDir;

    try {
      appDir = await getApplicationDocumentsDirectory();
    } catch (e) {
      emit(MapState.online(
          position: state.position,
          orientation: state.orientation,
          controller: state.controller));
      return;
    }

    final mapPath = '${appDir.path}/maps/map.mbtiles';

    // check if map file exists
    final exists = await File(mapPath).exists();
    if (!exists) {
      emit(MapState.unavailable('Map file not found',
          controller: state.controller, position: state.position));
      return;
    }

    // Initialize MBTiles
    final mbTiles = MbTiles(
      mbtilesPath: mapPath,
      gzip: true,
    );

    emit(MapState.offline(
      mbTiles: mbTiles,
      position: _getInitialCoordinates(mbTiles),
      orientation: 0,
      controller: ctrl,
      theme: theme,
      onReady: _onMapReady,
    ));
  }
}

extension ConvertLngLat on LatLng {
  LngLat toLngLat() => LngLat(lng: longitude, lat: latitude);
}

extension ConvertLatLng on LngLat {
  LatLng toLatLng() => LatLng(lat, lng);
}
