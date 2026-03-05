import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/theme_cubit.dart';
import '../cubits/version_overlay_cubit.dart';
import '../repositories/mdb_repository.dart';

class VersionOverlay extends StatelessWidget {
  const VersionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionOverlayCubit, bool>(
      builder: (context, visible) {
        if (!visible) return const SizedBox();

        return _VersionOverlayContent();
      },
    );
  }
}

class _VersionOverlayContent extends StatefulWidget {
  @override
  State<_VersionOverlayContent> createState() => _VersionOverlayContentState();
}

class _VersionOverlayContentState extends State<_VersionOverlayContent> {
  // Version data
  Map<String, String> _systemData = {};
  Map<String, String> _mdbVersionData = {};
  Map<String, String> _dbcVersionData = {};
  Map<String, String> _engineEcuData = {};
  Map<String, String> _auxBatteryData = {};
  Map<String, String> _cbBatteryData = {};
  bool _isLibreScootMdb = false;
  bool _isLibreScootDbc = false;

  @override
  void initState() {
    super.initState();
    _loadVersionData();
  }

  Future<void> _loadVersionData() async {
    final mdbRepository = context.read<MDBRepository>();

    // Fetch system data
    _systemData = await _getRedisData(mdbRepository, 'system');

    // Check if LibreScoot or Stock
    _isLibreScootMdb = await _checkRedisKeyExists(mdbRepository, 'version:mdb');
    _isLibreScootDbc = await _checkRedisKeyExists(mdbRepository, 'version:dbc');

    // Fetch version data based on firmware type
    if (_isLibreScootMdb) {
      _mdbVersionData = await _getRedisData(mdbRepository, 'version:mdb');
    }

    if (_isLibreScootDbc) {
      _dbcVersionData = await _getRedisData(mdbRepository, 'version:dbc');
    }

    // Fetch ECU data
    _engineEcuData = await _getRedisData(mdbRepository, 'engine-ecu');

    // Fetch battery data
    _auxBatteryData = await _getRedisData(mdbRepository, 'aux-battery');
    _cbBatteryData = await _getRedisData(mdbRepository, 'cb-battery');

    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _checkRedisKeyExists(MDBRepository repository, String key) async {
    try {
      final data = await repository.getAll(key);
      return data.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if $key exists: $e');
      return false;
    }
  }

  Future<Map<String, String>> _getRedisData(MDBRepository repository, String key) async {
    try {
      final data = await repository.getAll(key);
      return Map.fromEntries(data.map((entry) => MapEntry(entry.$1, entry.$2)));
    } catch (e) {
      debugPrint('Error loading $key data: $e');
      return {};
    }
  }

  String _getMdbVersionString() {
    if (_isLibreScootMdb) {
      final name = _mdbVersionData['name'] ?? 'LibreScoot';
      final version = _mdbVersionData['version'] ?? '';
      return '$name $version';
    } else {
      return 'Stock ${_systemData['mdb-version'] ?? ''}';
    }
  }

  String _getDbcVersionString() {
    if (_isLibreScootDbc) {
      final name = _dbcVersionData['name'] ?? 'LibreScoot';
      final version = _dbcVersionData['version'] ?? '';
      return '$name $version';
    } else {
      return 'Stock ${_systemData['dbc-version'] ?? ''}';
    }
  }

  String _getNrfVersionString() {
    return _systemData['nrf-fw-version'] ?? 'N/A';
  }

  String _getEcuVersionString() {
    return _engineEcuData['fw-version'] ?? 'N/A';
  }

  String _getAuxBatteryString() {
    final charge = _auxBatteryData['charge'] ?? '0';
    final voltage = _auxBatteryData['voltage'] != null
        ? '${((int.tryParse(_auxBatteryData['voltage'] ?? '0') ?? 0) / 1000).toStringAsFixed(1)}V'
        : '';
    final chargeStatus = _auxBatteryData['charge-status'] ?? 'unknown';

    return '$voltage $chargeStatus $charge%';
  }

  String _getCbBatteryString() {
    final charge = _cbBatteryData['charge'] ?? '0';
    final voltage = _cbBatteryData['cell-voltage'] != null
        ? '${((int.tryParse(_cbBatteryData['cell-voltage'] ?? '0') ?? 0) / 1000000).toStringAsFixed(1)}V'
        : '';
    final chargeStatus = _cbBatteryData['charge-status'] ?? 'unknown';

    return '$voltage $chargeStatus $charge%';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCubit.watch(context).isDark;

    final backgroundColor = isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7);
    final borderColor = isDark ? Colors.white30 : Colors.black26;
    final textColor = isDark ? Colors.white : Colors.black;

    return Positioned(
      bottom: 80,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // First section: Firmware versions
            _buildVersionSection(
              [
                _buildDataRow('MDB', _getMdbVersionString(), textColor),
                _buildDataRow('DBC', _getDbcVersionString(), textColor),
                _buildDataRow('nRF', _getNrfVersionString(), textColor),
                _buildDataRow('ECU', _getEcuVersionString(), textColor),
              ],
              borderColor,
            ),

            const SizedBox(height: 8),

            // Second section: Battery info
            _buildVersionSection(
              [
                _buildDataRow('AUX', _getAuxBatteryString(), textColor),
                _buildDataRow('CBB', _getCbBatteryString(), textColor),
              ],
              borderColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionSection(List<Widget> rows, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
