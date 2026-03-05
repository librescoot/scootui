import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../state/battery.dart';
import '../../state/enums.dart';
import '../../state/vehicle.dart';
import '../indicators/indicator_lights.dart';
import '../power/power_display.dart';

/// Bottom bar for cluster and CarPlay screens.
/// Shows telltale warning indicators or power display, switching via AnimatedSwitcher.
class ClusterBottomBar extends StatelessWidget {
  const ClusterBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);
    final battery0 = Battery0Sync.watch(context);
    final battery1 = Battery1Sync.watch(context);

    final showEngineWarning = vehicleState.isUnableToDrive == Toggle.on;
    final showHazards = vehicleState.blinkerState == BlinkerState.both;
    final showParking = vehicleState.state == ScooterState.parked;
    final showBatteryFault = (battery0.present && battery0.fault.isNotEmpty) ||
        (battery1.present && battery1.fault.isNotEmpty);
    final hasTelltales =
        showEngineWarning || showHazards || showParking || showBatteryFault;

    return SizedBox(
      height: 60,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: hasTelltales
            ? Center(
                key: const ValueKey('telltales'),
                child: _WarningIndicators(
                  vehicleState: vehicleState,
                  battery0: battery0,
                  battery1: battery1,
                  showEngineWarning: showEngineWarning,
                  showHazards: showHazards,
                  showParking: showParking,
                  showBatteryFault: showBatteryFault,
                ),
              )
            : SizedBox(
                key: const ValueKey('power'),
                width: 200,
                child: _PowerRow(),
              ),
      ),
    );
  }
}

class _WarningIndicators extends StatelessWidget {
  final VehicleData vehicleState;
  final BatteryData battery0;
  final BatteryData battery1;
  final bool showEngineWarning;
  final bool showHazards;
  final bool showParking;
  final bool showBatteryFault;

  const _WarningIndicators({
    required this.vehicleState,
    required this.battery0,
    required this.battery1,
    required this.showEngineWarning,
    required this.showHazards,
    required this.showParking,
    required this.showBatteryFault,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _PowerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final (powerOutput, motorCurrent) =
        EngineSync.select(context, (data) => (data.powerOutput, data.motorCurrent));
    final settings = SettingsSync.watch(context);
    return PowerDisplay(
      powerOutput: powerOutput,
      motorCurrent: motorCurrent.toDouble(),
      displayMode: settings.powerDisplayMode,
    );
  }
}
