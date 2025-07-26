import 'dart:async'; // Import dart:async for StreamSubscription

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/ota_cubit.dart';
import '../services/settings_service.dart';
import '../state/vehicle.dart';

part 'screen_cubit.freezed.dart';
part 'screen_state.dart';

class ScreenCubit extends Cubit<ScreenState> {
  final SettingsService _settingsService;
  final OtaCubit? _otaCubit;
  final VehicleSync _vehicleSync;
  late StreamSubscription _settingsSubscription; // Add subscription
  StreamSubscription? _otaSubscription;
  late StreamSubscription _vehicleSubscription;

  // Remember the screen state before shutdown/OTA transitions
  ScreenState? _previousNormalState;

  ScreenCubit(this._settingsService, this._vehicleSync, [this._otaCubit])
      : super(_getInitialState(_settingsService.getScreenSetting())) {
    // Subscribe to settings updates
    _settingsSubscription = _settingsService.settingsStream.listen((settings) {
      final screenMode =
          _settingsService.getScreenSetting(); // Get updated screen mode
      emit(
          _getInitialState(screenMode)); // Emit new state based on updated mode
    });

    // Subscribe to vehicle state updates
    _vehicleSubscription = _vehicleSync.stream.listen((vehicleData) {
      final currentState = state;
      final isOtaFullScreen = _otaCubit?.state is OtaFullScreen;

      // Store current normal state if we're about to enter a special state
      if (currentState is ScreenCluster || currentState is ScreenMap) {
        if (vehicleData.state == ScooterState.updating || isOtaFullScreen) {
          _previousNormalState = currentState;
        }
      }

      // Priority order: OTA Full Screen > Shutting Down > Vehicle Updating > Normal states

      // Highest priority: OTA is handled by OTA subscription, don't override
      if (isOtaFullScreen) {
        return; // Let OTA subscription handle screen changes
      }

      // Second priority: Shutting down state - DON'T change screen, let overlay handle it
      // if (vehicleData.state == ScooterState.shuttingDown) {
      //   emit(const ScreenState.shuttingDown());
      //   return;
      // }

      // Third priority: Vehicle updating state
      if (vehicleData.state == ScooterState.updating) {
        emit(const ScreenState.ota());
        return;
      }

      // When exiting special states, restore previous state if available
      if (currentState is ScreenOta &&
          vehicleData.state != ScooterState.updating) {
        // Restore previous state or default to cluster
        final stateToRestore =
            _previousNormalState ?? const ScreenState.cluster();
        _previousNormalState = null; // Clear the stored state
        emit(stateToRestore);
      }
    });

    // Subscribe to OTA state updates if OtaCubit is provided
    if (_otaCubit != null) {
      _otaSubscription = _otaCubit!.stream.listen((otaState) {
        // When OTA enters full screen mode, switch to OTA screen
        if (otaState is OtaFullScreen) {
          emit(const ScreenState.ota());
        } else if (state is ScreenOta && otaState is! OtaFullScreen) {
          // When OTA exits full screen mode, switch back to cluster
          emit(const ScreenState.cluster());
        }
      });
    }
  }

  static ScreenState _getInitialState(String mode) {
    switch (mode) {
      case 'navigation': // Map OEM 'navigation' to our 'map'
        return const ScreenState.map();
      case 'address_selection': // Default to cluster if address_selection is persisted
        return const ScreenState.cluster();
      case 'debug': // Handle debug mode
        return const ScreenState.debug();
      case 'speedometer': // Map OEM 'speedometer' to our 'cluster'
      default:
        return const ScreenState.cluster();
    }
  }

  void showCluster() {
    // No need to emit here, the stream listener will handle it
    _persistScreenMode('speedometer'); // Persist as OEM 'speedometer'
  }

  void showOta() => emit(const ScreenState.ota());
  void showAddressSelection() => emit(const ScreenState.addressSelection());
  void showDownloadMap() => emit(const ScreenState.downloadMap());

  void showMap() => emit(const ScreenState.map());

  void showDebug() {
    // Directly emit the debug state without persisting
    emit(const ScreenState.debug());
    // Debug mode should not be persisted
  }

  void _persistScreenMode(String mode) {
    _settingsService.updateScreenSetting(mode); // Use the provided mode string
  }

  static ScreenCubit create(BuildContext context) {
    final settingsService = context.read<SettingsService>();
    final vehicleSync = context.read<VehicleSync>();
    final otaCubit = context.read<OtaCubit>();
    return ScreenCubit(settingsService, vehicleSync, otaCubit);
  }

  @override
  Future<void> close() {
    _settingsSubscription.cancel(); // Cancel subscription on close
    _vehicleSubscription.cancel(); // Cancel vehicle subscription on close
    _otaSubscription?.cancel(); // Cancel OTA subscription if it exists
    return super.close();
  }
}
