import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../l10n/l10n.dart';
import '../repositories/mdb_repository.dart';
import '../services/l10n_service.dart';
import '../services/toast_service.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/general/control_hints.dart';

const _websiteUrl = 'https://librescoot.org';
const _licenseId = 'CC BY-NC-SA 4.0';
const _copyrightStart = 2025;

const _fossComponents = [
  _FossEntry('Flutter', 'BSD-3-Clause'),
  _FossEntry('flutter_bloc / bloc', 'MIT'),
  _FossEntry('freezed', 'MIT'),
  _FossEntry('provider / nested', 'MIT'),
  _FossEntry('flutter_map', 'BSD-2-Clause'),
  _FossEntry('flutter_map_animations', 'MIT'),
  _FossEntry('flutter_map_marker_cluster', 'MIT'),
  _FossEntry('vector_map_tiles', 'MIT'),
  _FossEntry('vector_map_tiles_mbtiles', 'MIT'),
  _FossEntry('vector_tile_renderer', 'MIT'),
  _FossEntry('vector_tile', 'MIT'),
  _FossEntry('mbtiles', 'MIT'),
  _FossEntry('latlong2', 'Apache-2.0'),
  _FossEntry('geojson_vi', 'MIT'),
  _FossEntry('google_polyline_algorithm', 'MIT'),
  _FossEntry('rbush', 'MIT'),
  _FossEntry('redis', 'BSD-3-Clause'),
  _FossEntry('dio', 'MIT'),
  _FossEntry('http', 'BSD-3-Clause'),
  _FossEntry('intl', 'BSD-3-Clause'),
  _FossEntry('flutter_svg', 'MIT'),
  _FossEntry('google_fonts', 'Apache-2.0'),
  _FossEntry('path_provider', 'BSD-3-Clause'),
  _FossEntry('sqlite3_flutter_libs', 'MIT'),
  _FossEntry('simple_animations', 'MIT'),
  _FossEntry('equatable', 'MIT'),
  _FossEntry('json_annotation', 'BSD-3-Clause'),
  _FossEntry('oktoast', 'MIT'),
  _FossEntry('window_manager', 'MIT'),
  _FossEntry('crypto', 'BSD-3-Clause'),
];

class _FossEntry {
  final String name;
  final String license;
  const _FossEntry(this.name, this.license);
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

// Easter egg: down×4, up×3, down×2, up×1 then exit
// true=down (left tap), false=up (left hold)
const _eggSeq = [true, true, true, true, false, false, false, true, true, false];

class _AboutScreenState extends State<AboutScreen> {
  final _scrollController = ScrollController();
  static const _scrollStep = 80.0;
  int _eggStep = 0;

  Map<String, String> _systemData = {};
  Map<String, String> _mdbVersionData = {};
  Map<String, String> _dbcVersionData = {};
  Map<String, String> _engineEcuData = {};

  @override
  void initState() {
    super.initState();
    _loadVersionData();
  }

  Future<void> _loadVersionData() async {
    final repo = context.read<MDBRepository>();
    Future<Map<String, String>> getAll(String key) async {
      try {
        final entries = await repo.getAll(key);
        return Map.fromEntries(entries.map((e) => MapEntry(e.$1, e.$2)));
      } catch (_) {
        return {};
      }
    }

    final system = await getAll('system');
    final mdb = await getAll('version:mdb');
    final dbc = await getAll('version:dbc');
    final ecu = await getAll('engine-ecu');

    if (mounted) {
      setState(() {
        _systemData = system;
        _mdbVersionData = mdb;
        _dbcVersionData = dbc;
        _engineEcuData = ecu;
      });
    }
  }

  List<(String, String)> get _versionRows {
    final rows = <(String, String)>[];
    if (_mdbVersionData.isNotEmpty) {
      final v = _mdbVersionData['version'] ?? '';
      rows.add(('MDB', v.isNotEmpty ? v : '—'));
    } else if (_systemData.containsKey('mdb-version')) {
      rows.add(('MDB', _systemData['mdb-version']!));
    }
    if (_dbcVersionData.isNotEmpty) {
      final v = _dbcVersionData['version'] ?? '';
      rows.add(('DBC', v.isNotEmpty ? v : '—'));
    } else if (_systemData.containsKey('dbc-version')) {
      rows.add(('DBC', _systemData['dbc-version']!));
    }
    final nrf = _systemData['nrf-fw-version'];
    if (nrf != null && nrf.isNotEmpty) rows.add(('nRF', nrf));
    final ecu = _engineEcuData['fw-version'];
    if (ecu != null && ecu.isNotEmpty) rows.add(('ECU', ecu));
    return rows;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _trackEgg(bool isDown) {
    if (isDown == _eggSeq[_eggStep]) {
      _eggStep++;
    } else {
      _eggStep = isDown == _eggSeq[0] ? 1 : 0;
    }
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + _scrollStep)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    _trackEgg(true);
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset - _scrollStep)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    _trackEgg(false);
  }

