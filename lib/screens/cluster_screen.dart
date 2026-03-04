import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../cubits/debug_overlay_cubit.dart';
import '../l10n/l10n.dart';
import '../cubits/mdb_cubits.dart';
import '../cubits/theme_cubit.dart';
import '../env_config.dart';
import '../widgets/cluster/blinker_row.dart';
import '../widgets/cluster/cluster_bottom_bar.dart';
import '../widgets/debug/debug_overlay.dart';
import '../widgets/navigation/turn_by_turn_widget.dart';
import '../widgets/speedometer/speedometer_display.dart';
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/status_bars/unified_bottom_status_bar.dart';
import '../state/auto_standby.dart';
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

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme) = ThemeCubit.watch(context);

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
                            const BlinkerRow(),

                            // Free space (expand)
                            const Expanded(child: SizedBox()),

                            // Bottom row with telltales or power display
                            const ClusterBottomBar(),
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
                                context.l10n.standbyWarning,
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
                                context.l10n.standbySeconds,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                context.l10n.standbyCancel,
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
