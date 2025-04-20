import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../indicators/indicator_lights.dart';

class MapBottomStatusBar extends StatelessWidget {
  const MapBottomStatusBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final engine = EngineSync.watch(context);
    final speed = engine.speed;
    final vehicle = VehicleSync.watch(context);
    final ThemeState(:isDark, :theme) = ThemeCubit.watch(context);
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          // Left blinker
          IndicatorLights.leftBlinker(vehicle),

          // Speed display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                speed.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'km/h',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),

          // Right blinker
          IndicatorLights.rightBlinker(vehicle),
        ],
      ),
    );
  }
}
