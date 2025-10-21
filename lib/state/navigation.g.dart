// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $NavigationData implements Syncable<NavigationData> {
  String get latitude;
  String get longitude;
  String get address;
  String get timestamp;
  String get destination;
  get syncSettings => SyncSettings(
      "navigation",
      Duration(microseconds: 5000000),
      [
        SyncFieldSettings(
            name: "latitude",
            variable: "latitude",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "longitude",
            variable: "longitude",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
        SyncFieldSettings(
            name: "address",
            variable: "address",
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
            name: "destination",
            variable: "destination",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: null,
            interval: null),
      ],
      "null",
      []);

  @override
  NavigationData update(String name, String value) {
    return NavigationData(
      latitude: "latitude" != name ? latitude : value,
      longitude: "longitude" != name ? longitude : value,
      address: "address" != name ? address : value,
      timestamp: "timestamp" != name ? timestamp : value,
      destination: "destination" != name ? destination : value,
    );
  }

  @override
  NavigationData updateSet(String name, Set<dynamic> value) {
    return NavigationData(
      latitude: latitude,
      longitude: longitude,
      address: address,
      timestamp: timestamp,
      destination: destination,
    );
  }

  List<Object?> get props =>
      [latitude, longitude, address, timestamp, destination];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("NavigationData(");
    buf.writeln("	latitude = $latitude");
    buf.writeln("	longitude = $longitude");
    buf.writeln("	address = $address");
    buf.writeln("	timestamp = $timestamp");
    buf.writeln("	destination = $destination");
    buf.writeln(")");

    return buf.toString();
  }
}
