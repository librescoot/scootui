import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/dashboard_cubit.dart';
import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../repositories/mdb_repository.dart';
import '../../state/enums.dart';
import '../../state/gps.dart';
import '../../state/vehicle.dart';

class DebugOverlay extends StatefulWidget {
  const DebugOverlay({super.key});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  // Additional Redis data
  Map<String, String> _auxBatteryData = {};
  Map<String, String> _cbBatteryData = {};

  @override
  void initState() {
    super.initState();
    _loadAdditionalData();
  }

  Future<void> _loadAdditionalData() async {
    final mdbRepository = context.read<MDBRepository>();

    // Fetch aux-battery and cb-battery data from Redis
    _auxBatteryData = await _getRedisData(mdbRepository, 'aux-battery');
    _cbBatteryData = await _getRedisData(mdbRepository, 'cb-battery');

    if (mounted) {
      setState(() {});
    }
  }

  Future<Map<String, String>> _getRedisData(MDBRepository repository, String key) async {
    try {
      final data = await repository.getAll(key);
      return Map.fromEntries(data.map((entry) => MapEntry(entry.$1, entry.$2)));
    } catch (e) {
      print('Error loading $key data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCubit.watch(context).isDark;
    final vehicle = VehicleSync.watch(context);
    final engine = EngineSync.watch(context);
    final battery0 = Battery0Sync.watch(context);
    final battery1 = Battery1Sync.watch(context);
    final gps = GpsSync.watch(context);
    final internet = InternetSync.watch(context);
    final dashboardData = DashboardSyncCubit.watch(context);

    final panelBackgroundColor = isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6);
    final borderColor = isDark ? Colors.white30 : Colors.black26;
    final textColor = isDark ? Colors.white : Colors.black;

    return Stack(
      children: [
        Positioned(
          top: 120,
          left: 0,
          right: 0,
          child: Center(
            child: _buildDebugPanel(
              context,
              content: Text(
                vehicle.stateRaw,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: panelBackgroundColor,
              borderColor: _getStateColor(vehicle.state),
              textColor: textColor,
              isCentered: true,
            ),
          ),
        ),

        // Condensed blinker and brake indicators on left and right
        // Left side
        Positioned(
          top: 10,
          left: 60,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('BLINK',
                    '${vehicle.blinkerSwitch.toString().split('.').last}/${vehicle.blinkerState.toString().split('.').last}'),
                _buildDataPoint('BRAKE', vehicle.brakeLeft.toString().split('.').last),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: borderColor,
            textColor: textColor,
          ),
        ),

        // Right side
        Positioned(
          top: 10,
          right: 60,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('BLINK',
                    '${vehicle.blinkerSwitch.toString().split('.').last}/${vehicle.blinkerState.toString().split('.').last}'),
                _buildDataPoint('BRAKE', vehicle.brakeRight.toString().split('.').last),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: borderColor,
            textColor: textColor,
            alignRight: true,
          ),
        ),

        // Engine info moved to the side to avoid cluttering the speed display
        Positioned(
          top: 260,
          left: 10,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('THR', engine.throttle.toString().split('.').last),
                _buildDataPoint('RPM', engine.rpm.toStringAsFixed(0)),
                _buildDataPoint('PWR', '${engine.powerOutput.toStringAsFixed(0)} W'),
                _buildDataPoint('EBS', engine.kers.toString().split('.').last),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: engine.powerState == Toggle.on ? Colors.blue : borderColor,
            textColor: textColor,
          ),
        ),

        // GPS on left - without icon
        Positioned(
          top: 60,
          left: 10,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('GPS', gps.state.toString().split('.').last),
                _buildDataPoint('LAT', gps.latitude.toStringAsFixed(5)),
                _buildDataPoint('LON', gps.longitude.toStringAsFixed(5)),
                _buildDataPoint('SPD', '${gps.speed.toStringAsFixed(1)} km/h'),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: _getGpsStateColor(gps.state),
            textColor: textColor,
          ),
        ),

        // Internet on right
        Positioned(
          top: 60,
          right: 10,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('MODEM', internet.modemState.toString().split('.').last),
                _buildDataPoint('CLOUD', internet.unuCloud.toString().split('.').last),
                _buildDataPoint('SIGNAL', '${internet.signalQuality}%'),
                _buildDataPoint('TECH', internet.accessTech),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: internet.status == ConnectionStatus.connected ? Colors.blue : borderColor,
            textColor: textColor,
            alignRight: true,
          ),
        ),

        // Batteries positioned between TRIP and TOTAL in a 2x2 grid
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Main batteries
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Battery 0 - simplified
                    battery0.present
                        ? _buildSimpleBatteryPanel(
                            context,
                            'B0',
                            battery0.charge,
                            '${(battery0.voltage / 1000).toStringAsFixed(1)}V',
                            '${(battery0.current / 1000).toStringAsFixed(1)}A',
                            battery0.state.toString().split('.').last,
                            battery0.cycleCount.toString(),
                            battery0.firmwareVersion,
                            panelBackgroundColor,
                            borderColor,
                            textColor,
                          )
                        : _buildNonPresentBatteryPanel(
                            context,
                            'B0: --',
                            panelBackgroundColor,
                            borderColor,
                            textColor,
                          ),

                    const SizedBox(width: 10),

