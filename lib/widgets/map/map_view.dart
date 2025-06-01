import 'dart:math' as math;

import 'package:flutter/material.dart'
    show Alignment, BuildContext, Colors, Icon, Icons, Widget, TickerProviderStateMixin;
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart'
    show FlutterMap, MapController, MapOptions, Marker, MarkerLayer, Polyline, PolylineLayer, TileLayer;
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' show TileProviders, VectorTileLayer, VectorTileProvider;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' show Theme;

import '../../repositories/mdb_repository.dart';
import '../../routing/models.dart';
import '../../utils/theme_aware_cache.dart';

final distanceCalculator = Distance();

class NorthIndicator extends StatelessWidget {
  final double orientation;

  const NorthIndicator({super.key, required this.orientation});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Transform.rotate(
        angle: -orientation * (math.pi / 180), // Rotate to show where north is
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: const Stack(
            children: [
              Positioned(
                top: -6,
                left: 4,
                child: Icon(
                  Icons.arrow_drop_up,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnlineMapView extends StatefulWidget {
  final MapController mapController;
  final LatLng position;
  final double orientation;
  final void Function(TickerProvider)? mapReady;
  final Route? route; // Added
  final LatLng? destination; // Added

  const OnlineMapView({
    super.key,
    required this.mapController,
    required this.position,
    required this.orientation,
    this.mapReady,
    this.route, // Added
    this.destination, // Added
  });

  @override
  State<OnlineMapView> createState() => _OnlineMapViewState();
}

class _OnlineMapViewState extends State<OnlineMapView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            onMapReady: () => widget.mapReady?.call(this),
            minZoom: 8,
            maxZoom: 18,
            initialCenter: widget.position,
            initialZoom: 17,
          ),
          mapController: widget.mapController,
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'github.com/librescoot/scootui',
            ),
            if (widget.route != null && widget.route!.waypoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.route!.waypoints,
                    strokeWidth: 4.0,
                    color: Colors.lightBlue,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.position,
                  width: 30.0,
                  height: 30.0,
                  alignment: Alignment.center,
                  rotate: false, // Don't let flutter_map rotate the marker
                  child: Transform.rotate(
                    angle: widget.orientation * (math.pi / 180), // Convert degrees to radians
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ),
                if (widget.destination != null)
                  Marker(
                    point: widget.destination!,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 30.0),
                  ),
              ],
            ),
          ],
        ),
        NorthIndicator(orientation: widget.orientation),
      ],
    );
  }
}

class OfflineMapView extends StatefulWidget {
  final MapController mapController;
  final Theme theme;
  final VectorTileProvider tiles;
  final LatLng position;
  final double orientation;
  final String themeMode;
  final void Function(TickerProvider)? mapReady;
  // final FutureOr<void> Function(LatLng)? setDestination; // Removed, handled by MDBRepository
  final Route? route;
  // final RouteInstruction? nextInstruction; // Removed, handled by TurnByTurnWidget
  final LatLng? destination;

  const OfflineMapView({
    super.key,
    required this.mapController,
    required this.theme,
    required this.tiles,
    required this.position,
    required this.orientation,
    required this.themeMode,
    // this.setDestination, // Removed
    this.route,
    this.mapReady,
    // this.nextInstruction, // Removed
    this.destination,
  });

  @override
  State<OfflineMapView> createState() => _OfflineMapViewState();
}

class _OfflineMapViewState extends State<OfflineMapView> with TickerProviderStateMixin {
  Widget? _routeLayer() {
    final waypoints = widget.route?.waypoints;
    if (waypoints == null || waypoints.isEmpty) {
      return null;
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: waypoints,
          strokeWidth: 4.0,
          color: Colors.lightBlue,
        ),
      ],
    );
  }

  List<Marker> _routeMarkers() {
    final markers = <Marker>[];
    if (widget.destination != null) {
      markers.add(Marker(
        point: widget.destination!,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 30.0),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final routeLayer = _routeLayer();

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            onMapReady: () {
              widget.mapReady?.call(this);
            },
            minZoom: 8,
            maxZoom: 20,
            initialCenter: widget.position,
            initialZoom: 17,
            onTap: (tapPosition, latLng) {
              // Set GPS location via MDBRepository in simulator mode
              final mdbRepo = RepositoryProvider.of<MDBRepository>(context);
              mdbRepo.set("gps", "latitude", latLng.latitude.toString());
              mdbRepo.set("gps", "longitude", latLng.longitude.toString());
            },
            onSecondaryTap: (tapPosition, latLng) {
              // Set destination via MDBRepository, NavigationCubit will pick it up
              final mdbRepo = RepositoryProvider.of<MDBRepository>(context);
              final coordinates = "${latLng.latitude},${latLng.longitude}";
              mdbRepo.set("navigation", "destination", coordinates);
            },
          ),
          mapController: widget.mapController,
          children: [
            VectorTileLayer(
              theme: widget.theme,
              tileProviders: TileProviders({
                'versatiles-shortbread': widget.tiles,
              }),
              maximumZoom: 20,
              // Optimized cache settings for better performance
              fileCacheTtl: const Duration(hours: 24), // Cache tiles for 24 hours
              memoryTileCacheMaxSize: 10 * 1024 * 1024, // 10MB memory cache (bytes)
              memoryTileDataCacheMaxSize: 99, // 99 parsed tiles in memory (max < 100)
              fileCacheMaximumSizeInBytes: 500 * 1024 * 1024, // 500MB file cache
              tileDelay: Duration.zero,
              cacheFolder: ThemeAwareCache.getCacheFolderProvider(widget.themeMode),
            ),
            if (routeLayer != null) routeLayer,
            MarkerLayer(markers: [
              Marker(
                point: widget.position,
                rotate: false, // Don't let flutter_map rotate the marker
                child: Transform.rotate(
                  angle: widget.orientation * (math.pi / 180), // Convert degrees to radians
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                ),
              ),
              ..._routeMarkers()
            ]),
          ],
        ),
        NorthIndicator(orientation: widget.orientation),
      ],
    );
  }
}
