// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $GpsData implements Syncable<GpsData> {
  double get latitude;
  double get longitude;
  double get course;
  double get speed;
  double get altitude;
  String get timestamp;
  get syncSettings => SyncSettings(
      "gps",
      Duration(microseconds: 3000000),
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
            name: "timestamp",
            variable: "timestamp",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
      ],
      "null");

  @override
  GpsData update(String name, String value) {
    return GpsData(
      latitude: "latitude" != name ? latitude : double.parse(value),
      longitude: "longitude" != name ? longitude : double.parse(value),
      course: "course" != name ? course : double.parse(value),
      speed: "speed" != name ? speed : double.parse(value),
      altitude: "altitude" != name ? altitude : double.parse(value),
      timestamp: "timestamp" != name ? timestamp : value,
    );
  }

  List<Object?> get props =>
      [latitude, longitude, course, speed, altitude, timestamp];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("GpsData(");
    buf.writeln("	latitude = $latitude");
    buf.writeln("	longitude = $longitude");
    buf.writeln("	course = $course");
    buf.writeln("	speed = $speed");
    buf.writeln("	altitude = $altitude");
    buf.writeln("	timestamp = $timestamp");
    buf.writeln(")");

    return buf.toString();
  }
}
