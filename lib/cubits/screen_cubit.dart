import 'dart:async'; // Import dart:async for StreamSubscription

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../cubits/mdb_cubits.dart';
import '../services/settings_service.dart';
import '../env_config.dart';

part 'screen_cubit.freezed.dart';
part 'screen_state.dart';

class ScreenCubit extends Cubit<ScreenState> {
  final SettingsService _settingsService;
  final VehicleSync _vehicleSync;
  late StreamSubscription _settingsSubscription; // Add subscription
  late StreamSubscription _vehicleSubscription;


  ScreenCubit(this._settingsService, this._vehicleSync)
      : super(_getInitialState(_settingsService.getScreenSetting())) {
    // Subscribe to settings updates
    _settingsSubscription = _settingsService.settingsStream.listen((settings) {
      final screenMode = _settingsService.getScreenSetting(); // Get updated screen mode
      emit(_getInitialState(screenMode)); // Emit new state based on updated mode
    });

    // Subscribe to vehicle state updates
    _vehicleSubscription = _vehicleSync.stream.listen((vehicleData) {
      // Vehicle state changes handled here if needed
      // Currently no special handling required since OTA display is handled by ShutdownOverlay
    });
  }

  static ScreenState _getInitialState(String mode) {
    // If CarPlay mode is enabled via environment variable, always start in CarPlay
    if (EnvConfig.isCarPlayMode) {
      return const ScreenState.carplay();
    }

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

  void showMap() {
    // No need to emit here, the stream listener will handle it
    _persistScreenMode('navigation'); // Persist as OEM 'navigation'
  }

  void showAddressSelection() {
    // Directly emit the state without persisting
    emit(const ScreenState.addressSelection());
    // Do not persist address_selection mode as it can cause hanging
  }

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
    return ScreenCubit(settingsService, vehicleSync);
  }

  @override
  Future<void> close() {
    _settingsSubscription.cancel(); // Cancel subscription on close
    _vehicleSubscription.cancel(); // Cancel vehicle subscription on close
    return super.close();
  }
}
