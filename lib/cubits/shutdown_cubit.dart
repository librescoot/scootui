import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/vehicle.dart';
import 'mdb_cubits.dart';

enum ShutdownStatus {
  hidden,
  shuttingDown,
  shutdownComplete,
  backgroundProcessing,
  suspending,
  hibernatingImminent,
  suspendingImminent
}

class ShutdownState {
  final ShutdownStatus status;

  const ShutdownState({required this.status});

  bool get isVisible => status != ShutdownStatus.hidden;
  bool get isFullOverlay =>
      status == ShutdownStatus.shuttingDown ||
      status == ShutdownStatus.shutdownComplete;
  bool get isBackgroundIndicator =>
      status == ShutdownStatus.backgroundProcessing;
}

class ShutdownCubit extends Cubit<ShutdownState> {
  late final StreamSubscription<VehicleData> _vehicleSub;

  ScooterState? _previousState;
  bool _wasUserInitiatedShutdown = false;

  ShutdownCubit({
    required Stream<VehicleData> vehicleStream,
  }) : super(const ShutdownState(status: ShutdownStatus.hidden)) {
    _vehicleSub = vehicleStream.listen(_onVehicleData);
  }

  void _onVehicleData(VehicleData data) {
    final currentState = data.state;

    // Detect user-initiated shutdown transitions
    if (_previousState != null &&
        (_previousState == ScooterState.parked ||
            _previousState == ScooterState.readyToDrive) &&
        currentState == ScooterState.shuttingDown) {
      _wasUserInitiatedShutdown = true;
    }

    // Map scooter state to shutdown status
    ShutdownStatus newStatus;

    switch (currentState) {
      case ScooterState.shuttingDown:
        newStatus = ShutdownStatus.shuttingDown;
        break;
      case ScooterState.suspending:
        newStatus = ShutdownStatus.suspending;
        break;
      case ScooterState.hibernatingImminent:
        newStatus = ShutdownStatus.hibernatingImminent;
        break;
      case ScooterState.suspendingImminent:
        newStatus = ShutdownStatus.suspendingImminent;
        break;
      case ScooterState.standBy:
        // If we came from a user-initiated shutdown, keep showing shutdown overlay
        if (_wasUserInitiatedShutdown) {
          newStatus = ShutdownStatus.shutdownComplete;
        } else {
          // If we're in standBy but didn't come from parked/ready-to-drive, show background processing indicator
          newStatus = ShutdownStatus.backgroundProcessing;
        }
        break;
      case ScooterState.parked:
      case ScooterState.readyToDrive:
        // Clear user shutdown flag when returning to active states
        _wasUserInitiatedShutdown = false;
        newStatus = ShutdownStatus.hidden;
        break;
      default:
        newStatus = ShutdownStatus.hidden;
    }

    // Update previous state for next transition
    _previousState = currentState;

    // Only emit if status changed
    if (state.status != newStatus) {
      emit(ShutdownState(status: newStatus));
    }
  }

  @override
  Future<void> close() async {
    await _vehicleSub.cancel();
    return super.close();
  }

  static ShutdownState watch(BuildContext context) =>
      context.watch<ShutdownCubit>().state;

  static ShutdownCubit create(BuildContext context) => ShutdownCubit(
        vehicleStream: context.read<VehicleSync>().stream,
      );
}
