import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../services/toast_service.dart';
import '../widgets/general/control_gestures_detector.dart';

const _websiteUrl = 'https://librescoot.org';
const _licenseId = 'CC BY-NC-SA 4.0';
const _licenseUrl = 'https://creativecommons.org/licenses/by-nc-sa/4.0/';
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
    const path = '/etc/plymouth/theme-override';
    final file = File(path);
    final current = file.existsSync() ? file.readAsStringSync().trim() : '';
    if (current == 'windowsxp') {
      file.writeAsStringSync('librescoot\n');
      ToastService.showInfo('Boot theme: LibreScoot restored.');
    } else {
      file.writeAsStringSync('windowsxp\n');
      ToastService.showSuccess('Genuine Advantage activated.');
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
                      'FOSS firmware for unu Scooter Pro e-mopeds',
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
                                  'NON-COMMERCIAL SOFTWARE',
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
                              'Commercial distribution, resale, or preinstallation '
                              'on devices for sale is prohibited under $_licenseId.',
                              style: TextStyle(
                                  fontSize: 12, color: fg, height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'If you paid money for this software, you may '
                              'have been the victim of a scam. Please report it at $_websiteUrl.',
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
                          'OPEN SOURCE COMPONENTS',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlHint('Left Brake', 'Scroll', fg, subtle),
                  _buildControlHint('Right Brake', 'Back', fg, subtle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlHint(
      String control, String action, Color fg, Color subtle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          control,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: subtle,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          action,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ],
    );
  }
}
