import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/toast_service.dart';
import '../state/battery.dart';
import '../state/cb_battery.dart';
import '../state/engine.dart';
import 'mdb_cubits.dart';

const _engineTempThreshold = 4;
const _batteryTempThreshold = 4;
const _cbBatteryTempThreshold = 10;

class LowTemperatureWarningCubit extends Cubit<bool> {
  final Stream<EngineData> _engineStream;
  final Stream<BatteryData> _battery0Stream;
  final Stream<CbBatteryData> _cbBatteryStream;

  StreamSubscription<EngineData>? _engineSub;
  StreamSubscription<BatteryData>? _battery0Sub;
  StreamSubscription<CbBatteryData>? _cbBatterySub;

  bool _hasShownWarning = false;
  Timer? _debounceTimer;

  EngineData? _latestEngine;
  BatteryData? _latestBattery0;
  CbBatteryData? _latestCbBattery;

  LowTemperatureWarningCubit({
    required Stream<EngineData> engineStream,
    required Stream<BatteryData> battery0Stream,
    required Stream<CbBatteryData> cbBatteryStream,
  })  : _engineStream = engineStream,
        _battery0Stream = battery0Stream,
        _cbBatteryStream = cbBatteryStream,
        super(false);

  static LowTemperatureWarningCubit create(BuildContext context) {
    return LowTemperatureWarningCubit(
      engineStream: context.read<EngineSync>().stream,
      battery0Stream: context.read<Battery0Sync>().stream,
      cbBatteryStream: context.read<CbBatterySync>().stream,
    )..start();
  }

  void start() {
    _engineSub = _engineStream.listen((data) {
      _latestEngine = data;
      _scheduleCheck();
    });

    _battery0Sub = _battery0Stream.listen((data) {
      _latestBattery0 = data;
      _scheduleCheck();
    });

    _cbBatterySub = _cbBatteryStream.listen((data) {
      _latestCbBattery = data;
      _scheduleCheck();
    });
  }

  void _scheduleCheck() {
    if (_hasShownWarning) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), _checkTemperatures);
  }

  void _checkTemperatures() {
    if (_hasShownWarning) return;

    final engine = _latestEngine;
    final battery0 = _latestBattery0;
    final cbBattery = _latestCbBattery;

    // Wait until we have data from at least one source
    if (engine == null && battery0 == null && cbBattery == null) return;

    final lowTempSources = <String>[];

    // Check engine temperature (engine-ecu temperature)
    if (engine != null && engine.temperature <= _engineTempThreshold && engine.temperature != 0) {
      lowTempSources.add('Motor');
    }

    // Check battery:0 temperature:2 and temperature:3
    if (battery0 != null && battery0.present) {
      if (battery0.temperature2 <= _batteryTempThreshold && battery0.temperature2 != 0) {
        lowTempSources.add('Battery');
      } else if (battery0.temperature3 <= _batteryTempThreshold && battery0.temperature3 != 0) {
        lowTempSources.add('Battery');
      }
    }

    // Check cb-battery temperature
    if (cbBattery != null && cbBattery.present && cbBattery.temperature <= _cbBatteryTempThreshold && cbBattery.temperature != 0) {
      lowTempSources.add('12V Battery');
    }

    if (lowTempSources.isNotEmpty) {
      _hasShownWarning = true;
      emit(true);
      ToastService.showWarning('Low Temperatures - Ride Carefully');
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _engineSub?.cancel();
    _battery0Sub?.cancel();
    _cbBatterySub?.cancel();
    return super.close();
  }
}
