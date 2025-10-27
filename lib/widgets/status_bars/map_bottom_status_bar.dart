import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../cubits/trip_cubit.dart';
import '../../state/engine.dart';
import '../../state/settings.dart';
import '../indicators/speed_limit_indicator.dart';

class MapBottomStatusBar extends StatelessWidget {
  const MapBottomStatusBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final engineData = EngineSync.watch(context);
    final settings = SettingsSync.watch(context);
    final trip = TripCubit.watch(context);
    final ThemeState(:isDark, :theme) = ThemeCubit.watch(context);
    final textColor = isDark ? Colors.white : Colors.black;

    // Get the correct speed based on settings
    final speed = _getDisplaySpeed(engineData, settings);

    final currentTrip = trip.distanceTravelled / 1000;
    final currentTotal = engineData.odometer / 1000;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: Trip stats
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${currentTrip.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'AVG ${trip.averageSpeed.toStringAsFixed(1)} km/h',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                Text(
                  _formatTripTime(trip.tripDuration),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Center: Speed display with speed limit
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpeedLimitIndicator(iconSize: 35),
                Text(
                  speed.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
                Text(
                  'km/h',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Right: Total distance
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  currentTotal.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the correct speed value based on settings
  double _getDisplaySpeed(EngineData engineData, SettingsData settings) {
    if (settings.showRawSpeedBool) {
      // Use raw speed if available and not null, otherwise fall back to processed speed
      final rawSpeedValue = engineData.rawSpeed;
      if (rawSpeedValue != null) {
        return rawSpeedValue.toDouble();
      }
    }

    return engineData.speed.toDouble();
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
