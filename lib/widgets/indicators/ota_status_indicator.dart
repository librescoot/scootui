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
    final errorType = otaData.dbcError;
    // Treat 'reboot-failed' as 'rebooting' status (backward compatibility - show ready-to-reboot icon)
    final isRealError = dbcStatus == 'error' && errorType != 'reboot-failed';
    final isRebootFailed = dbcStatus == 'error' && errorType == 'reboot-failed';
    final isOtaOngoing = dbcStatus == 'downloading' || dbcStatus == 'installing' || dbcStatus == 'rebooting' || isRealError || isRebootFailed;
    
    // Only show when scooter is unlocked and DBC update is ongoing
    final isUnlocked = vehicleState.state == ScooterState.readyToDrive ||
                      vehicleState.state == ScooterState.parked;

    if (!isOtaOngoing || !isUnlocked) {
      return const SizedBox.shrink();
    }

    final color = isDark ? Colors.white : Colors.black;
    final updateVersion = otaData.dbcUpdateVersion;
    final errorMessage = otaData.dbcErrorMessage;

    final String actionText;
    final String iconAsset;
    final bool hasError = dbcStatus == 'error' && !isRebootFailed;

    if (isRebootFailed) {
      // Treat reboot-failed as rebooting status (backward compatibility)
      actionText = 'Waiting for reboot';
      iconAsset = _Icons.rebooting;
    } else {
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
          // Use appropriate icon based on error type
          actionText = _getErrorText(errorType);
          iconAsset = _getErrorIcon(errorType);
          break;
        default:
          actionText = 'Updating';
          iconAsset = _Icons.downloading;
      }
    }

    final versionText = updateVersion.isNotEmpty ? ' Librescoot $updateVersion' : ' update';

    // Build tooltip message - use detailed error message if available
    final String tooltipMessage;
    if (hasError && errorMessage.isNotEmpty) {
      tooltipMessage = errorMessage;
    } else {
      tooltipMessage = '$actionText$versionText';
    }

    // Build the icon, with error overlay if needed
    final Widget icon;
    if (hasError) {
      icon = Stack(
        alignment: Alignment.center,
        children: [
          // Base icon (using same pattern as battery_display.dart)
          SvgPicture.asset(
            'assets/icons/$iconAsset',
            width: 24.0,
            height: 24.0,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          // Error overlay
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
      );
    } else {
      icon = IndicatorLight(
        icon: IndicatorLight.svgAsset(iconAsset),
        isActive: true,
        size: 24.0,
        activeColor: color,
      );
    }

    // Build widget with optional progress text
    Widget result = icon;

    // Show download progress percentage when downloading
    if (dbcStatus == 'downloading' && !hasError) {
      final progress = int.tryParse(otaData.dbcDownloadProgress) ?? 0;
      if (progress > 0) {
        result = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 2),
            Text(
              '$progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      }
    }

    return Tooltip(
      message: tooltipMessage,
      child: result,
    );
  }

  static String _getErrorText(String errorType) {
    // Convert error type to user-friendly text
    // Maintains backwards compatibility if errorType is empty
    switch (errorType) {
      case 'invalid-release-tag':
        return 'Invalid release';
      case 'download-failed':
        return 'Download failed';
      case 'install-failed':
        return 'Install failed';
      case 'reboot-failed':
        return 'Reboot failed';
      default:
        return 'Update error';
    }
  }

  static String _getErrorIcon(String errorType) {
    // Select appropriate icon based on error type
    switch (errorType) {
      case 'download-failed':
      case 'invalid-release-tag':
        return _Icons.downloading;
      case 'install-failed':
        return _Icons.installing;
      default:
        // Default to rebooting icon for unknown errors
        return _Icons.rebooting;
    }
  }
}
