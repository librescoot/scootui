// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usb.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $UsbData implements Syncable<UsbData> {
  String get status;
  String get mode;
  String get step;
  get syncSettings => SyncSettings(
      "usb",
      Duration(microseconds: 5000000),
      [
        SyncFieldSettings(
            name: "status",
            variable: "status",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "idle",
            interval: null),
        SyncFieldSettings(
            name: "mode",
            variable: "mode",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "normal",
            interval: null),
        SyncFieldSettings(
            name: "step",
            variable: "step",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
      ],
      "null",
      []);

  @override
  UsbData update(String name, String value) {
    return UsbData(
      status: "status" != name ? status : value,
      mode: "mode" != name ? mode : value,
      step: "step" != name ? step : value,
    );
  }

  @override
  UsbData updateSet(String name, Set<dynamic> value) {
    return UsbData(
      status: status,
      mode: mode,
      step: step,
    );
  }

  List<Object?> get props => [status, mode, step];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("UsbData(");
    buf.writeln("	status = $status");
    buf.writeln("	mode = $mode");
    buf.writeln("	step = $step");
    buf.writeln(")");

    return buf.toString();
  }
}
