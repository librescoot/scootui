import 'package:equatable/equatable.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';
import './enums.dart';

part 'engine.g.dart';

@StateClass("engine-ecu", Duration(seconds: 1))
class EngineData extends Equatable with $EngineData {
  @override
  @StateField(name: "state", defaultValue: "off", interval: Duration(seconds: 10))
  final Toggle powerState;

  @override
  @StateField(name: "kers", defaultValue: "on")
  final Toggle kers;

  @override
  @StateField()
  final String kersReasonOff;

  @override
  @StateField(name: "motor:voltage")
  final num motorVoltage;

  @override
  @StateField(name: "motor:current")
  final num motorCurrent;

  @override
  @StateField()
  final num rpm;

  @override
  @StateField(interval: Duration(milliseconds: 100))
  final num speed;

  @override
  @StateField(name: "raw-speed", interval: Duration(milliseconds: 100))
  final num? rawSpeed;

  @override
  @StateField(defaultValue: "off")
  final Toggle throttle;

  @override
  @StateField(name: "fw-version")
  final String firmwareVersion;

  @override
  @StateField(interval: Duration(seconds: 5))
  final double odometer;

  @override
  @StateField()
  final double temperature;

  double get powerOutput => motorVoltage * motorCurrent / 1000000;

  EngineData({
    this.powerState = Toggle.off,
    this.kers = Toggle.on,
    this.kersReasonOff = "none",
    this.speed = 0,
    this.rawSpeed,
    this.firmwareVersion = "",
    this.motorCurrent = 0,
    this.motorVoltage = 0,
    this.odometer = 0,
    this.rpm = 0,
    this.temperature = 0,
    this.throttle = Toggle.off,
  });
}
