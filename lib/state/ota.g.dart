// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ota.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $OtaData implements Syncable<OtaData> {
  String get otaStatus;
  String get updateType;
  String get dbcStatus;
  String get mdbStatus;
  String get dbcUpdateVersion;
  String get dbcError;
  String get dbcErrorMessage;
  String get dbcDownloadProgress;
  get syncSettings => SyncSettings(
      "ota",
      Duration(microseconds: 5000000),
      [
        SyncFieldSettings(
            name: "otaStatus",
            variable: "status",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "unknown",
            interval: null),
        SyncFieldSettings(
            name: "updateType",
            variable: "update-type",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "none",
            interval: null),
        SyncFieldSettings(
            name: "dbcStatus",
            variable: "status:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "mdbStatus",
            variable: "status:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "dbcUpdateVersion",
            variable: "update-version:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "dbcError",
            variable: "error:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "dbcErrorMessage",
            variable: "error-message:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "dbcDownloadProgress",
            variable: "download-progress:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "0",
            interval: null),
      ],
      "null",
      []);

  @override
  OtaData update(String name, String value) {
    return OtaData(
      otaStatus: "status" != name ? otaStatus : value,
      updateType: "update-type" != name ? updateType : value,
      dbcStatus: "status:dbc" != name ? dbcStatus : value,
      mdbStatus: "status:mdb" != name ? mdbStatus : value,
      dbcUpdateVersion: "update-version:dbc" != name ? dbcUpdateVersion : value,
      dbcError: "error:dbc" != name ? dbcError : value,
      dbcErrorMessage: "error-message:dbc" != name ? dbcErrorMessage : value,
      dbcDownloadProgress:
          "download-progress:dbc" != name ? dbcDownloadProgress : value,
    );
  }

  @override
  OtaData updateSet(String name, Set<dynamic> value) {
    return OtaData(
      otaStatus: otaStatus,
      updateType: updateType,
      dbcStatus: dbcStatus,
      mdbStatus: mdbStatus,
      dbcUpdateVersion: dbcUpdateVersion,
      dbcError: dbcError,
      dbcErrorMessage: dbcErrorMessage,
      dbcDownloadProgress: dbcDownloadProgress,
    );
  }

  List<Object?> get props => [
        otaStatus,
        updateType,
        dbcStatus,
        mdbStatus,
        dbcUpdateVersion,
        dbcError,
        dbcErrorMessage,
        dbcDownloadProgress
      ];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("OtaData(");
    buf.writeln("	otaStatus = $otaStatus");
    buf.writeln("	updateType = $updateType");
    buf.writeln("	dbcStatus = $dbcStatus");
    buf.writeln("	mdbStatus = $mdbStatus");
    buf.writeln("	dbcUpdateVersion = $dbcUpdateVersion");
    buf.writeln("	dbcError = $dbcError");
    buf.writeln("	dbcErrorMessage = $dbcErrorMessage");
    buf.writeln("	dbcDownloadProgress = $dbcDownloadProgress");
    buf.writeln(")");

    return buf.toString();
  }
}
