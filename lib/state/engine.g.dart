// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

final $_ToggleMap = {
  "on": Toggle.on,
  "off": Toggle.off,
};

abstract mixin class $EngineData implements Syncable<EngineData> {
  Toggle get powerState;
  Toggle get kers;
  String get kersReasonOff;
  num get motorVoltage;
  num get motorCurrent;
  num get rpm;
  num get speed;
  num? get rawSpeed;
  Toggle get throttle;
  String get firmwareVersion;
  double get odometer;
  double get temperature;
  get syncSettings => SyncSettings(
      "engine-ecu",
      Duration(microseconds: 200000),
      [
        SyncFieldSettings(
            name: "powerState",
            variable: "state",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: Duration(microseconds: 10000000)),
        SyncFieldSettings(
            name: "kers",
            variable: "kers",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "on",
            interval: null),
        SyncFieldSettings(
            name: "kersReasonOff",
            variable: "kers-reason-off",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "motorVoltage",
            variable: "motor:voltage",
            type: SyncFieldType.num,
            typeName: "num",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "motorCurrent",
            variable: "motor:current",
            type: SyncFieldType.num,
            typeName: "num",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "rpm",
            variable: "rpm",
            type: SyncFieldType.num,
            typeName: "num",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "speed",
            variable: "speed",
            type: SyncFieldType.num,
            typeName: "num",
            defaultValue: null,
            interval: Duration(microseconds: 250000)),
        SyncFieldSettings(
            name: "rawSpeed",
            variable: "raw-speed",
            type: SyncFieldType.num,
            typeName: "num?",
            defaultValue: null,
            interval: Duration(microseconds: 250000)),
        SyncFieldSettings(
            name: "throttle",
            variable: "throttle",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: null),
        SyncFieldSettings(
            name: "firmwareVersion",
            variable: "fw-version",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "odometer",
            variable: "odometer",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: Duration(microseconds: 5000000)),
        SyncFieldSettings(
            name: "temperature",
            variable: "temperature",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: null),
      ],
      "null",
      []);

  @override
  EngineData update(String name, String value) {
    return EngineData(
      powerState:
          "state" != name ? powerState : $_ToggleMap[value] ?? Toggle.off,
      kers: "kers" != name ? kers : $_ToggleMap[value] ?? Toggle.on,
      kersReasonOff: "kers-reason-off" != name ? kersReasonOff : value,
      motorVoltage: "motor:voltage" != name ? motorVoltage : num.parse(value),
      motorCurrent: "motor:current" != name ? motorCurrent : num.parse(value),
      rpm: "rpm" != name ? rpm : num.parse(value),
      speed: "speed" != name ? speed : num.parse(value),
      rawSpeed: "raw-speed" != name ? rawSpeed : num.parse(value),
      throttle:
          "throttle" != name ? throttle : $_ToggleMap[value] ?? Toggle.off,
      firmwareVersion: "fw-version" != name ? firmwareVersion : value,
      odometer: "odometer" != name ? odometer : double.parse(value),
      temperature: "temperature" != name ? temperature : double.parse(value),
    );
  }

  @override
  EngineData updateSet(String name, Set<dynamic> value) {
    return EngineData(
      powerState: powerState,
      kers: kers,
      kersReasonOff: kersReasonOff,
      motorVoltage: motorVoltage,
      motorCurrent: motorCurrent,
      rpm: rpm,
      speed: speed,
      rawSpeed: rawSpeed,
      throttle: throttle,
      firmwareVersion: firmwareVersion,
      odometer: odometer,
      temperature: temperature,
    );
  }

  List<Object?> get props => [
        powerState,
        kers,
        kersReasonOff,
        motorVoltage,
        motorCurrent,
        rpm,
        speed,
        rawSpeed,
        throttle,
        firmwareVersion,
        odometer,
        temperature
      ];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("EngineData(");
    buf.writeln("	powerState = $powerState");
    buf.writeln("	kers = $kers");
    buf.writeln("	kersReasonOff = $kersReasonOff");
    buf.writeln("	motorVoltage = $motorVoltage");
    buf.writeln("	motorCurrent = $motorCurrent");
    buf.writeln("	rpm = $rpm");
    buf.writeln("	speed = $speed");
    buf.writeln("	rawSpeed = $rawSpeed");
    buf.writeln("	throttle = $throttle");
    buf.writeln("	firmwareVersion = $firmwareVersion");
    buf.writeln("	odometer = $odometer");
    buf.writeln("	temperature = $temperature");
    buf.writeln(")");

    return buf.toString();
  }
}
