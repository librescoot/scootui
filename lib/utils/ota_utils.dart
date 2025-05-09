import '../state/vehicle.dart';

/// Defines possible OTA update states
enum OtaStatus {
  initializing,
  checkingUpdates,
  checkingUpdateError,
  deviceUpdated,
  waitingDashboard,
  downloadingUpdates,
  downloadingUpdateError,
  installingUpdates,
  installingUpdateError,
  installationCompleteWaitingDashboardReboot,
  installationCompleteWaitingReboot,
  unknown,
  none, // 'none' state for when no update is in progress
}

/// Maps string status from MDB to OtaStatus enum
OtaStatus mapOtaStatus(String? status) {
  switch (status) {
    case 'initializing':
      return OtaStatus.initializing;
    case 'checking-updates':
      return OtaStatus.checkingUpdates;
    case 'checking-update-error':
      return OtaStatus.checkingUpdateError;
    case 'device-updated':
      return OtaStatus.deviceUpdated;
    case 'waiting-dashboard':
      return OtaStatus.waitingDashboard;
    case 'downloading-updates':
      return OtaStatus.downloadingUpdates;
    case 'downloading-update-error':
      return OtaStatus.downloadingUpdateError;
    case 'installing-updates':
      return OtaStatus.installingUpdates;
    case 'installing-update-error':
      return OtaStatus.installingUpdateError;
    case 'installation-complete-waiting-dashboard-reboot':
      return OtaStatus.installationCompleteWaitingDashboardReboot;
    case 'installation-complete-waiting-reboot':
      return OtaStatus.installationCompleteWaitingReboot;
    case 'unknown':
      return OtaStatus.unknown;
    default:
      return OtaStatus.none;
  }
}

/// Gets display text for OTA status
String getOtaStatusText(OtaStatus status) {
  switch (status) {
    case OtaStatus.initializing:
      return 'Initializing update...';
    case OtaStatus.checkingUpdates:
      return 'Checking for updates...';
    case OtaStatus.checkingUpdateError:
      return 'Update check failed.';
    case OtaStatus.deviceUpdated:
      return 'Device updated.';
    case OtaStatus.waitingDashboard:
      return 'Waiting for dashboard...';
    case OtaStatus.downloadingUpdates:
      return 'Downloading updates...';
    case OtaStatus.downloadingUpdateError:
      return 'Download failed.';
    case OtaStatus.installingUpdates:
      return 'Installing updates...';
    case OtaStatus.installingUpdateError:
      return 'Installation failed.';
    case OtaStatus.installationCompleteWaitingDashboardReboot:
      return 'Installation complete, waiting for dashboard reboot...';
    case OtaStatus.installationCompleteWaitingReboot:
      return 'Installation complete, waiting for reboot...';
    case OtaStatus.unknown:
    case OtaStatus.none:
      return ''; // Should not be displayed
  }
}

/// Determines if the OTA status is active (i.e., has a valid update status)
bool isOtaActive(String? otaStatusString) {
  final status = mapOtaStatus(otaStatusString);
  return status != OtaStatus.none && 
         status != OtaStatus.unknown &&
         (otaStatusString?.isNotEmpty ?? false);
}

/// Determines if the vehicle is in a state where OTA UI can be shown
bool isVehicleStateAllowingOta(ScooterState vehicleState) {
  // Only show OTA UI in these states
  return vehicleState == ScooterState.parked ||
         vehicleState == ScooterState.readyToDrive ||
         vehicleState == ScooterState.standBy ||
         vehicleState == ScooterState.updating;
}

/// Determines which OTA display mode to use based on vehicle state and OTA status
enum OtaDisplayMode {
  none,
  minimal,
  fullScreen,
}

/// Determines the appropriate OTA display mode
OtaDisplayMode getOtaDisplayMode(ScooterState vehicleState, OtaStatus otaStatus) {
  // If vehicle is updating, always show full screen
  if (vehicleState == ScooterState.updating) {
    return OtaDisplayMode.fullScreen;
  }
  
  // Ready to drive: show minimal overlay for critical statuses
  if (vehicleState == ScooterState.readyToDrive) {
    final criticalStatuses = [
      OtaStatus.downloadingUpdates,
      OtaStatus.downloadingUpdateError,
      OtaStatus.installingUpdates,
      OtaStatus.installingUpdateError,
    ];
    
    return criticalStatuses.contains(otaStatus) 
        ? OtaDisplayMode.minimal 
        : OtaDisplayMode.none;
  }
  
  // Parked: show full screen for most statuses except early initialization
  if (vehicleState == ScooterState.parked) {
    final nonVisibleStatuses = [
      OtaStatus.unknown,
      OtaStatus.initializing,
      OtaStatus.checkingUpdates,
    ];
    
    return nonVisibleStatuses.contains(otaStatus)
        ? OtaDisplayMode.none
        : OtaDisplayMode.fullScreen;
  }
  
  // Other states (standby, etc): show full screen for everything except deviceUpdated
  return otaStatus == OtaStatus.deviceUpdated
      ? OtaDisplayMode.none
      : OtaDisplayMode.fullScreen;
}