import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scooter_cluster/cubits/dashboard_cubit.dart';

import '../repositories/mdb_repository.dart';
import '../widgets/status_bars/top_status_bar.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  // Data maps for each Redis key
  Map<String, String> _vehicleData = {};
  Map<String, String> _engineEcuData = {};
  Map<String, String> _battery0Data = {};
  Map<String, String> _battery1Data = {};
  Map<String, String> _auxBatteryData = {};
  Map<String, String> _cbBatteryData = {};
  Map<String, String> _systemData = {};
  Map<String, String> _powerManagerData = {};
  Map<String, String> _powerMuxData = {};
  Map<String, String> _gpsData = {};
  Map<String, String> _internetData = {};
  Map<String, String> _modemData = {};
  Map<String, String> _otaData = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLegacyData();
    // Set up periodic refresh every 1 second for legacy data
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 250), (_) => _loadLegacyData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Renamed to avoid conflict and clarify purpose
  Future<void> _loadLegacyData() async {
    final mdbRepository = context.read<MDBRepository>();

    // Load data from Redis
    _vehicleData = await _getRedisData(mdbRepository, 'vehicle');
    _engineEcuData = await _getRedisData(mdbRepository, 'engine-ecu');
    _battery0Data = await _getRedisData(mdbRepository, 'battery:0');
    _battery1Data = await _getRedisData(mdbRepository, 'battery:1');
    _auxBatteryData = await _getRedisData(mdbRepository, 'aux-battery');
    _cbBatteryData = await _getRedisData(mdbRepository, 'cb-battery');
    _systemData = await _getRedisData(mdbRepository, 'system');
    _powerManagerData = await _getRedisData(mdbRepository, 'power-manager');
    _powerMuxData = await _getRedisData(mdbRepository, 'power-mux');
    _gpsData = await _getRedisData(mdbRepository, 'gps');
    _internetData = await _getRedisData(mdbRepository, 'internet');
    _modemData = await _getRedisData(mdbRepository, 'modem');
    _otaData = await _getRedisData(mdbRepository, 'ota');

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
    final theme = Theme.of(context);
    final dashboardData = DashboardSyncCubit.watch(context); // Watch DashboardSyncCubit

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Status bar at top
          const StatusBar(),

          // Debug title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            width: double.infinity,
            color: theme.colorScheme.primary,
            child: Text(
              'DEBUG MODE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Compact debug info
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    // Two-column table layout
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2), // Left column width
                        1: FlexColumnWidth(8), // Right column takes remaining space
                      },
                      children: [
                        // Vehicle state and versions
                        _buildTableRow(
                          'Vehicle',
                          _buildWrappingRow([
                            _buildCompactItem('State', _vehicleData['state'] ?? 'N/A'),
                            _buildCompactItem('Pwr', _vehicleData['main-power'] ?? 'N/A'),
                          ]),
                        ),

                        // Engine data
                        _buildTableRow(
                          'Engine',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('Spd', '${_engineEcuData['speed'] ?? 'N/A'} km/h'),
                                _buildCompactItem('RPM', _engineEcuData['rpm'] ?? 'N/A'),
                                _buildCompactItem('Odo', '${_engineEcuData['odometer'] ?? 'N/A'} m'),
                                _buildCompactItem('Eng', _engineEcuData['state'] ?? 'N/A'),
                                _buildCompactItem('Thr', _engineEcuData['throttle'] ?? 'N/A'),
                              ]),
                              _buildWrappingRow([
                                _buildCompactItem('MV', '${_engineEcuData['motor:voltage'] ?? 'N/A'} mV'),
                                _buildCompactItem('MC', '${_engineEcuData['motor:current'] ?? 'N/A'} mA'),
                                _buildCompactItem('KERS', _engineEcuData['kers'] ?? 'N/A'),
                                _buildCompactItem('KOff', _engineEcuData['kers-reason-off'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // Switches and controls
                        _buildTableRow(
                          'Switches',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('HPos', _vehicleData['handlebar:position'] ?? 'N/A'),
                                _buildCompactItem('HLock', _vehicleData['handlebar:lock-sensor'] ?? 'N/A'),
                                _buildCompactItem('Kick', _vehicleData['kickstand'] ?? 'N/A'),
                                _buildCompactItem('Seat', _vehicleData['seatbox:lock'] ?? 'N/A'),
                              ]),
                              _buildWrappingRow([
                                _buildCompactItem('BL', _vehicleData['brake:left'] ?? 'N/A'),
                                _buildCompactItem('BR', _vehicleData['brake:right'] ?? 'N/A'),
                                _buildCompactItem('Blink', _vehicleData['blinker:switch'] ?? 'N/A'),
                                _buildCompactItem('BlSt', _vehicleData['blinker:state'] ?? 'N/A'),
                                _buildCompactItem('Horn', _vehicleData['horn:button'] ?? 'N/A'),
                                _buildCompactItem('SBtn', _vehicleData['seatbox:button'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // GPS
                        _buildTableRow(
                          'GPS',
                          _buildWrappingRow([
                            _buildCompactItem('Lat', _gpsData['latitude'] ?? 'N/A'),
                            _buildCompactItem('Lng', _gpsData['longitude'] ?? 'N/A'),
                            _buildCompactItem('Alt', _gpsData['altitude'] ?? 'N/A'),
                            _buildCompactItem('Crs', _gpsData['course'] ?? 'N/A'),
                          ]),
                        ),

                        // Battery 0
                        _buildTableRow(
                          'Battery 0',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('B0', _battery0Data['present'] ?? 'N/A'),
                                _buildCompactItem('St', _battery0Data['state'] ?? 'N/A'),
                                _buildCompactItem('V', '${_battery0Data['voltage'] ?? 'N/A'} mV'),
                                _buildCompactItem('C', '${_battery0Data['current'] ?? 'N/A'} mA'),
                                _buildCompactItem('Chg', '${_battery0Data['charge'] ?? 'N/A'}%'),
                              ]),
                              _buildWrappingRow([
                                _buildCompactItem('T0', '${_battery0Data['temperature:0'] ?? 'N/A'}°C'),
                                _buildCompactItem('T1', '${_battery0Data['temperature:1'] ?? 'N/A'}°C'),
                                _buildCompactItem('T2', '${_battery0Data['temperature:2'] ?? 'N/A'}°C'),
                                _buildCompactItem('T3', '${_battery0Data['temperature:3'] ?? 'N/A'}°C'),
                                _buildCompactItem('TSt', _battery0Data['temperature-state'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // Battery 1
                        _buildTableRow(
                          'Battery 1',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('B1', _battery1Data['present'] ?? 'N/A'),
                                _buildCompactItem('St', _battery1Data['state'] ?? 'N/A'),
                                _buildCompactItem('V', '${_battery1Data['voltage'] ?? 'N/A'} mV'),
                                _buildCompactItem('C', '${_battery1Data['current'] ?? 'N/A'} mA'),
                                _buildCompactItem('Chg', '${_battery1Data['charge'] ?? 'N/A'}%'),
                              ]),
                              _buildWrappingRow([
                                _buildCompactItem('T0', '${_battery1Data['temperature:0'] ?? 'N/A'}°C'),
                                _buildCompactItem('T1', '${_battery1Data['temperature:1'] ?? 'N/A'}°C'),
                                _buildCompactItem('T2', '${_battery1Data['temperature:2'] ?? 'N/A'}°C'),
                                _buildCompactItem('T3', '${_battery1Data['temperature:3'] ?? 'N/A'}°C'),
                                _buildCompactItem('TSt', _battery1Data['temperature-state'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // Aux battery and Power Mux
                        _buildTableRow(
                          'Aux & Power',
                          _buildWrappingRow([
                            _buildCompactItem('AuxV', '${_auxBatteryData['voltage'] ?? 'N/A'} mV'),
                            _buildCompactItem('Chg', '${_auxBatteryData['charge'] ?? 'N/A'}%'),
                            _buildCompactItem('ChgSt', _auxBatteryData['charge-status'] ?? 'N/A'),
                            _buildCompactItem('PMux', _powerMuxData['selected-input'] ?? 'N/A'),
                          ]),
                        ),

                        // CB battery
                        _buildTableRow(
                          'CB Battery',
                          _buildWrappingRow([
                            _buildCompactItem('CBChg', '${_cbBatteryData['charge'] ?? 'N/A'}%'),
                            _buildCompactItem('Curr', '${_cbBatteryData['current'] ?? 'N/A'} μA'),
                            _buildCompactItem('Temp', '${_cbBatteryData['temperature'] ?? 'N/A'}°C'),
                            _buildCompactItem('SoH', '${_cbBatteryData['state-of-health'] ?? 'N/A'}%'),
                          ]),
                        ),

                        // System data
                        _buildTableRow(
                          'System',
                          _buildWrappingRow([
                            _buildCompactItem('MDB', _systemData['mdb-version'] ?? 'N/A'),
                            _buildCompactItem('DBC', _systemData['dbc-version'] ?? 'N/A'),
                            _buildCompactItem('NRF', _systemData['nrf-fw-version'] ?? 'N/A'),
                            _buildCompactItem('Env', _systemData['environment'] ?? 'N/A'),
                          ]),
                        ),

                        // Power Manager
                        _buildTableRow(
                          'Power Mgr',
                          _buildWrappingRow([
                            _buildCompactItem('State', _powerManagerData['state'] ?? 'N/A'),
                            _buildCompactItem('Wake', _powerManagerData['wakeup-source'] ?? 'N/A'),
                          ]),
                        ),

                        // Internet data
                        _buildTableRow(
                          'Internet',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('Modem', _internetData['modem-state'] ?? 'N/A'),
                                _buildCompactItem('Status', _internetData['status'] ?? 'N/A'),
                                _buildCompactItem('Cloud', _internetData['unu-cloud'] ?? 'N/A'),
                                _buildCompactItem('IP', _internetData['ip-address'] ?? 'N/A'),
                                _buildCompactItem('Tech', _internetData['access-tech'] ?? 'N/A'),
                                _buildCompactItem('Signal', _internetData['signal-quality'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // Modem data
                        _buildTableRow(
                          'Modem',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('Power', _modemData['power-state'] ?? 'N/A'),
                                _buildCompactItem('SIM', _modemData['sim-state'] ?? 'N/A'),
                                _buildCompactItem('Lock', _modemData['sim-lock'] ?? 'N/A'),
                                _buildCompactItem('Error', _modemData['error-state'] ?? 'N/A'),
                              ]),
                              _buildWrappingRow([
                                _buildCompactItem('Op', _modemData['operator-name'] ?? 'N/A'),
                                _buildCompactItem('Code', _modemData['operator-code'] ?? 'N/A'),
                                _buildCompactItem('Roam', _modemData['is-roaming'] ?? 'N/A'),
                                _buildCompactItem('RegFail', _modemData['registration-fail'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // OTA data
                        _buildTableRow(
                          'OTA',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWrappingRow([
                                _buildCompactItem('Status', _otaData['status'] ?? 'N/A'),
                                _buildCompactItem('Type', _otaData['update-type'] ?? 'N/A'),
                                _buildCompactItem('Comp', _otaData['component'] ?? 'N/A'),
                                _buildCompactItem('Prog', '${_otaData['progress'] ?? 'N/A'}%'),
                                _buildCompactItem('Error', _otaData['error'] ?? 'N/A'),
                                _buildCompactItem('URL', _otaData['url'] ?? 'N/A'),
                              ]),
                            ],
                          ),
                        ),

                        // Dashboard Data (New)
                        _buildTableRow(
                          'Dashboard',
                          _buildWrappingRow([
                            _buildCompactItem('Bright', '${dashboardData.brightness?.toStringAsFixed(1) ?? "N/A"} lx'),
                            _buildCompactItem('Backlight', dashboardData.backlight?.toString() ?? 'N/A'),
                            _buildCompactItem('Theme', dashboardData.theme ?? 'N/A'),
                            _buildCompactItem('Mode', dashboardData.mode ?? 'N/A'),
                            _buildCompactItem('Debug', dashboardData.debug ?? 'N/A'),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrappingRow(List<Widget> items) {
    return Wrap(
      spacing: 4, // gap between adjacent items
      runSpacing: 2, // gap between lines
      children: items,
    );
  }

  Widget _buildCompactItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, Widget content) {
    return TableRow(
      children: [
        // Left column - title
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 2),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[200],
            ),
          ),
        ),
        // Right column - content
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: content,
        ),
      ],
    );
  }
}
