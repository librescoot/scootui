import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/map_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../widgets/map/map_overlay_indicators.dart';
import '../widgets/map/map_view.dart';
import '../widgets/navigation/turn_by_turn_widget.dart';
import '../widgets/status_bars/unified_bottom_status_bar.dart';
import '../widgets/status_bars/speed_center_widget.dart';
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/indicators/indicator_lights.dart';
import '../widgets/indicators/speed_limit_indicator.dart';
import '../cubits/mdb_cubits.dart';
import '../state/enums.dart';
import '../state/vehicle.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);
    final MapCubit(:state) = context.watch<MapCubit>();

    return Container(
      width: 480,
      height: 480,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Top status bar (fixed height)
          StatusBar(),

          // Map widget (expand to fit available space)
          Expanded(
            child: Stack(
              children: [
                // Map fills entire area as background
                _buildMap(context, state, theme),
                
                // Overlay content in Column layout (top to bottom)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Navigation info, if navigation is active
                      TurnByTurnWidget(),
                      
                      // 8px spacing
                      const SizedBox(height: 8),
                      
                      // Blinker overlay (BELOW turn by turn)
                      _buildBlinkerRow(context),
                      
                      // Free space (expand)
                      const Expanded(child: SizedBox()),
                      
                      // Bottom row
                      Row(
                        children: [
                          // Left side: warning indicators
                          Expanded(
                            child: _buildWarningIndicators(context),
                          ),
                          // Center bottom: street name display if available
                          Expanded(
                            child: _buildStreetNameDisplay(context),
                          ),
                          // Right side: north indicator space (map renders it)
                          const Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom status bar (shrink to content)
          const UnifiedBottomStatusBar(
            centerWidget: SpeedCenterWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState mapState, ThemeData theme) {
    // Listen to NavigationState to get the route for drawing
    final navState = context.watch<NavigationCubit>().state;

    return switch (mapState) {
      MapLoading() => const Center(child: CircularProgressIndicator()),
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
      MapOnline(
        :final position,
        :final controller,
        :final onReady,
        :final orientation,
      ) =>
        OnlineMapView(
          mapController: controller,
          position: position,
          mapReady: onReady,
          orientation: orientation,
          route: navState.route, // Pass route from NavigationCubit
          destination: navState.destination, // Pass destination from NavigationCubit
        ),
      MapOffline(
        :final tiles,
        :final position,
        :final controller,
        :final theme,
        :final themeMode,
        :final renderMode,
        :final onReady,
        :final orientation,
      ) =>
        OfflineMapView(
          tiles: tiles,
          mapController: controller,
          theme: theme,
          themeMode: themeMode,
          renderMode: renderMode,
          position: position,
          mapReady: onReady,
          orientation: orientation,
          route: navState.route, // Pass route from NavigationCubit
          destination: navState.destination, // Pass destination from NavigationCubit
        ),
    };
  }

  Widget _buildBlinkerRow(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);
    
    return Row(
      children: [
        // Left blinker
        (vehicleState.blinkerState == BlinkerState.left || vehicleState.blinkerState == BlinkerState.both)
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: 0.8,
                  child: IndicatorLights.leftBlinker(vehicleState),
                ),
              ),
            )
          : const SizedBox(width: 56),
        
        // Spacer
        const Expanded(child: SizedBox()),
        
        // Right blinker
        (vehicleState.blinkerState == BlinkerState.right || vehicleState.blinkerState == BlinkerState.both)
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: 0.8,
                  child: IndicatorLights.rightBlinker(vehicleState),
                ),
              ),
            )
          : const SizedBox(width: 56),
      ],
    );
  }

  Widget _buildWarningIndicators(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);
    
    if (vehicleState.isUnableToDrive != Toggle.on && 
        vehicleState.blinkerState != BlinkerState.both && 
        vehicleState.state != ScooterState.parked) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vehicleState.isUnableToDrive == Toggle.on) ...[
              IndicatorLights.engineWarning(vehicleState),
              if (vehicleState.blinkerState == BlinkerState.both || vehicleState.state == ScooterState.parked)
                const SizedBox(width: 8),
            ],
            if (vehicleState.blinkerState == BlinkerState.both) ...[
              IndicatorLights.hazards(vehicleState),
              if (vehicleState.state == ScooterState.parked)
                const SizedBox(width: 8),
            ],
            if (vehicleState.state == ScooterState.parked)
              IndicatorLights.parkingBrake(vehicleState),
          ],
        ),
      ),
    );
  }

  Widget _buildStreetNameDisplay(BuildContext context) {
    final speedLimitData = SpeedLimitSync.watch(context);
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);
    
    if (speedLimitData.roadName.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: RoadNameDisplay(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
