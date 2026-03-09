import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/map_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../env_config.dart';
import '../widgets/map/map_view.dart';
import '../widgets/navigation/turn_by_turn_widget.dart';
import '../widgets/navigation/navigation_status_overlay.dart';
import '../widgets/status_bars/unified_bottom_status_bar.dart';
import '../widgets/status_bars/speed_center_widget.dart';
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/indicators/indicator_lights.dart';
import '../widgets/indicators/speed_limit_indicator.dart';
import '../cubits/mdb_cubits.dart';
import '../l10n/l10n.dart';
import '../state/enums.dart';
import '../state/gps.dart';
import '../state/vehicle.dart';
import 'navigation_setup_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);
    final MapCubit(:state) = context.watch<MapCubit>();
    final gpsData = GpsSync.watch(context);

    // No local maps: show the setup screen instead of a broken map
    if (state is MapUnavailable) {
      return const NavigationSetupScreen();
    }

    // No GPS fix yet: show waiting message instead of map (prevents tile requests at 0,0)
    if (state is MapOffline && gpsData.state != GpsState.fixEstablished) {
      return _buildWaitingForGps(context, theme);
    }

    return Container(
      width: EnvConfig.resolution.width,
      height: EnvConfig.resolution.height,
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

                // Out-of-coverage overlay (shown over the map when GPS is outside mbtiles bounds)
                if (state case MapOffline(:final isOutOfCoverage) when isOutOfCoverage)
                  _buildOutOfCoverageOverlay(context, theme),

                // Overlay content in Column layout (top to bottom)
                Column(
                  children: [
                    // Navigation info, if navigation is active (full width, flush to edges)
                    TurnByTurnWidget(),
                    const SizedBox(height: 8),

                    // Padded content below
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            // Blinker overlay (BELOW turn by turn)
                            const _MapBlinkerRow(),

                            // Free space (expand)
                            const Expanded(child: SizedBox()),

                            // Bottom row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Left side: warning indicators
                                const Expanded(
                                  child: _MapWarningIndicators(),
                                ),
                                // Center bottom: street name display
                                Flexible(
                                  flex: 2,
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
                    ),
                  ],
                ),

                // Navigation status overlay (GPS waiting, rerouting, arrival)
                // Positioned at top-center, floating above everything
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: NavigationStatusOverlay(),
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

  Widget _buildWaitingForGps(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final fgDim = isDark ? Colors.white60 : Colors.black54;

    return Container(
      width: EnvConfig.resolution.width,
      height: EnvConfig.resolution.height,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_not_fixed, size: 48, color: fgDim),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.mapWaitingForGps,
                    style: TextStyle(fontSize: 18, color: fg),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const UnifiedBottomStatusBar(centerWidget: SpeedCenterWidget()),
        ],
      ),
    );
  }

  Widget _buildOutOfCoverageOverlay(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.orange.withOpacity(0.6), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                context.l10n.mapOutOfCoverage,
                style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState mapState, ThemeData theme) {
    // Listen to NavigationState to get the route for drawing
    final navState = context.watch<NavigationCubit>().state;
    final positionNotifier = context.read<MapCubit>().positionNotifier;

    return switch (mapState) {
      MapLoading() => const Center(child: CircularProgressIndicator()),
      MapUnavailable() => const SizedBox.shrink(), // handled above in build()
      MapOnline(
        :final controller,
        :final onReady,
        :final orientation,
      ) =>
        OnlineMapView(
          mapController: controller,
          positionListenable: positionNotifier,
          mapReady: onReady,
          orientation: orientation,
          route: navState.route,
          destination: navState.destination,
        ),
      MapOffline(
        :final tiles,
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
          positionListenable: positionNotifier,
          mapReady: onReady,
          orientation: orientation,
          route: navState.route,
          destination: navState.destination,
        ),
    };
  }

  Widget _buildStreetNameDisplay(BuildContext context) {
    final roadName = context.select((NavigationCubit c) => c.state.currentStreetName);
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    if (roadName == null || roadName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Allow full width but constrain to screen width
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: RoadNameDisplay(
              textStyle: TextStyle(
                fontSize: 14,
                letterSpacing: roadName.length > 20 ? -0.5 : 0,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapBlinkerRow extends StatelessWidget {
  const _MapBlinkerRow();

  @override
  Widget build(BuildContext context) {
    final blinkerState = context.select((VehicleSync v) => v.state.blinkerState);
    final (theme, isDark) = context.select((ThemeCubit t) => (t.state.theme, t.state.isDark));
    final overlayActive = context.select((SettingsSync s) => s.state.blinkerOverlayEnabled);

    final showLeft = (blinkerState == BlinkerState.left || blinkerState == BlinkerState.both) &&
        !(overlayActive && blinkerState == BlinkerState.left);
    final showRight = (blinkerState == BlinkerState.right || blinkerState == BlinkerState.both) &&
        !(overlayActive && blinkerState == BlinkerState.right);

    // Need full VehicleData for IndicatorLights; read without subscribing again
    final vehicleState = context.read<VehicleSync>().state;

    return Row(
      children: [
        showLeft
            ? Container(
                key: ValueKey('map-left-$blinkerState'),
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
        const Expanded(child: SizedBox()),
        showRight
            ? Container(
                key: ValueKey('map-right-$blinkerState'),
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
}

class _MapWarningIndicators extends StatelessWidget {
  const _MapWarningIndicators();

  @override
  Widget build(BuildContext context) {
    final (isUnableToDrive, blinkerState, scooterState) =
        context.select((VehicleSync v) => (v.state.isUnableToDrive, v.state.blinkerState, v.state.state));
    final (theme, isDark) = context.select((ThemeCubit t) => (t.state.theme, t.state.isDark));

    if (isUnableToDrive != Toggle.on && blinkerState != BlinkerState.both && scooterState != ScooterState.parked) {
      return const SizedBox.shrink();
    }

    final vehicleState = context.read<VehicleSync>().state;

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
            if (isUnableToDrive == Toggle.on) ...[
              IndicatorLights.engineWarning(vehicleState),
              if (blinkerState == BlinkerState.both || scooterState == ScooterState.parked) const SizedBox(width: 8),
            ],
            if (blinkerState == BlinkerState.both) ...[
              IndicatorLights.hazards(vehicleState),
              if (scooterState == ScooterState.parked) const SizedBox(width: 8),
            ],
            if (scooterState == ScooterState.parked) IndicatorLights.parkingBrake(vehicleState),
          ],
        ),
      ),
    );
  }
}
