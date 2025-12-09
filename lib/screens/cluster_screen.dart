import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../cubits/debug_overlay_cubit.dart';
import '../cubits/mdb_cubits.dart';
import '../cubits/theme_cubit.dart';
import '../env_config.dart';
import '../widgets/debug/debug_overlay.dart';
import '../widgets/navigation/turn_by_turn_widget.dart';
import '../widgets/power/power_display.dart';
import '../widgets/speedometer/speedometer_display.dart';
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/status_bars/unified_bottom_status_bar.dart';
import '../widgets/indicators/indicator_lights.dart';
import '../state/auto_standby.dart';
import '../state/enums.dart';
import '../state/vehicle.dart';
import '../cubits/navigation_cubit.dart';
import '../cubits/navigation_state.dart';

enum ViewMode {
  dashboard,
  map,
}

class ClusterScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeSwitch;
  final Function()? onResetTrip;

  const ClusterScreen({
    super.key,
    this.onThemeSwitch,
    this.onResetTrip,
  });

  @override
  State<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends State<ClusterScreen> {
  String? _errorMessage;

  // Track blinker state to force animation restart on changes
  BlinkerState? _previousBlinkerState;
  Key _leftBlinkerKey = UniqueKey();
  Key _rightBlinkerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _printDocumentsDirectory();
  }

  Future<void> _printDocumentsDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      print('ClusterScreen - Application Documents Directory: ${appDir.path}');
      final mapPath = '${appDir.path}/maps/map.mbtiles';
      print('ClusterScreen - MBTiles path: $mapPath');
    } catch (e) {
      print('ClusterScreen - Error getting documents directory: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildLeftBlinker(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);

    // Check if blinker state has changed and restart animations if needed
    if (_previousBlinkerState != vehicleState.blinkerState) {
      _previousBlinkerState = vehicleState.blinkerState;
      _leftBlinkerKey = UniqueKey(); // Force widget rebuild with new animations
      _rightBlinkerKey = UniqueKey(); // Force widget rebuild with new animations
    }

    return (vehicleState.blinkerState == BlinkerState.left || vehicleState.blinkerState == BlinkerState.both)
        ? SizedBox(
            key: _leftBlinkerKey,
            width: 56,
            height: 56,
            child: Center(
              child: Transform.scale(
                scale: 0.8,
                child: IndicatorLights.leftBlinker(vehicleState),
              ),
            ),
          )
        : const SizedBox(width: 56);
  }

  Widget _buildRightBlinker(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);

    return (vehicleState.blinkerState == BlinkerState.right || vehicleState.blinkerState == BlinkerState.both)
        ? SizedBox(
            key: _rightBlinkerKey,
            width: 56,
            height: 56,
            child: Center(
              child: Transform.scale(
                scale: 0.8,
                child: IndicatorLights.rightBlinker(vehicleState),
              ),
            ),
          )
        : const SizedBox(width: 56);
  }

  Widget _buildWarningIndicators(BuildContext context, dynamic vehicleState, ThemeData theme, bool isDark) {
    final battery0 = Battery0Sync.watch(context);
    final battery1 = Battery1Sync.watch(context);

    final showEngineWarning = vehicleState.isUnableToDrive == Toggle.on;
    final showHazards = vehicleState.blinkerState == BlinkerState.both;
    final showParking = vehicleState.state == ScooterState.parked;
    final showBatteryFault =
        (battery0.present && battery0.fault.isNotEmpty) || (battery1.present && battery1.fault.isNotEmpty);

    if (!showEngineWarning && !showHazards && !showParking && !showBatteryFault) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEngineWarning) ...[
          IndicatorLights.engineWarning(vehicleState),
          if (showHazards || showParking || showBatteryFault) const SizedBox(width: 8),
        ],
        if (showHazards) ...[
          IndicatorLights.hazards(vehicleState),
          if (showParking || showBatteryFault) const SizedBox(width: 8),
        ],
        if (showParking) ...[
          IndicatorLights.parkingBrake(vehicleState),
          if (showBatteryFault) const SizedBox(width: 8),
        ],
        if (showBatteryFault) IndicatorLights.batteryFault(battery0, battery1),
      ],
    );
  }

  bool _hasTelltales(BuildContext context, dynamic vehicleState) {
    final battery0 = Battery0Sync.watch(context);
    final battery1 = Battery1Sync.watch(context);
    final showBatteryFault =
        (battery0.present && battery0.fault.isNotEmpty) || (battery1.present && battery1.fault.isNotEmpty);

    return vehicleState.isUnableToDrive == Toggle.on ||
        vehicleState.blinkerState == BlinkerState.both ||
        vehicleState.state == ScooterState.parked ||
        showBatteryFault;
  }

  Widget _buildBottomRow(BuildContext context, dynamic vehicleState, ThemeData theme, bool isDark, double powerOutput) {
    final hasTelltales = _hasTelltales(context, vehicleState);

    return SizedBox(
      height: 60, // Fixed height to prevent jitter
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: hasTelltales
            ? Center(
                key: const ValueKey('telltales'),
                child: _buildWarningIndicators(context, vehicleState, theme, isDark),
              )
            : SizedBox(
                key: const ValueKey('power'),
                width: 200, // Fixed width to constrain PowerDisplay
                child: PowerDisplay(
                  powerOutput: powerOutput / 1000,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    final (odometer, powerOutput) = EngineSync.select(context, (data) => (data.odometer, data.powerOutput));

    return Container(
      width: EnvConfig.resolution.width,
      height: EnvConfig.resolution.height,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Top status bar (fixed height)
          StatusBar(),

          // Main speedometer area (expand to fit available space)
          Expanded(
            child: Stack(
              children: [
                // Speedometer fills entire area as background
                RepaintBoundary(child: SpeedometerDisplay()),

                // Overlay content in Column layout (top to bottom)
                Column(
                  children: [
                    // Turn-by-turn navigation (top priority, no padding)
                    TurnByTurnWidget(),

                    // Conditional spacing (only if turn-by-turn is active)
                    BlocBuilder<NavigationCubit, NavigationState>(
                      builder: (context, navState) {
                        final hasNavContent = (navState.status == NavigationStatus.idle &&
                                navState.hasDestination &&
                                navState.hasPendingConditions) ||
                            (navState.hasInstructions && navState.status != NavigationStatus.idle) ||
                            navState.status == NavigationStatus.arrived;

                        return hasNavContent ? const SizedBox(height: 8) : const SizedBox.shrink();
                      },
                    ),

                    // Blinker row and remaining content (with padding)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            // Blinker row (below turn-by-turn)
                            Row(
                              children: [
                                // Left blinker
                                _buildLeftBlinker(context),

                                // Spacer
                                const Expanded(child: SizedBox()),

                                // Right blinker
                                _buildRightBlinker(context),
                              ],
                            ),

                            // Free space (expand)
                            const Expanded(child: SizedBox()),

                            // Bottom row with telltales or power display
                            _buildBottomRow(context, VehicleSync.watch(context), theme, isDark, powerOutput),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Error message overlay
                if (_errorMessage != null)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.red.withOpacity(0.8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Auto-standby warning overlay
                BlocBuilder<AutoStandbySync, AutoStandbyData>(
                  builder: (context, autoStandby) {
                    final remaining = autoStandby.autoStandbyRemaining;
                    if (remaining > 0 && remaining <= 30) {
                      return Positioned(
                        top: 80,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Vehicle will enter standby in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$remaining',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'seconds',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Press brake or move kickstand to cancel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Debug overlay - controlled by DebugOverlayCubit
                BlocBuilder<DebugOverlayCubit, DebugMode>(
                  builder: (context, debugMode) {
                    // Only show overlay if mode is set to overlay
                    if (debugMode == DebugMode.overlay) {
                      return const DebugOverlay();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),

          // Bottom status bar (shrink to content)
          const UnifiedBottomStatusBar(),
        ],
      ),
    );
  }
}
