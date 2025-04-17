import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/system_cubit.dart';
import '../../cubits/theme_cubit.dart';
import '../indicators/connectivity_indicators.dart';
import 'battery_display.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);
    final system = SystemCubit.watch(context);
    final bluetooth = BluetoothSync.watch(context);

    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left side - Battery indicators
          Expanded(
            flex: 2,
            child: CombinedBatteryDisplay(),
          ),

          // Center - Time
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                system.formattedTime,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),

          // Right side - Bluetooth icon
          Expanded(
            flex: 2,
            child: ConnectivityIndicators(),
          ),
        ],
      ),
    );
  }
}
