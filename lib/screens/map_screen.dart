import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/map_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../widgets/map/map_view.dart';
import '../widgets/status_bars/map_bottom_status_bar.dart';
import '../widgets/status_bars/top_status_bar.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);

    return Container(
      width: 480,
      height: 480,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Top status bar
          StatusBar(),

          // Map view
          Expanded(
            child: _buildMap(context, context.watch<MapCubit>().state, theme),
          ),

          // Bottom status bar with speed
          MapBottomStatusBar(),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState mapState, ThemeData theme) =>
      switch (mapState) {
        MapInitial() ||
        MapLoading() =>
          const Center(child: CircularProgressIndicator()),
        MapUnavailable(:final error) => Center(
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
                    error,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please install the map data to use this feature',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        MapLoaded(
          :final mbTiles,
          :final position,
          :final controller,
          :final theme,
          :final onReady,
          :final orientation,
        ) =>
          MapView(
            mbTiles: mbTiles,
            mapController: controller,
            theme: theme,
            position: position,
            mapReady: onReady,
            orientation: orientation,
          ),
      };
}
