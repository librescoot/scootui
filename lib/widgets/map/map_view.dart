import 'dart:math' as math;

import 'package:flutter/material.dart'
    show Border, BoxDecoration, BoxShape, BorderRadius, BorderSide, Brightness, BuildContext, Colors, Column, Container, CrossAxisAlignment, Curves, FontWeight, Icon, Icons, Paint, PaintingStyle, Positioned, SizedBox, State, StatefulWidget, Stack, Text, TextStyle, Theme, TweenAnimationBuilder, Widget, TickerProviderStateMixin;
import 'package:flutter/scheduler.dart' show Ticker, TickerCallback;
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart'
    show FlutterMap, MapController, MapOptions, Marker, MarkerLayer, Polyline, PolylineLayer, TileLayer;
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' show TileProviders, VectorTileLayer, VectorTileProvider;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../cubits/map_cubit.dart';
import '../../repositories/mdb_repository.dart';
import '../../routing/models.dart';
import '../../utils/theme_aware_cache.dart';

final distanceCalculator = Distance();

class NorthIndicator extends StatelessWidget {
  final double orientation;

  const NorthIndicator({super.key, required this.orientation});

  // Normalize angle to [-180, 180] range for shortest-path interpolation
  double _normalizeAngle(double angle) {
    double normalized = angle % 360;
    if (normalized > 180) normalized -= 360;
    if (normalized < -180) normalized += 360;
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey.shade800.withOpacity(0.9) : Colors.grey.shade300.withOpacity(0.9);
    final borderColor = isDark ? Colors.grey.shade600.withOpacity(0.9) : Colors.grey.shade500.withOpacity(0.9);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _normalizeAngle(orientation), end: _normalizeAngle(orientation)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: -angle * (math.pi / 180), // Rotate to show where north is
          child: child,
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 0.5),
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
    );
  }
}

class VehicleIndicator extends StatelessWidget {
  const VehicleIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey.shade800.withOpacity(0.9) : Colors.grey.shade300.withOpacity(0.9);
    final borderColor = isDark ? Colors.grey.shade600.withOpacity(0.9) : Colors.grey.shade500.withOpacity(0.9);

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, 130), // Match _mapCenterOffset from map_cubit
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: const Icon(
              Icons.navigation,
              color: Colors.blue,
              size: 30.0,
            ),
          ),
        ),
      ),
    );
  }
}

class ScaleBar extends StatelessWidget {
  final double? zoom;
  final double latitude;

  const ScaleBar({super.key, this.zoom, required this.latitude});

  // Calculate appropriate scale bar distance and width
  (String, double) _calculateScale() {
    final currentZoom = zoom ?? 17.0; // Default to zoom 17 if camera not ready
    // Calculate meters per pixel at this zoom level and latitude
    const earthCircumference = 40075000.0; // meters at equator
    final metersPerPixel = (earthCircumference * math.cos(latitude * math.pi / 180)) / (256 * math.pow(2, currentZoom));

    // Target scale bar width in pixels (max 1/3 of 480px screen = 160px)
    const maxWidth = 160.0;
    final targetMeters = metersPerPixel * maxWidth;

    // Round to nice numbers
    final scales = [20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000];
    int scaleMeters = scales.firstWhere((s) => s >= targetMeters * 0.6, orElse: () => 20);

    // Calculate actual pixel width for this scale
    final actualWidth = scaleMeters / metersPerPixel;

    // Format label
    String label;
    if (scaleMeters >= 1000) {
      final km = scaleMeters / 1000;
      label = km % 1 == 0 ? '${km.toInt()} km' : '$km km';
    } else {
      label = '$scaleMeters m';
    }

    return (label, actualWidth.clamp(40.0, maxWidth));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.white : Colors.black;
    final strokeColor = isDark ? Colors.black : Colors.white;

    final (label, width) = _calculateScale();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Stroke/outline
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = strokeColor,
              ),
            ),
            // Fill
            Text(
              label,
              style: TextStyle(
                color: fillColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        // Scale bar with vertical ticks on ends
        SizedBox(
          width: width,
          height: 8,
          child: Stack(
            children: [
              // Left vertical tick
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border.all(color: strokeColor, width: 0.5),
                  ),
                ),
              ),
              // Horizontal bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border.all(color: strokeColor, width: 0.5),
                  ),
                ),
              ),
              // Right vertical tick
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border.all(color: strokeColor, width: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
  bool _isDisposing = false;

  @override
  Ticker createTicker(TickerCallback onTick) {
    if (_isDisposing) {
      // Return a fake ticker that does nothing if we're disposing
      return Ticker((elapsed) {}, debugLabel: 'disposed-ticker');
    }
    return super.createTicker(onTick);
  }

  @override
  void dispose() {
    _isDisposing = true;
    print("OnlineMapView: Starting disposal");

    // Stop any ongoing animations in MapCubit before disposing the ticker provider
    try {
      final mapCubit = context.read<MapCubit>();
      mapCubit.stopAnimations();
    } catch (e) {
      print("OnlineMapView: Error stopping animations: $e");
    }

    // Ensure any remaining tickers are properly disposed
    super.dispose();
    print("OnlineMapView: Disposal completed");
  }

  double? _getZoomIfReady() {
    try {
      return widget.mapController.camera.zoom;
    } catch (_) {
      return null; // Camera not ready yet
    }
  }

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
            // Only show destination marker, not the vehicle (it's a fixed overlay now)
            MarkerLayer(
              markers: [
                if (widget.destination != null)
                  Marker(
                    point: widget.destination!,
                    rotate: false, // Keep marker upright on screen
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 30.0),
                  ),
              ],
            ),
          ],
        ),
        const VehicleIndicator(),
        Positioned(
          bottom: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NorthIndicator(orientation: widget.orientation),
              const SizedBox(height: 4),
              ScaleBar(
                zoom: _getZoomIfReady(),
                latitude: widget.position.latitude,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OfflineMapView extends StatefulWidget {
  final MapController mapController;
  final vtr.Theme theme;
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
  bool _isDisposing = false;

  @override
  Ticker createTicker(TickerCallback onTick) {
    if (_isDisposing) {
      // Return a fake ticker that does nothing if we're disposing
      return Ticker((elapsed) {}, debugLabel: 'disposed-ticker');
    }
    return super.createTicker(onTick);
  }

  @override
  void dispose() {
    _isDisposing = true;
    print("OfflineMapView: Starting disposal");

    // Stop any ongoing animations in MapCubit before disposing the ticker provider
    try {
      final mapCubit = context.read<MapCubit>();
      mapCubit.stopAnimations();
    } catch (e) {
      print("OfflineMapView: Error stopping animations: $e");
    }

    try {
      // Ensure any remaining tickers are properly disposed
      super.dispose();
      print("OfflineMapView: Disposal completed");
    } catch (e) {
      print("OfflineMapView: Error during dispose: $e");
    }
  }

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
        rotate: false, // Keep marker upright on screen
        child: const Icon(Icons.location_pin, color: Colors.red, size: 30.0),
      ));
    }
    return markers;
  }

  double? _getZoomIfReady() {
    try {
      return widget.mapController.camera.zoom;
    } catch (_) {
      return null; // Camera not ready yet
    }
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
            // Only show destination markers, not the vehicle (it's a fixed overlay now)
            MarkerLayer(markers: _routeMarkers()),
          ],
        ),
        const VehicleIndicator(),
        Positioned(
          bottom: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NorthIndicator(orientation: widget.orientation),
              const SizedBox(height: 4),
              ScaleBar(
                zoom: _getZoomIfReady(),
                latitude: widget.position.latitude,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
