import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rbush/rbush.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' show TileProviders, VectorTileLayer;

import '../cubits/address_cubit.dart';
import '../cubits/map_cubit.dart';
import '../cubits/theme_cubit.dart';

import '../utils/theme_aware_cache.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> with SingleTickerProviderStateMixin {
  LatLng? _currentDestination;

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);
    final mapCubit = context.watch<MapCubit>();
    final addressCubit = context.watch<AddressCubit>();

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: _buildMap(context, mapCubit, addressCubit, theme),
    );
  }

  Widget _buildMap(BuildContext context, MapCubit map, AddressCubit address, ThemeData themeData) {
    final mapState = map.state;
    if (mapState is! MapOffline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                "The destination selector only works with offline maps",
                style: themeData.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please install the map data to use this feature',
                style: themeData.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final addressState = address.state;
    late final List<LatLng> addrs;
    switch (addressState) {
      case AddressStateLoading():
        return const Center(child: CircularProgressIndicator());
      case AddressStateError(:final message):
        return Center(child: Text(message));
      case AddressStateLoaded(:final addresses):
        addrs = addresses;
        break;
    }

    final MapOffline(:tiles, :position, :controller, :theme, :themeMode, :onReady, :orientation) = // Removed route, nextInstruction
        mapState;

    return FlutterMap(
      options: MapOptions(
        onMapReady: () {
          onReady?.call(this);
        },
        onSecondaryTap: (tapPosition, point) {
          print(point);
        },
        minZoom: 8,
        maxZoom: 20,
        initialCenter: position,
        initialZoom: 17,
      ),
      mapController: controller,
      children: [
        VectorTileLayer(
          theme: theme,
          tileProviders: TileProviders({
            // Use the provider directly from the state
            'versatiles-shortbread': tiles,
          }),
          maximumZoom: 20,
          fileCacheTtl: const Duration(seconds: 1),
          memoryTileCacheMaxSize: 0,
          memoryTileDataCacheMaxSize: 0,
          fileCacheMaximumSizeInBytes: 1024 * 1024,
          tileDelay: Duration.zero,
          cacheFolder: ThemeAwareCache.getCacheFolderProvider(themeMode),
        ),
        // MarkerClusterLayerWidget(
        //   options: MarkerClusterLayerOptions(
        //     maxZoom: 20,
        //     size: const Size(30, 30),
        //     markers: addresses.values
        //         .map(
        //           (address) => Marker(
        //             rotate: true,
        //             point: address.coordinates,
        //             child: GestureDetector(
        //               onTap: () {
        //                 setState(() {
        //                   _currentDestination = address;
        //                 });
        //               },
        //               child: const Icon(
        //                 Icons.location_pin,
        //                 size: 30.0,
        //               ),
        //             ),
        //           ),
        //         )
        //         .toList(),
        //     builder: (context, markers) {
        //       return Container(
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(20),
        //             color: Colors.blue),
        //         child: Center(
        //           child: Text(
        //             markers.length.toString(),
        //             style: const TextStyle(color: Colors.white, fontSize: 16),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        CameraFilteredMarkerLayer(
          minZoom: 17.5,
          markers: addrs
              .map((e) => Marker(
                    point: e,
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentDestination = e;
                          });
                        },
                        child: const Icon(Icons.location_pin)),
                  ))
              .toList(),
        ),
        if (_currentDestination != null)
          GestureDetector(
            onTap: () {
              setState(() {
                _currentDestination = null;
              });
            },
            child: ColoredBox(
              color: Colors.grey,
              child: Center(
                child: Text(
                  '${_currentDestination!.latitude.toStringAsFixed(5)}, ${_currentDestination!.longitude.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CameraFilteredMarkerLayer extends StatefulWidget {
  const CameraFilteredMarkerLayer({super.key, required this.markers, this.minZoom = 0});
  final List<Marker> markers;
  final double minZoom;

  @override
  State<CameraFilteredMarkerLayer> createState() => _CameraFilteredMarkerLayerState();
}

class _CameraFilteredMarkerLayerState extends State<CameraFilteredMarkerLayer> {
  final _bush = RBush<Marker>();

  @override
  void initState() {
    super.initState();

    for (final marker in widget.markers) {
      _bush.insert(RBushElement(
          data: marker,
          minX: marker.point.longitude,
          maxX: marker.point.longitude,
          minY: marker.point.latitude,
          maxY: marker.point.latitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCamera = MapCamera.maybeOf(context);
    if (mapCamera == null || mapCamera.zoom < widget.minZoom) {
      return const SizedBox.shrink();
    }

    final cameraBounds = mapCamera.visibleBounds;

    final markers = _bush.search(RBushBox(
      minX: cameraBounds.west,
      maxX: cameraBounds.east,
      minY: cameraBounds.south,
      maxY: cameraBounds.north,
    ));

    return MarkerLayer(
      markers: markers.map((e) => e.data).toList(),
    );
  }
}
