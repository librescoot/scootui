import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/vehicle.dart';
import 'mdb_cubits.dart';

enum ShutdownStatus {
  hidden,
  shuttingDown,
  exiting,
  shutdownComplete,
  backgroundProcessing,
  suspending,
  hibernatingImminent,
  suspendingImminent,
  blackout,
}

class ShutdownState {
  final ShutdownStatus status;

  const ShutdownState({required this.status});

  bool get isVisible => status != ShutdownStatus.hidden;
  bool get isFullOverlay =>
      status == ShutdownStatus.shuttingDown ||
      status == ShutdownStatus.exiting ||
      status == ShutdownStatus.shutdownComplete ||
      status == ShutdownStatus.blackout;
  bool get isBackgroundIndicator =>
      status == ShutdownStatus.backgroundProcessing;
  bool get isBlackout =>
      status == ShutdownStatus.blackout ||
      status == ShutdownStatus.exiting;
}

class ShutdownCubit extends Cubit<ShutdownState> {
  static ShutdownCubit? _instance;

  late final StreamSubscription<VehicleData> _vehicleSub;
  Timer? _blackoutTimer;

  ScooterState? _previousState;
  bool _wasUserInitiatedShutdown = false;

  ShutdownCubit({
    required Stream<VehicleData> vehicleStream,
  }) : super(const ShutdownState(status: ShutdownStatus.hidden)) {
    _instance = this;
    _vehicleSub = vehicleStream.listen(_onVehicleData);
  }

  static void forceBlackout() => _instance?._doBlackout();

  void _doBlackout() {
    _blackoutTimer?.cancel();
    _blackoutTimer = null;
    if (!isClosed) emit(const ShutdownState(status: ShutdownStatus.blackout));
  }

  void signalAnimationComplete() {
    if (state.status == ShutdownStatus.blackout) return;
    _blackoutTimer?.cancel();
    _blackoutTimer = null;
    if (!isClosed) {
      emit(const ShutdownState(status: ShutdownStatus.exiting));
    }
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
        if (_wasUserInitiatedShutdown) {
          newStatus = ShutdownStatus.shutdownComplete;
        } else {
          newStatus = ShutdownStatus.backgroundProcessing;
        }
        break;
      case ScooterState.parked:
      case ScooterState.readyToDrive:
        _wasUserInitiatedShutdown = false;
        newStatus = ShutdownStatus.hidden;
        break;
      default:
        newStatus = ShutdownStatus.hidden;
    }

    _previousState = currentState;

    if (state.status == ShutdownStatus.blackout) return;

    if (state.status != newStatus) {
      emit(ShutdownState(status: newStatus));
    }
  }

  @override
  Future<void> close() async {
    _blackoutTimer?.cancel();
    _instance = null;
    await _vehicleSub.cancel();
    return super.close();
  }

  static ShutdownState watch(BuildContext context) =>
      context.watch<ShutdownCubit>().state;

  static ShutdownCubit create(BuildContext context) => ShutdownCubit(
        vehicleStream: context.read<VehicleSync>().stream,
      );
}
