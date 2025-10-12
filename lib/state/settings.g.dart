// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

final $_MapTypeMap = {
  "online": MapType.online,
  "offline": MapType.offline,
};

final $_MapRenderModeMap = {
  "vector": MapRenderMode.vector,
  "raster": MapRenderMode.raster,
};

abstract mixin class $SettingsData implements Syncable<SettingsData> {
  String? get showRawSpeed;
  String? get showGps;
  String? get showBluetooth;
  String? get showCloud;
  String? get showInternet;
  MapType get mapType;
  MapRenderMode get mapRenderMode;
  get syncSettings => SyncSettings(
      "settings",
      Duration(microseconds: 5000000),
      [
        SyncFieldSettings(
            name: "showRawSpeed",
            variable: "dashboard.show-raw-speed",
            type: SyncFieldType.string,
            typeName: "String?",
            defaultValue: "false",
            interval: null),
        SyncFieldSettings(
            name: "showGps",
            variable: "dashboard.show-gps",
            type: SyncFieldType.string,
            typeName: "String?",
            defaultValue: "error",
            interval: null),
        SyncFieldSettings(
            name: "showBluetooth",
            variable: "dashboard.show-bluetooth",
            type: SyncFieldType.string,
            typeName: "String?",
            defaultValue: "active-or-error",
            interval: null),
        SyncFieldSettings(
            name: "showCloud",
            variable: "dashboard.show-cloud",
            type: SyncFieldType.string,
            typeName: "String?",
            defaultValue: "error",
            interval: null),
        SyncFieldSettings(
            name: "showInternet",
            variable: "dashboard.show-internet",
            type: SyncFieldType.string,
            typeName: "String?",
            defaultValue: "always",
            interval: null),
        SyncFieldSettings(
            name: "mapType",
            variable: "dashboard.map.type",
            type: SyncFieldType.enum_,
            typeName: "MapType",
            defaultValue: "offline",
            interval: null),
        SyncFieldSettings(
            name: "mapRenderMode",
            variable: "dashboard.map.render-mode",
            type: SyncFieldType.enum_,
            typeName: "MapRenderMode",
            defaultValue: "raster",
            interval: null),
      ],
      "null",
      []);

  @override
  SettingsData update(String name, String value) {
    return SettingsData(
      showRawSpeed: "dashboard.show-raw-speed" != name ? showRawSpeed : value,
      showGps: "dashboard.show-gps" != name ? showGps : value,
      showBluetooth: "dashboard.show-bluetooth" != name ? showBluetooth : value,
      showCloud: "dashboard.show-cloud" != name ? showCloud : value,
      showInternet: "dashboard.show-internet" != name ? showInternet : value,
      mapType: "dashboard.map.type" != name
          ? mapType
          : $_MapTypeMap[value] ?? MapType.offline,
      mapRenderMode: "dashboard.map.render-mode" != name
          ? mapRenderMode
          : $_MapRenderModeMap[value] ?? MapRenderMode.raster,
    );
  }

  @override
  SettingsData updateSet(String name, Set<dynamic> value) {
    return SettingsData(
      showRawSpeed: showRawSpeed,
      showGps: showGps,
      showBluetooth: showBluetooth,
      showCloud: showCloud,
      showInternet: showInternet,
      mapType: mapType,
      mapRenderMode: mapRenderMode,
    );
  }

  List<Object?> get props => [
        showRawSpeed,
        showGps,
        showBluetooth,
        showCloud,
        showInternet,
        mapType,
        mapRenderMode
      ];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("SettingsData(");
    buf.writeln("	showRawSpeed = $showRawSpeed");
    buf.writeln("	showGps = $showGps");
    buf.writeln("	showBluetooth = $showBluetooth");
    buf.writeln("	showCloud = $showCloud");
    buf.writeln("	showInternet = $showInternet");
    buf.writeln("	mapType = $mapType");
    buf.writeln("	mapRenderMode = $mapRenderMode");
    buf.writeln(")");

    return buf.toString();
  }
}
