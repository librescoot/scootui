import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:scooter_cluster/cubits/theme_cubit.dart';
import 'package:scooter_cluster/map/coordinate_utils.dart';
import 'package:scooter_cluster/widgets/map/map_painter.dart';
import 'package:scooter_cluster/map/map_viewport_state.dart';
import 'package:scooter_cluster/map/map_draw_command.dart';
import 'package:scooter_cluster/map/tile_provider.dart';
import 'package:scooter_cluster/repositories/tiles_repository.dart';
import 'package:scooter_cluster/widgets/map/vehicle_marker.dart';
import 'package:scooter_cluster/map/display_tile.dart';
import 'package:scooter_cluster/routing/models.dart' as routing;
import 'package:scooter_cluster/map/map_calculator.dart';

class CustomMapView extends StatefulWidget {
  final LatLng position;
  final double orientation;
  final routing.Route? route;
  final LatLng? destination;

  const CustomMapView({
    super.key,
    required this.position,
    required this.orientation,
    this.route,
    this.destination,
  });

  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView> {
  late MapViewportState _viewportState;
  List<LatLng> _routePoints = [];

  TileProvider? _tileProvider;
  Map<math.Point<int>, DisplayTile> _tileCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewportState = MapViewportState(
      center: widget.position,
      zoom: 14, // Default zoom level
      rotation: widget.orientation,
    );
    _initTileProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVisibleTiles();
  }

  @override
  void didUpdateWidget(CustomMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.route != oldWidget.route) {
      setState(() {
        _routePoints = widget.route?.waypoints ?? [];
      });
    }

    const distance = Distance();
    final posChanged =
        distance(oldWidget.position, widget.position) > 0.1; // 10cm threshold
    final rotChanged = (oldWidget.orientation - widget.orientation).abs() > 0.1;

    if (posChanged || rotChanged) {
      setState(() {
        _viewportState = MapViewportState(
          center: widget.position,
          zoom: _viewportState.zoom,
          rotation: widget.orientation,
        );
      });

      final oldTile = CoordinateUtils.geoToTile(
          oldWidget.position, _viewportState.zoom.round());
      final newTile = CoordinateUtils.geoToTile(
          widget.position, _viewportState.zoom.round());
      if (oldTile != newTile) {
        _loadVisibleTiles();
      }
    }
  }

  Future<void> _initTileProvider() async {
    final tilesRepo = context.read<TilesRepository>();
    final result = await tilesRepo.getMbTiles();

    if (!mounted) return;

    switch (result) {
      case Success(:final mbTiles):
        _tileProvider = TileProvider(mbtiles: mbTiles);
        _loadVisibleTiles();
        break;
      case NotFound():
        // Handle error
        break;
      case Error(:final message):
        // Handle error
        break;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _loadVisibleTiles() {
    if (_tileProvider == null || !mounted) return;

    final size = MediaQuery.of(context).size;
    final zoom = _viewportState.zoom;
    final zoomInt =
        zoom.round(); // Use round() instead of toInt() for stability

    // Clamp the zoom to the max supported by the tile provider for tile fetching
    final tileZoom = zoom.clamp(0, _tileProvider!.maxZoom).toInt();

    final centerTile =
        CoordinateUtils.geoToTile(_viewportState.center, zoomInt);

    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        final tileX = centerTile.x + x;
        final tileY = centerTile.y + y;
        final tilePoint = math.Point(tileX, tileY);

        if (!_tileCache.containsKey(tilePoint)) {
          // Placeholder to prevent multiple requests
          _tileCache[tilePoint] =
              DisplayTile(z: tileZoom, x: tileX, y: tileY, commands: []);

          _tileProvider!.getTile(tileZoom, tileX, tileY).then((tile) {
            if (mounted && tile != null) {
              setState(() {
                _tileCache[tilePoint] = tile;
              });
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final calculator = MapCalculator(_viewportState);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, theme) {
        return ClipRect(
          child: Stack(
            children: [
              CustomPaint(
                painter: MapPainter(
                  tiles: _tileCache,
                  calculator: calculator,
                  route: _routePoints,
                  isDarkTheme: theme.isDark,
                ),
                child: const SizedBox.expand(),
              ),
              const Center(
                child: VehicleMarker(),
              ),
            ],
          ),
        );
      },
    );
  }
}
