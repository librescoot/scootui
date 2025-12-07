// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_standby.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $AutoStandbyData implements Syncable<AutoStandbyData> {
  int get autoStandbyRemaining;
  get syncSettings => SyncSettings(
      "vehicle",
      Duration(microseconds: 500000),
      [
        SyncFieldSettings(
            name: "autoStandbyRemaining",
            variable: "auto-standby-remaining",
            type: SyncFieldType.int,
            typeName: "int",
            defaultValue: null,
            interval: null),
      ],
      "null",
      []);

  @override
  AutoStandbyData update(String name, String value) {
    return AutoStandbyData(
      autoStandbyRemaining: "auto-standby-remaining" != name
          ? autoStandbyRemaining
          : int.parse(value),
    );
  }

  @override
  AutoStandbyData updateSet(String name, Set<dynamic> value) {
    return AutoStandbyData(
      autoStandbyRemaining: autoStandbyRemaining,
    );
  }

  List<Object?> get props => [autoStandbyRemaining];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("AutoStandbyData(");
    buf.writeln("	autoStandbyRemaining = $autoStandbyRemaining");
    buf.writeln(")");

    return buf.toString();
  }
}
