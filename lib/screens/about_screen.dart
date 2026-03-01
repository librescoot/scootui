import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../widgets/general/control_gestures_detector.dart';

const _nonCommercialNotice =
    'LibreScoot / ScootUI is free and open-source software licensed for '
    'non-commercial use. Commercial distribution, resale, or preinstallation '
    'on devices for sale is prohibited.';

const _fossComponents = [
  _FossEntry('Flutter', 'BSD-3-Clause', 'https://flutter.dev'),
  _FossEntry('flutter_bloc / bloc', 'MIT', 'https://bloclibrary.dev'),
  _FossEntry('freezed', 'MIT', 'https://pub.dev/packages/freezed'),
  _FossEntry('provider / nested', 'MIT', 'https://pub.dev/packages/provider'),
  _FossEntry('flutter_map', 'BSD-2-Clause', 'https://pub.dev/packages/flutter_map'),
  _FossEntry('flutter_map_animations', 'MIT', 'https://pub.dev/packages/flutter_map_animations'),
  _FossEntry('flutter_map_marker_cluster', 'MIT', 'https://pub.dev/packages/flutter_map_marker_cluster'),
  _FossEntry('vector_map_tiles', 'MIT', 'https://pub.dev/packages/vector_map_tiles'),
  _FossEntry('vector_map_tiles_mbtiles', 'MIT', 'https://pub.dev/packages/vector_map_tiles_mbtiles'),
  _FossEntry('vector_tile_renderer', 'MIT', 'https://pub.dev/packages/vector_tile_renderer'),
  _FossEntry('vector_tile', 'MIT', 'https://pub.dev/packages/vector_tile'),
  _FossEntry('mbtiles', 'MIT', 'https://pub.dev/packages/mbtiles'),
  _FossEntry('latlong2', 'Apache-2.0', 'https://pub.dev/packages/latlong2'),
  _FossEntry('geojson_vi', 'MIT', 'https://pub.dev/packages/geojson_vi'),
  _FossEntry('google_polyline_algorithm', 'MIT', 'https://pub.dev/packages/google_polyline_algorithm'),
  _FossEntry('rbush', 'MIT', 'https://pub.dev/packages/rbush'),
  _FossEntry('redis', 'BSD-3-Clause', 'https://pub.dev/packages/redis'),
  _FossEntry('dio', 'MIT', 'https://pub.dev/packages/dio'),
  _FossEntry('http', 'BSD-3-Clause', 'https://pub.dev/packages/http'),
  _FossEntry('intl', 'BSD-3-Clause', 'https://pub.dev/packages/intl'),
  _FossEntry('flutter_svg', 'MIT', 'https://pub.dev/packages/flutter_svg'),
  _FossEntry('google_fonts', 'Apache-2.0', 'https://pub.dev/packages/google_fonts'),
  _FossEntry('path_provider', 'BSD-3-Clause', 'https://pub.dev/packages/path_provider'),
  _FossEntry('sqlite3_flutter_libs', 'MIT', 'https://pub.dev/packages/sqlite3_flutter_libs'),
  _FossEntry('simple_animations', 'MIT', 'https://pub.dev/packages/simple_animations'),
  _FossEntry('equatable', 'MIT', 'https://pub.dev/packages/equatable'),
  _FossEntry('json_annotation', 'BSD-3-Clause', 'https://pub.dev/packages/json_annotation'),
  _FossEntry('oktoast', 'MIT', 'https://pub.dev/packages/oktoast'),
  _FossEntry('window_manager', 'MIT', 'https://pub.dev/packages/window_manager'),
  _FossEntry('crypto', 'BSD-3-Clause', 'https://pub.dev/packages/crypto'),
];

class _FossEntry {
  final String name;
  final String license;
  final String url;
  const _FossEntry(this.name, this.license, this.url);
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _scrollController = ScrollController();
  static const _scrollStep = 80.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    final target = (_scrollController.offset + _scrollStep)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _scrollUp() {
    final target = (_scrollController.offset - _scrollStep)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state;
    final isDark = theme.isDark;

    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final subtle = isDark ? Colors.white54 : Colors.black54;
    final divider = isDark ? Colors.white12 : Colors.black12;
    final noticeBg = isDark ? const Color(0xFF1A1200) : const Color(0xFFFFF8E1);
    final noticeBorder = isDark ? const Color(0xFF5C4400) : const Color(0xFFFFB300);

    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      onLeftTap: _scrollDown,
      onLeftHold: _scrollUp,
      onRightTap: () => context.read<ScreenCubit>().closeAbout(),
      child: Container(
        color: bg,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: divider)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: subtle, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ABOUT & LICENSES',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: fg,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Non-commercial notice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: noticeBg,
                        border: Border.all(color: noticeBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: noticeBorder, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'NON-COMMERCIAL SOFTWARE',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: noticeBorder,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _nonCommercialNotice,
                            style: TextStyle(
                              fontSize: 13,
                              color: fg,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // FOSS components header
                    Text(
                      'OPEN SOURCE COMPONENTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: subtle,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: divider, height: 1),
                    const SizedBox(height: 4),

                    // Package list
                    ..._fossComponents.map((entry) => _buildPackageRow(
                          entry,
                          fg,
                          subtle,
                          divider,
                        )),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Controls bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
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

  Widget _buildPackageRow(
    _FossEntry entry,
    Color fg,
    Color subtle,
    Color divider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.name,
                  style: TextStyle(fontSize: 14, color: fg),
                ),
              ),
              Text(
                entry.license,
                style: TextStyle(
                  fontSize: 12,
                  color: subtle,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        Divider(color: divider, height: 1),
      ],
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
