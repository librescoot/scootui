import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../cubits/mdb_cubits.dart';
import '../services/toast_service.dart';
import '../state/vehicle.dart';

part 'ota_cubit.freezed.dart';
part 'ota_state.dart';

// Define possible OTA update states
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
  none, // Add a 'none' state for when no update is in progress
}

// Helper function to map string status from MDB to OtaStatus enum
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

// Helper function to get display text for OTA status
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

class OtaCubit extends Cubit<OtaState> {
  final OtaSync _otaSync;
  final VehicleSync _vehicleSync;
  late StreamSubscription _otaSubscription;
  late StreamSubscription _vehicleSubscription;

  String? _lastDbcStatus;
  String? _lastDbcError;

  OtaCubit(this._otaSync, this._vehicleSync) : super(const OtaState.inactive()) {
    _initialize();
  }

  void _initialize() {
    // Subscribe to OTA status updates
    _otaSubscription = _otaSync.stream.listen((otaData) {
      _updateState();
    });

    // Subscribe to vehicle state updates
    _vehicleSubscription = _vehicleSync.stream.listen((vehicleData) {
      // Re-evaluate OTA state when vehicle state changes
      _updateState();
    });
  }

  void _updateState() {
    final vehicleState = _vehicleSync.state.state;
    final isReadyToDrive = vehicleState == ScooterState.readyToDrive;
    final isParked = vehicleState == ScooterState.parked;
    final isUnlocked = isReadyToDrive || isParked;

    // Get DBC-specific status field which is populated by the update-service
    final dbcStatus = _otaSync.state.dbcStatus;
    final dbcError = _otaSync.state.dbcError;
    final dbcErrorMessage = _otaSync.state.dbcErrorMessage;
    final dbcUpdateVersion = _otaSync.state.dbcUpdateVersion;

    // Show toasts for state transitions
    _handleStatusChange(dbcStatus, dbcUpdateVersion);
    _handleErrorChange(dbcError, dbcErrorMessage, dbcUpdateVersion);

    // Check if DBC updates are ongoing
    final dbcDownloading = dbcStatus == "downloading";
    final dbcInstalling = dbcStatus == "installing";
    final dbcUpdating = dbcDownloading || dbcInstalling;

    // Only show status bar icon when unlocked and DBC updating
    if (dbcUpdating && isUnlocked) {
      emit(OtaState.statusBar(
        status: dbcDownloading ? OtaStatus.downloadingUpdates : OtaStatus.installingUpdates,
        statusText: dbcDownloading ? 'Downloading updates...' : 'Installing updates...',
      ));
      return;
    }

    // For all other cases, emit inactive - let ShutdownOverlay handle display
    emit(const OtaState.inactive());
  }

  void _handleStatusChange(String status, String version) {
    if (_lastDbcStatus == status || status.isEmpty) return;

    _lastDbcStatus = status;
    final versionText = version.isNotEmpty ? ' Librescoot $version' : '';

    switch (status) {
      case 'downloading':
        ToastService.showInfo('Downloading$versionText update');
        break;
      case 'installing':
        ToastService.showInfo('Installing$versionText update');
        break;
      case 'rebooting':
        ToastService.showWarning('Update installed. Waiting for reboot');
        break;
    }
  }

  void _handleErrorChange(String error, String errorMessage, String version) {
    if (_lastDbcError == error || error.isEmpty) return;

    _lastDbcError = error;
    final versionText = version.isNotEmpty ? ' Librescoot $version' : '';
    final message = errorMessage.isNotEmpty
        ? 'Update failed: $errorMessage'
        : 'Update$versionText failed';

    ToastService.showError(message);
  }

  static OtaCubit create(BuildContext context) {
    return OtaCubit(
      context.read<OtaSync>(),
      context.read<VehicleSync>(),
    );
  }

  @override
  Future<void> close() {
    _otaSubscription.cancel();
    _vehicleSubscription.cancel();
    return super.close();
  }
}
