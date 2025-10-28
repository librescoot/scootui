// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carplay_availability.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $CarPlayAvailabilityData
    implements Syncable<CarPlayAvailabilityData> {
  String get dongle_available;
  String get device_connected;
  String get device_type;
  String get error;
  get syncSettings => SyncSettings(
      "carplay",
      Duration(microseconds: 2000000),
      [
        SyncFieldSettings(
            name: "dongle_available",
            variable: "dongle_available",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "device_connected",
            variable: "device_connected",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "device_type",
            variable: "device_type",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "error",
            variable: "error",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
      ],
      "null",
      []);

  @override
  CarPlayAvailabilityData update(String name, String value) {
    return CarPlayAvailabilityData(
      dongle_available: "dongle_available" != name ? dongle_available : value,
      device_connected: "device_connected" != name ? device_connected : value,
      device_type: "device_type" != name ? device_type : value,
      error: "error" != name ? error : value,
    );
  }

  @override
  CarPlayAvailabilityData updateSet(String name, Set<dynamic> value) {
    return CarPlayAvailabilityData(
      dongle_available: dongle_available,
      device_connected: device_connected,
      device_type: device_type,
      error: error,
    );
  }

  List<Object?> get props =>
      [dongle_available, device_connected, device_type, error];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("CarPlayAvailabilityData(");
    buf.writeln("	dongle_available = $dongle_available");
    buf.writeln("	device_connected = $device_connected");
    buf.writeln("	device_type = $device_type");
    buf.writeln("	error = $error");
    buf.writeln(")");

    return buf.toString();
  }
}
