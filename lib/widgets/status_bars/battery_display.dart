import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../state/battery.dart';

// Battery icon dimensions (scaled from 144x144)
const double kBatteryIconWidth = 24.0;
const double kBatteryIconHeight = 24.0;

// Scale factor for converting from 144x144 to our icon size
const double kScaleFactor = kBatteryIconWidth / 144.0;

// Charge level rectangle dimensions (scaled from 144x144)
const double kChargeRectX = 26.0 * kScaleFactor;
const double kChargeRectY = 43.0 * kScaleFactor;
const double kChargeRectHeight = 81.0 * kScaleFactor;
const double kChargeRectMaxWidth = 92.0 * kScaleFactor;

// Text position (scaled from 144x144)
const double kTextY = 45.0 * kScaleFactor;

class BatteryStatusDisplay extends StatelessWidget {
  final BatteryData battery;

  const BatteryStatusDisplay({super.key, required this.battery});

  @override
  Widget build(BuildContext context) {
    // Determine which icon to show based on battery state
    Widget batteryIcon;

    // Get theme information
    final ThemeState(:isDark) = ThemeCubit.watch(context);
    final iconColor = isDark ? Colors.white : Colors.black;

    if (!battery.present) {
      // Battery not present - show blank with slash overlay
      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/librescoot-battery-blank.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SvgPicture.asset(
            'assets/icons/librescoot-overlay-slashed.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ],
      );
    } else if (battery.faults.isNotEmpty) {
      // Battery has fault - show error overlay with fault code
      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/librescoot-battery-blank.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SvgPicture.asset(
            'assets/icons/librescoot-overlay-error.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
          ),
          Positioned(
            top: kTextY,
            child: Center(
              child: Builder(builder: (context) {
                final ThemeState(:isDark) = ThemeCubit.watch(context);
                return Text(
                  battery.faults.first.toString(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = isDark ? Colors.black : Colors.white,
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: kTextY,
            child: Center(
              child: Text(
                battery.faults.first.toString(),
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (battery.state == BatteryState.asleep) {
      // Battery is asleep
      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/librescoot-battery-blank.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SvgPicture.asset(
            'assets/icons/librescoot-overlay-asleep.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ],
      );
    } else if (battery.charge <= 0) {
      // Critically empty battery
      batteryIcon = SvgPicture.asset(
        'assets/icons/librescoot-battery-level-0.svg',
        width: kBatteryIconWidth,
        height: kBatteryIconHeight,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else {
      // Normal battery with charge level
      final chargeWidth = (battery.charge / 100.0) * kChargeRectMaxWidth;

      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          // Base battery icon
          SvgPicture.asset(
            'assets/icons/librescoot-battery-blank.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),

          // Charge level rectangle
          Positioned(
            left: kChargeRectX,
            top: kChargeRectY,
            child: Container(
              width: chargeWidth,
              height: kChargeRectHeight,
              color: iconColor,
            ),
          ),

          // Charge percentage text with outline
          Positioned(
            bottom: 2,
            child: Center(
              child: Builder(builder: (context) {
                final ThemeState(:isDark) = ThemeCubit.watch(context);
                return Text(
                  battery.charge.toString(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = isDark ? Colors.black : Colors.white,
                  ),
                );
              }),
            ),
          ),

          // Charge percentage text
          Positioned(
            bottom: 2,
            child: Center(
              child: Text(
                battery.charge.toString(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Return the battery icon
    return batteryIcon;
  }
}

class CombinedBatteryDisplay extends StatelessWidget {
  const CombinedBatteryDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final battery1 = Battery1Sync.watch(context);
    final battery2 = Battery2Sync.watch(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BatteryStatusDisplay(battery: battery1),
        BatteryStatusDisplay(battery: battery2),
      ],
    );
  }
}
