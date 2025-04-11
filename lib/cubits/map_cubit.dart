import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

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

  Future<void> setDestination(LatLng destination) async {
    final current = state;
    if (current is! MapOffline && current is! MapOnline) {
      return;
    }

    final waypoints = [
      state.position,
      destination,
    ]
        .map((latlng) => LngLat(lng: latlng.longitude, lat: latlng.latitude))
        .toList();

    final route = await _routingManager.getRoute(
        request: OSRMRequest.route(
      waypoints: waypoints,
      geometries: Geometries.polyline,
      routingType: RoutingType.car,
    ));

    emit(switch (current) {
      MapOnline() => current.copyWith(route: route),
      MapOffline() => current.copyWith(route: route),
      _ => current,
    });
  }

  void _moveAndRotate(LatLng center, double course) {
    final ctrl = switch (state) {
      MapOnline(:final controller, :final isReady) =>
        isReady ? controller : null,
      MapOffline(:final controller, :final isReady) =>
        isReady ? controller : null,
      _ => null,
    };
    final offset = Offset(0, 100);

    ctrl?.move(center, ctrl.camera.zoom, offset: offset);
    ctrl?.rotateAroundPoint(course, offset: offset);
  }

  void _onGpsData(GpsData data) {
    final course = (360 - data.course);
    final position = LatLng(data.latitude, data.longitude);

    _moveAndRotate(position, course);
    emit(state.copyWith(
      position: position,
      orientation: course,
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

  void _onMapReady() {
    final current = state;

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