                    // Battery 1 - simplified
                    battery1.present
                        ? _buildSimpleBatteryPanel(
                            context,
                            'B1',
                            battery1.charge,
                            '${(battery1.voltage / 1000).toStringAsFixed(1)}V',
                            '${(battery1.current / 1000).toStringAsFixed(1)}A',
                            battery1.state.toString().split('.').last,
                            battery1.cycleCount.toString(),
                            battery1.firmwareVersion,
                            panelBackgroundColor,
                            borderColor,
                            textColor,
                          )
                        : _buildNonPresentBatteryPanel(
                            context,
                            'B1: --',
                            panelBackgroundColor,
                            borderColor,
                            textColor,
                          ),
                  ],
                ),

                const SizedBox(height: 4),

                // Bottom row: Auxiliary batteries with fixed layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CB battery with specified layout
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: panelBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First line: CBB 98% 4.18V -35.94µA
                          Text(
                            "CBB ${_cbBatteryData['charge'] ?? '0'}% ${_cbBatteryData['cell-voltage'] != null ? '${((int.tryParse(_cbBatteryData['cell-voltage'] ?? '0') ?? 0) / 1000000).toStringAsFixed(2)}V' : ''} ${_cbBatteryData['current'] != null ? '${((int.tryParse(_cbBatteryData['current'] ?? '0') ?? 0) / 1000).toStringAsFixed(2)}mA' : ''}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          // Second line: not-charging / SoH 92%
                          Text(
                            "${_cbBatteryData['charge-status'] ?? 'unknown'} / SoH ${_cbBatteryData['state-of-health'] ?? '0'}%",
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // AUX battery with specified layout
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: panelBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // First line: AUX 50% 12.2V
                          Text(
                            "AUX ${_auxBatteryData['charge'] ?? '0'}% ${((int.tryParse(_auxBatteryData['voltage'] ?? '0') ?? 0) / 1000).toStringAsFixed(1)}V",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          // Second line: float-charge
                          Text(
                            _auxBatteryData['charge-status'] ?? 'unknown',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Motor details moved to the right side
        Positioned(
          top: 260,
          right: 10,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('MOTOR V', '${(engine.motorVoltage / 1000).toStringAsFixed(1)} V'),
                _buildDataPoint('MOTOR I', '${(engine.motorCurrent / 1000).toStringAsFixed(1)} A'),
                _buildDataPoint('TEMP', '${engine.temperature.toStringAsFixed(1)}°C'),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: borderColor,
            textColor: textColor,
            alignRight: true,
          ),
        ),

        // Dashboard Info Panel
        Positioned(
          top: 180, // Adjust position as needed
          left: 10,
          child: _buildDebugPanel(
            context,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataPoint('BRI', '${dashboardData.brightness?.toStringAsFixed(1) ?? "N/A"} lx'),
                _buildDataPoint('BLT', dashboardData.backlight?.toString() ?? 'N/A'),
                _buildDataPoint('THM', dashboardData.theme ?? 'N/A'),
              ],
            ),
            backgroundColor: panelBackgroundColor,
            borderColor: borderColor,
            textColor: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugPanel(
    BuildContext context, {
    required Widget content,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    Widget? icon,
    bool isCentered = false,
    bool alignRight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isCentered ? MainAxisAlignment.center : (alignRight ? MainAxisAlignment.end : MainAxisAlignment.start),
        children: [
          if (icon != null && !alignRight) ...[
            icon,
            const SizedBox(width: 8),
          ],
          Flexible(child: content),
          if (icon != null && alignRight) ...[
            const SizedBox(width: 8),
            icon,
          ],
        ],
      ),
    );
  }

  Widget _buildDataPoint(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getBatteryChargeColor(int charge) {
    if (charge > 70) {
      return Colors.green;
    } else if (charge > 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getStateColor(ScooterState state) {
    return switch (state) {
      ScooterState.readyToDrive => Colors.green,
      ScooterState.standBy => Colors.blue,
      ScooterState.parked => Colors.orange,
      ScooterState.off => Colors.grey,
      ScooterState.booting => Colors.purple,
      ScooterState.shuttingDown => Colors.red,
      ScooterState.hibernating => Colors.indigo,
      ScooterState.hibernatingImminent => Colors.pink,
      ScooterState.suspending => Colors.red,
      ScooterState.suspendingImminent => Colors.pink,
      ScooterState.updating => Colors.yellow,
      ScooterState.waitingHibernation => Colors.deepPurple,
      ScooterState.waitingHibernationAdvanced => Colors.deepPurple[700]!,
      ScooterState.waitingHibernationSeatbox => Colors.purple,
      ScooterState.waitingHibernationConfirm => Colors.deepPurple[900]!,
    };
  }

  Color _getGpsStateColor(GpsState state) {
    return switch (state) {
      GpsState.off => Colors.grey,
      GpsState.searching => Colors.yellow,
      GpsState.fixEstablished => Colors.green,
      GpsState.error => Colors.red,
    };
  }

  // Simple battery panel for present batteries
  Widget _buildSimpleBatteryPanel(
    BuildContext context,
    String title,
    int charge,
    String voltage,
    String current,
    String state,
    String cycleCount,
    String fwVersion,
    Color backgroundColor,
    Color borderColor,
    Color textColor,
  ) {
    Color chargeColor = _getBatteryChargeColor(charge);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chargeColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // First line: title, charge, voltage, current
          Text(
            "$title: $charge% $voltage $current",
            style: TextStyle(
              color: chargeColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),

          // Second line: state (bold), cycles, firmware
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                " - $cycleCount cyc - fw $fwVersion",
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Simple panel for non-present batteries
  Widget _buildNonPresentBatteryPanel(
    BuildContext context,
    String title,
    Color backgroundColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey, width: 1.5),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
