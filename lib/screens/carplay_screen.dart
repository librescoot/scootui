import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/carplay_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../env_config.dart';
import '../widgets/carplay/carplay_video_widget.dart';
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/status_bars/unified_bottom_status_bar.dart';
import '../widgets/indicators/indicator_lights.dart';
import '../widgets/power/power_display.dart';
import '../state/enums.dart';
import '../state/vehicle.dart';
import '../state/battery.dart';
import '../cubits/mdb_cubits.dart';

class CarPlayScreen extends StatefulWidget {
  const CarPlayScreen({super.key});

  @override
  State<CarPlayScreen> createState() => _CarPlayScreenState();
}

class _CarPlayScreenState extends State<CarPlayScreen> {
  // Track blinker state to force animation restart on changes
  BlinkerState? _previousBlinkerState;
  Key _leftBlinkerKey = UniqueKey();
  Key _rightBlinkerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Auto-connect to CarPlay backend on screen init
    context.read<CarPlayCubit>().connect();
  }

  Widget _buildLeftBlinker(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);

    // Check if blinker state has changed and restart animations if needed
    if (_previousBlinkerState != vehicleState.blinkerState) {
      _previousBlinkerState = vehicleState.blinkerState;
      _leftBlinkerKey = UniqueKey();
      _rightBlinkerKey = UniqueKey();
    }

    return (vehicleState.blinkerState == BlinkerState.left ||
            vehicleState.blinkerState == BlinkerState.both)
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

    return (vehicleState.blinkerState == BlinkerState.right ||
            vehicleState.blinkerState == BlinkerState.both)
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

  Widget _buildWarningIndicators(BuildContext context, dynamic vehicleState,
      ThemeData theme, bool isDark) {
    final battery0 = Battery0Sync.watch(context);
    final battery1 = Battery1Sync.watch(context);

    final showEngineWarning = vehicleState.isUnableToDrive == Toggle.on;
    final showHazards = vehicleState.blinkerState == BlinkerState.both;
    final showParking = vehicleState.state == ScooterState.parked;
    final showBatteryFault = (battery0.present && battery0.fault.isNotEmpty) ||
        (battery1.present && battery1.fault.isNotEmpty);

    if (!showEngineWarning &&
        !showHazards &&
        !showParking &&
        !showBatteryFault) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEngineWarning) ...[
          IndicatorLights.engineWarning(vehicleState),
          if (showHazards || showParking || showBatteryFault)
            const SizedBox(width: 8),
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
    final showBatteryFault = (battery0.present && battery0.fault.isNotEmpty) ||
        (battery1.present && battery1.fault.isNotEmpty);

    return vehicleState.isUnableToDrive == Toggle.on ||
        vehicleState.blinkerState == BlinkerState.both ||
        vehicleState.state == ScooterState.parked ||
        showBatteryFault;
  }

  Widget _buildBottomRow(BuildContext context, dynamic vehicleState,
      ThemeData theme, bool isDark, double powerOutput, num motorCurrent, dynamic settings) {
    final hasTelltales = _hasTelltales(context, vehicleState);

    return SizedBox(
      height: 60,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: hasTelltales
            ? Center(
                key: const ValueKey('telltales'),
                child: _buildWarningIndicators(
                    context, vehicleState, theme, isDark),
              )
            : SizedBox(
                key: const ValueKey('power'),
                width: 200,
                child: PowerDisplay(
                  powerOutput: powerOutput,
                  motorCurrent: motorCurrent.toDouble(),
                  displayMode: settings.powerDisplayMode,
                ),
              ),
      ),
    );
  }

  Widget _buildCarPlayContent(BuildContext context, CarPlayState state) {
    return switch (state) {
      CarPlayDisconnected() => _buildStatusMessage(
          context,
          'Disconnected from CarPlay',
          'Connecting to localhost:8001...',
          icon: Icons.link_off,
        ),
      CarPlayConnecting() => _buildStatusMessage(
          context,
          'Connecting to CarPlay...',
          'Initializing MJPEG stream',
          showSpinner: true,
        ),
      CarPlayConnected() => const CarPlayVideoWidget(),
      CarPlayError(:final message) => _buildErrorMessage(context, message),
    };
  }

  Widget _buildStatusMessage(
    BuildContext context,
    String title,
    String subtitle, {
    IconData? icon,
    bool showSpinner = false,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner)
            const CircularProgressIndicator()
          else if (icon != null)
            Icon(icon, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'CarPlay Connection Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CarPlayCubit>().retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);
    final vehicleState = VehicleSync.watch(context);
    final (powerOutput, motorCurrent) = EngineSync.select(context, (data) => (data.powerOutput, data.motorCurrent));
    final settings = SettingsSync.watch(context);

    return Container(
      width: EnvConfig.resolution.width,
      height: EnvConfig.resolution.height,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Top status bar
          StatusBar(),

          // Main CarPlay area
          Expanded(
            child: Stack(
              children: [
                // CarPlay video or status messages
                BlocBuilder<CarPlayCubit, CarPlayState>(
                  builder: (context, state) {
                    return _buildCarPlayContent(context, state);
                  },
                ),

                // Overlay content (blinkers and indicators)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Blinker row
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

                      // Free space
                      const Expanded(child: SizedBox()),

                      // Bottom row with telltales or power display
                      _buildBottomRow(context, vehicleState, theme, isDark, powerOutput, motorCurrent, settings),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom status bar
          const UnifiedBottomStatusBar(),
        ],
      ),
    );
  }
}
