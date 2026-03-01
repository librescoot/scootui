import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../cubits/trip_cubit.dart';
import '../../l10n/l10n.dart';

class UnifiedBottomStatusBar extends StatelessWidget {
  final Widget? centerWidget;

  const UnifiedBottomStatusBar({
    super.key,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final engineData = EngineSync.watch(context);
    final trip = TripCubit.watch(context);
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);
    final textColor = isDark ? Colors.white : Colors.black;

    final currentTrip = trip.distanceTravelled / 1000;
    final currentTotal = engineData.odometer / 1000;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: Duration and Avg Speed (equal width section)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Labels and values rows
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Duration column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context.l10n.statusBarDuration, isDark),
                          _buildValue(_formatTripTime(trip.tripDuration), textColor),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Avg Speed column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context.l10n.statusBarAvgSpeed, isDark),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              _buildValue(trip.averageSpeed.toStringAsFixed(1), textColor),
                              const SizedBox(width: 2),
                              Text(
                                context.l10n.statusBarKmh,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Center: Configurable widget (equal width section)
          Expanded(
            flex: 1,
            child: centerWidget ?? const SizedBox(),
          ),

          // Right: Trip and Total distances (equal width section)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Labels and values rows
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Trip column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildLabel(context.l10n.statusBarTrip, isDark),
                          _buildValue(currentTrip.toStringAsFixed(1), textColor),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Total column
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildLabel(context.l10n.statusBarTotal, isDark),
                          _buildValue(currentTotal.toStringAsFixed(1), textColor),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white60 : Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildValue(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }


  String _formatTripTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}