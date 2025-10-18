import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../state/engine.dart';
import '../../state/settings.dart';
import '../indicators/speed_limit_indicator.dart';

class SpeedCenterWidget extends StatelessWidget {
  const SpeedCenterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final engineData = EngineSync.watch(context);
    final settings = SettingsSync.watch(context);
    final ThemeState(:isDark) = ThemeCubit.watch(context);
    final textColor = isDark ? Colors.white : Colors.black;

    // Get the correct speed based on settings
    final speed = _getDisplaySpeed(engineData, settings);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
        // Position speed limit to the right of the speed
        Positioned(
          right: 0,
          child: const SpeedLimitIndicator(iconSize: 36),
        ),
      ],
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
}