import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/engine.dart';
import '../state/vehicle.dart';
import 'mdb_cubits.dart';

@immutable
class TripState {
  final double distanceTravelled;
  final DateTime startTime;
  final Duration activeDrivingTime;

  const TripState(this.distanceTravelled, this.startTime, this.activeDrivingTime);
  
  Duration get tripDuration => activeDrivingTime;
  
  double get averageSpeed {
    final durationSeconds = activeDrivingTime.inSeconds;
    if (durationSeconds == 0 || distanceTravelled == 0) return 0.0;
    return (distanceTravelled / durationSeconds) * 3.6;
  }
}

class TripCubit extends Cubit<TripState> {
  late final StreamSubscription<EngineData> _engineSub;
  late final StreamSubscription<VehicleData> _vehicleSub;
  Timer? _updateTimer;
  int _timerTicks = 0;

  EngineData? _tripStart;
  DateTime? _tripStartTime;
  final Stopwatch _drivingStopwatch = Stopwatch();

  EngineData? _latest;
  bool _isReadyToDrive = false;

  TripCubit(Stream<EngineData> engineStream, Stream<VehicleData> vehicleStream) 
      : super(TripState(0, DateTime.now(), Duration.zero)) {
    _engineSub = engineStream.listen(_onEngineData);
    _vehicleSub = vehicleStream.listen(_onVehicleData);
  }

  void _onEngineData(EngineData data) {
    // Always update latest data for tracking purposes
    _latest = data;

    // ignore data if the odometer is not set
    if (data.odometer > 0) {
      // Initialize trip start if not set
      if (_tripStart == null) {
        _tripStart = data;
        _tripStartTime = DateTime.now();
        // Start stopwatch if already ready to drive
        if (_isReadyToDrive && !_drivingStopwatch.isRunning) {
          _drivingStopwatch.start();
        }
      }
      
      // Check for odometer reset
      if (data.odometer < _tripStart!.odometer) {
        _tripStart = data;
        _tripStartTime = DateTime.now();
        _drivingStopwatch.reset();
        if (_isReadyToDrive) {
          _drivingStopwatch.start();
        }
      }

      // Only calculate distance and emit when ready to drive
      if (_isReadyToDrive) {
        final distance = data.odometer - _tripStart!.odometer;
        emit(TripState(distance, _tripStartTime!, _drivingStopwatch.elapsed));
      }
    }
  }

  void _onVehicleData(VehicleData data) {
    final wasReadyToDrive = _isReadyToDrive;
    _isReadyToDrive = data.state == ScooterState.readyToDrive;
    
    // Start/stop driving session and timer based on ready-to-drive state
    if (_isReadyToDrive && !wasReadyToDrive) {
      _startDrivingSession();
      _startUpdateTimer();
    } else if (!_isReadyToDrive && wasReadyToDrive) {
      _endDrivingSession();
      _stopUpdateTimer();
    }
  }

  void _startDrivingSession() {
    _drivingStopwatch.start();
  }

  void _endDrivingSession() {
    _drivingStopwatch.stop();
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _timerTicks = 0;
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_tripStartTime != null) {
        _timerTicks++;

        // Always emit to update duration (every second)
        // But only update when ticks are divisible by 3 for smoother average speed
        if (_timerTicks % 3 == 0 || _timerTicks == 1) {
          final distance = _latest != null && _tripStart != null
              ? _latest!.odometer - _tripStart!.odometer
              : 0.0;
          emit(TripState(distance, _tripStartTime!, _drivingStopwatch.elapsed));
        } else {
          // Just update duration, keep same distance for stable average speed
          final currentState = state;
          emit(TripState(currentState.distanceTravelled, _tripStartTime!, _drivingStopwatch.elapsed));
        }
      }
    });
  }

  void _stopUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void reset() {
    _tripStart = _latest;
    _tripStartTime = DateTime.now();
    _drivingStopwatch.reset();
    if (_isReadyToDrive) {
      _drivingStopwatch.start();
    }
    emit(TripState(0, _tripStartTime!, Duration.zero));
  }

  @override
  Future<void> close() async {
    await _engineSub.cancel();
    await _vehicleSub.cancel();
    _updateTimer?.cancel();
    return super.close();
  }

  static TripState watch(BuildContext context) => context.watch<TripCubit>().state;

  static TripCubit create(BuildContext context) => TripCubit(
    context.read<EngineSync>().stream,
    context.read<VehicleSync>().stream,
  );
}
