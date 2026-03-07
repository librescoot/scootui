import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../cubits/shutdown_cubit.dart';
import '../../cubits/mdb_cubits.dart';
import '../../state/vehicle.dart';
import '../../state/ota.dart';
import 'shutdown_animation.dart';

class ShutdownOverlay extends StatelessWidget {
  const ShutdownOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final shutdownState = ShutdownCubit.watch(context);
    final vehicleState = VehicleSync.watch(context);
    final otaData = OtaSync.watch(context);

    // Check if OTA update is ongoing (DBC status takes priority)
    final dbcStatus = otaData.dbcStatus;
    final isOtaOngoing =
        dbcStatus == 'downloading' || dbcStatus == 'installing';

    // Check shutdown overlay types
    final isFullShutdownOverlay = shutdownState.isFullOverlay;
    final isBackgroundProcessing = shutdownState.isBackgroundIndicator;

    // Priority logic:
    // 1. If OTA is ongoing AND we have full shutdown overlay -> show combined OTA shutdown overlay
    // 2. If OTA is ongoing (and no full shutdown or only background processing) -> show OTA overlay only
    // 3. If full shutdown overlay but no OTA -> show normal shutdown overlay
    // 4. If background processing only (no OTA, no full shutdown) -> show small background indicator
    // 5. Otherwise -> show nothing

    if (shutdownState.isBlackout) {
      return Container(color: Colors.black);
    }

    if (isOtaOngoing && isFullShutdownOverlay) {
      return _buildCombinedOtaShutdownOverlay(
          context, vehicleState, otaData, shutdownState.status);
    } else if (isOtaOngoing) {
      // OTA takes priority over background processing indicator
      return _buildOtaOverlay(context, vehicleState, otaData);
    } else if (isFullShutdownOverlay) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ShutdownContent(status: shutdownState.status),
      );
    } else if (isBackgroundProcessing) {
      return _buildBackgroundProcessingIndicator(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildOtaOverlay(
      BuildContext context, VehicleData vehicleState, OtaData otaData) {
    final dbcStatus = otaData.dbcStatus;
    final updateVersion = otaData.dbcUpdateVersion;
    final isUnlocked = vehicleState.state == ScooterState.readyToDrive ||
        vehicleState.state == ScooterState.parked;
    final isLocked = vehicleState.state == ScooterState.standBy;

    // Status bar icon for unlocked scooter (handled by OtaStatusIndicator in top status bar)
    if (isUnlocked) {
      return const SizedBox.shrink();
    }

    // Full message for locked scooter
    if (isLocked) {
      final l10n = context.l10n;
      final actionText =
          dbcStatus == 'downloading' ? l10n.otaDownloading : l10n.otaInstalling;
      final versionText = updateVersion.isNotEmpty ? ' $updateVersion' : '';

      return Container(
        color: Colors.black, // Full black background for stand-by state
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spinner
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3.0,
                  ),
                ),
                const SizedBox(height: 10),
                // Text
                Text(
                  l10n.otaUpdateMessage(actionText, versionText),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCombinedOtaShutdownOverlay(
      BuildContext context,
      VehicleData vehicleState,
      OtaData otaData,
      ShutdownStatus shutdownStatus) {
    final dbcStatus = otaData.dbcStatus;
    final updateVersion = otaData.dbcUpdateVersion;
    final l10n = context.l10n;
    final actionText =
        dbcStatus == 'downloading' ? l10n.otaDownloading : l10n.otaInstalling;
    final versionText = updateVersion.isNotEmpty ? ' $updateVersion' : '';

    // Use full black background when in stand-by, translucent when shutting down
    final isStandBy = vehicleState.state == ScooterState.standBy;
    final backgroundColor =
        isStandBy ? Colors.black : Colors.black.withOpacity(0.8);

    return Container(
      color: backgroundColor,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinner
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3.0,
                ),
              ),
              const SizedBox(height: 10),
              // Text
              Text(
                l10n.otaUpdateMessage(actionText, versionText),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundProcessingIndicator(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.shutdownProcessing,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
