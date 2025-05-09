import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../cubits/mdb_cubits.dart';
import '../state/vehicle.dart';
import '../utils/ota_utils.dart';

part 'ota_cubit.freezed.dart';
part 'ota_state.dart';

class OtaCubit extends Cubit<OtaState> {
  final OtaSync _otaSync;
  final VehicleSync _vehicleSync;
  late StreamSubscription _otaSubscription;
  late StreamSubscription _vehicleSubscription;

  OtaCubit(this._otaSync, this._vehicleSync)
      : super(const OtaState.inactive()) {
    _initialize();
  }

  void _initialize() {
    // Subscribe to OTA status updates
    _otaSubscription = _otaSync.stream.listen((otaData) {
      _updateState(otaData.otaStatus);
    });

    // Subscribe to vehicle state updates
    _vehicleSubscription = _vehicleSync.stream.listen((vehicleData) {
      // Re-evaluate OTA state when vehicle state changes
      _updateState(_otaSync.state.otaStatus);
    });
  }

  void _updateState(String? otaStatusString) {
    final otaStatus = mapOtaStatus(otaStatusString);
    final vehicleState = _vehicleSync.state.state;

    // Always hide if OTA status is none/empty or vehicle state doesn't allow showing OTA
    if (!isOtaActive(otaStatusString) || !isVehicleStateAllowingOta(vehicleState)) {
      emit(const OtaState.inactive());
      return;
    }

    // Get the appropriate display mode for the current state
    final displayMode = getOtaDisplayMode(vehicleState, otaStatus);
    final statusText = getOtaStatusText(otaStatus);

    // Emit the appropriate state based on the display mode
    switch (displayMode) {
      case OtaDisplayMode.none:
        emit(const OtaState.inactive());

      case OtaDisplayMode.minimal:
        emit(OtaState.minimal(status: otaStatus, statusText: statusText));

      case OtaDisplayMode.fullScreen:
        // Use semi-transparent background only in parked mode
        final isParked = vehicleState == ScooterState.parked;
        emit(OtaState.fullScreen(
          status: otaStatus,
          statusText: statusText,
          isParked: isParked,
        ));
    }
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