  void _close() {
    if (_eggStep == _eggSeq.length) _toggleXpTheme();
    context.read<ScreenCubit>().closeAbout();
  }

  Future<void> _toggleXpTheme() async {
    // /data/plymouth-theme is read by plymouth-start.service at boot.
    // /data survives OTA updates; /etc/plymouth/plymouthd.conf is overwritten.
    // Write plymouthd.conf directly too so the change takes effect next boot
    // without requiring plymouth-start to re-run.
    const confPath = '/etc/plymouth/plymouthd.conf';
    const dataPath = '/data/plymouth-theme';
    final conf = File(confPath);
    final current = conf.existsSync()
        ? RegExp(r'Theme=(\S+)').firstMatch(conf.readAsStringSync())?.group(1) ?? ''
        : '';
    final (next, message) = current == 'windowsxp'
        ? ('librescoot', L10nService.current.aboutBootThemeRestored)
        : ('windowsxp', L10nService.current.aboutGenuineAdvantage);
    const template = '[Daemon]\nTheme=%s\nShowDelay=0\nDeviceTimeout=5\nIgnoreSerialConsoles=yes\n';
    conf.writeAsStringSync(template.replaceFirst('%s', next));
    if (next == 'librescoot') {
      File(dataPath).deleteSync();
    } else {
      File(dataPath).writeAsStringSync('$next\n');
    }
    if (next == 'windowsxp') {
      ToastService.showSuccess(message);
    } else {
      ToastService.showInfo(message);
    }
  }

  String get _copyrightYear {
    final year = DateTime.now().year;
    return year > _copyrightStart ? '$_copyrightStart–$year' : '$_copyrightStart';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state;
    final isDark = theme.isDark;

    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final subtle = isDark ? Colors.white54 : Colors.black54;
    final divider = isDark ? Colors.white12 : Colors.black12;
    final accent = isDark ? const Color(0xFF40C8F0) : const Color(0xFF0090B8);

    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      initialData: context.read<VehicleSync>().state,
      requireInitialRelease: true,
      onLeftTap: _scrollDown,
      onLeftHold: _scrollUp,
      onRightTap: _close,
      child: Container(
        color: bg,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo + title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/librescoot-logo.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LibreScoot',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: fg,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'ScootUI',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtle,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      context.l10n.aboutFossDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtle,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _websiteUrl,
                      style: TextStyle(
                        fontSize: 13,
                        color: accent,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '$_licenseId  ©\u00a0$_copyrightYear LibreScoot contributors',
                      style: TextStyle(fontSize: 12, color: subtle),
                      textAlign: TextAlign.center,
                    ),

                    if (_versionRows.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: _versionRows.map((row) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '${row.$1}:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtle),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  row.$2,
                                  style: TextStyle(fontSize: 12, color: subtle, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Divider(color: divider, indent: 40, endIndent: 40),
                    const SizedBox(height: 8),

                    // Non-commercial notice
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1200)
                              : const Color(0xFFFFF8E1),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF5C4400)
                                : const Color(0xFFFFB300),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: isDark
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFFE65100),
                                    size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.aboutNonCommercialTitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFFE65100),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.aboutCommercialProhibited(_licenseId),
                              style: TextStyle(
                                  fontSize: 12, color: fg, height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.aboutScamWarning(_websiteUrl),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: fg,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: divider, indent: 40, endIndent: 40),
                    const SizedBox(height: 8),

                    // FOSS list header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.aboutOpenSourceComponents,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: subtle,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Package list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: _fossComponents.map((e) => Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(e.name,
                                        style: TextStyle(
                                            fontSize: 13, color: fg)),
                                  ),
                                  Text(
                                    e.license,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subtle,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: divider, height: 1),
                          ],
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Controls bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divider)),
              ),
              child: ControlHints(
                leftAction: context.l10n.aboutScrollAction,
                rightAction: context.l10n.aboutBackAction,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
