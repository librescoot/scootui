// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

final $_GpsStateMap = {
  "off": GpsState.off,
  "searching": GpsState.searching,
  "fix-established": GpsState.fixEstablished,
  "error": GpsState.error,
};

abstract mixin class $GpsData implements Syncable<GpsData> {
  double get latitude;
  double get longitude;
  double get course;
  double get speed;
  double get altitude;
  String get updated;
  String get timestamp;
  GpsState get state;
  get syncSettings => SyncSettings(
      "gps",
      Duration(microseconds: 1000000),
      [
        SyncFieldSettings(
            name: "latitude",
            variable: "latitude",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "longitude",
            variable: "longitude",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "course",
            variable: "course",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "speed",
            variable: "speed",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "altitude",
            variable: "altitude",
            type: SyncFieldType.double,
            typeName: "double",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "updated",
            variable: "updated",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "timestamp",
            variable: "timestamp",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "state",
            variable: "state",
            type: SyncFieldType.enum_,
            typeName: "GpsState",
            defaultValue: "off",
            interval: null),
      ],
      "null",
      []);

  @override
  GpsData update(String name, String value) {
    return GpsData(
      latitude: "latitude" != name ? latitude : double.parse(value),
      longitude: "longitude" != name ? longitude : double.parse(value),
      course: "course" != name ? course : double.parse(value),
      speed: "speed" != name ? speed : double.parse(value),
      altitude: "altitude" != name ? altitude : double.parse(value),
      updated: "updated" != name ? updated : value,
      timestamp: "timestamp" != name ? timestamp : value,
      state: "state" != name ? state : $_GpsStateMap[value] ?? GpsState.off,
    );
  }

  @override
  GpsData updateSet(String name, Set<dynamic> value) {
    return GpsData(
      latitude: latitude,
      longitude: longitude,
      course: course,
      speed: speed,
      altitude: altitude,
      updated: updated,
      timestamp: timestamp,
      state: state,
    );
  }

  List<Object?> get props =>
      [latitude, longitude, course, speed, altitude, updated, timestamp, state];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("GpsData(");
    buf.writeln("	latitude = $latitude");
    buf.writeln("	longitude = $longitude");
    buf.writeln("	course = $course");
    buf.writeln("	speed = $speed");
    buf.writeln("	altitude = $altitude");
    buf.writeln("	updated = $updated");
    buf.writeln("	timestamp = $timestamp");
    buf.writeln("	state = $state");
    buf.writeln(")");

    return buf.toString();
  }
}
