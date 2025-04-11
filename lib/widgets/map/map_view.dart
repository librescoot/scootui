import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart'
    show Alignment, BuildContext, Colors, Icon, Icons, StatelessWidget, Widget;
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_map/flutter_map.dart'
    show
        FlutterMap,
        MapController,
        MapOptions,
        Marker,
        MarkerLayer,
        Polyline,
        PolylineLayer,
        TileLayer;
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:routing_client_dart/routing_client_dart.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart'
    show TileProviders, VectorTileLayer;
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart'
    show MbTilesVectorTileProvider;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' show Theme;

class OnlineMapView extends StatelessWidget {
  final MapController mapController;
  final LatLng position;
  final double orientation;
  final void Function()? mapReady;

  const OnlineMapView({
    super.key,
    required this.mapController,
    required this.position,
    required this.orientation,
    this.mapReady,
  });
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        onMapReady: mapReady,
        minZoom: 8,
        maxZoom: 18,
        initialCenter: position,
        initialZoom: 17,
      ),
      mapController: mapController,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'github.com/librescoot/scootui',
          // Plenty of other options available!
        ),
        MarkerLayer(markers: [
          Marker(
            width: 30.0,
            height: 30.0,
            point: position,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -orientation * (math.pi / 180),
              child: const Icon(
                Icons.navigation,
                color: Colors.blue,
                size: 30.0,
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class OfflineMapView extends StatelessWidget {
  final MapController mapController;
  final Theme theme;
  final MbTiles mbTiles;
  final LatLng position;
  final double orientation;
  final void Function()? mapReady;
  final FutureOr<void> Function(LatLng)? setDestination;
  final Route? route;

  const OfflineMapView({
    super.key,
    required this.mapController,
    required this.theme,
    required this.mbTiles,
    required this.position,
    required this.orientation,
    this.setDestination,
    this.route,
    this.mapReady,
  });

  Widget? _routeLayer() {
    final line = route?.polyline;
    if (line == null || line.isEmpty) {
      return null;
    }

    final points =
        line.map((lnglat) => LatLng(lnglat.lat, lnglat.lng)).toList();

    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          strokeWidth: 4.0,
          color: Colors.lightBlue,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeLayer = _routeLayer();

    return FlutterMap(
      options: MapOptions(
        onMapReady: mapReady,
        minZoom: 8,
        maxZoom: 18,
        initialCenter: position,
        initialZoom: 17,
        onSecondaryTap: (position, coordinates) {
          if (setDestination != null) {
            setDestination!(coordinates);
          }
        },
      ),
      mapController: mapController,
      children: [
        VectorTileLayer(
          theme: theme,
          tileProviders: TileProviders({
            'versatiles-shortbread': MbTilesVectorTileProvider(
              mbtiles: mbTiles,
              silenceTileNotFound: true,
            ),
          }),
          maximumZoom: 18,
          // Set minimal cache settings to prevent theme persistence
          fileCacheTtl: const Duration(seconds: 1),
          memoryTileCacheMaxSize: 0,
          // Disable memory tile cache
          memoryTileDataCacheMaxSize: 0,
          // Disable memory tile data cache
          fileCacheMaximumSizeInBytes: 1024 * 1024,
          // 1MB file cache
          // Force immediate tile updates
          tileDelay: Duration.zero,
        ),
        MarkerLayer(markers: [
          Marker(
            width: 30.0,
            height: 30.0,
            point: position,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -orientation * (math.pi / 180),
              child: const Icon(
                Icons.navigation,
                color: Colors.blue,
                size: 30.0,
              ),
            ),
          ),
        ]),
        if (routeLayer != null) routeLayer,
      ],
    );
  }
}
