import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart'
    show TileProviders, VectorTileLayer;

import '../cubits/map_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../utils/theme_aware_cache.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);
    final mapCubit = context.watch<MapCubit>();

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: _buildMap(context, mapCubit, theme),
    );
  }

  Widget _buildMap(BuildContext context, MapCubit map, ThemeData themeData) {
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

    final MapOffline(
      :tiles,
      :position,
      :controller,
      :theme,
      :themeMode,
      :onReady
    ) = mapState;

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
      ],
    );
  }
}
