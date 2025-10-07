import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/theme_cubit.dart';
import '../../cubits/mdb_cubits.dart';
import '../../state/vehicle.dart';
import 'indicator_light.dart';

class _Icons {
  static const String downloading = 'librescoot-ota-status-downloading.svg';
  static const String installing = 'librescoot-ota-status-installing.svg';
  static const String rebooting = 'librescoot-ota-status-waiting-for-reboot.svg';
}

class OtaStatusIndicator extends StatelessWidget {
  const OtaStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleState = VehicleSync.watch(context);
    final otaData = OtaSync.watch(context);
    final ThemeState(:isDark) = ThemeCubit.watch(context);
    
    // Check if DBC update is ongoing
    final dbcStatus = otaData.dbcStatus;
    final isOtaOngoing = dbcStatus == 'downloading' || dbcStatus == 'installing' || dbcStatus == 'rebooting' || dbcStatus == 'error';
    
    // Only show when scooter is unlocked and DBC update is ongoing
    final isUnlocked = vehicleState.state == ScooterState.readyToDrive || 
                      vehicleState.state == ScooterState.parked;
    
    if (!isOtaOngoing || !isUnlocked) {
      return const SizedBox.shrink();
    }

    final color = isDark ? Colors.white : Colors.black;
    final updateVersion = otaData.dbcUpdateVersion;

    final String actionText;
    final String iconAsset;
    final bool hasError = dbcStatus == 'error';

    switch (dbcStatus) {
      case 'downloading':
        actionText = 'Downloading';
        iconAsset = _Icons.downloading;
        break;
      case 'installing':
        actionText = 'Installing';
        iconAsset = _Icons.installing;
        break;
      case 'rebooting':
        actionText = 'Waiting for reboot';
        iconAsset = _Icons.rebooting;
        break;
      case 'error':
        actionText = 'Update error';
        iconAsset = _Icons.rebooting;
        break;
      default:
        actionText = 'Updating';
        iconAsset = _Icons.downloading;
    }

    final versionText = updateVersion.isNotEmpty ? ' Librescoot $updateVersion' : ' update';

    // Build the icon, with error overlay if needed
    final Widget icon;
    if (hasError) {
      icon = SizedBox(
        width: 24.0,
        height: 24.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/$iconAsset',
              width: 24.0,
              height: 24.0,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SvgPicture.asset(
              'assets/icons/librescoot-overlay-error.svg',
              width: 24.0,
              height: 24.0,
              colorFilter: !isDark
                  ? const ColorFilter.matrix([
                      // Invert colors for light theme
                      -1.0, 0.0, 0.0, 0.0, 255.0,
                      0.0, -1.0, 0.0, 0.0, 255.0,
                      0.0, 0.0, -1.0, 0.0, 255.0,
                      0.0, 0.0, 0.0, 1.0, 0.0,
                    ])
                  : null,
            ),
          ],
        ),
      );
    } else {
      icon = IndicatorLight(
        icon: IndicatorLight.svgAsset(iconAsset),
        isActive: true,
        size: 24.0,
        activeColor: color,
      );
    }

    return Tooltip(
      message: '$actionText$versionText',
      child: icon,
    );
  }
}
