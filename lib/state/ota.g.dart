// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ota.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

abstract mixin class $OtaData implements Syncable<OtaData> {
  String get dbcStatus;
  String get dbcUpdateVersion;
  String get dbcUpdateMethod;
  String get dbcError;
  String get dbcErrorMessage;
  String get dbcDownloadProgress;
  String get dbcInstallProgress;
  String get mdbStatus;
  String get mdbUpdateVersion;
  String get mdbUpdateMethod;
  String get mdbError;
  String get mdbErrorMessage;
  String get mdbDownloadProgress;
  String get mdbInstallProgress;
  get syncSettings => SyncSettings(
      "ota",
      Duration(microseconds: 5000000),
      [
        SyncFieldSettings(
            name: "dbcStatus",
            variable: "status:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "idle",
            interval: null),
        SyncFieldSettings(
            name: "dbcUpdateVersion",
            variable: "update-version:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "dbcUpdateMethod",
            variable: "update-method:dbc",
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
        SyncFieldSettings(
            name: "dbcInstallProgress",
            variable: "install-progress:dbc",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "0",
            interval: null),
        SyncFieldSettings(
            name: "mdbStatus",
            variable: "status:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "idle",
            interval: null),
        SyncFieldSettings(
            name: "mdbUpdateVersion",
            variable: "update-version:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "mdbUpdateMethod",
            variable: "update-method:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "mdbError",
            variable: "error:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "mdbErrorMessage",
            variable: "error-message:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "mdbDownloadProgress",
            variable: "download-progress:mdb",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "0",
            interval: null),
        SyncFieldSettings(
            name: "mdbInstallProgress",
            variable: "install-progress:mdb",
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
      dbcStatus: "status:dbc" != name ? dbcStatus : value,
      dbcUpdateVersion: "update-version:dbc" != name ? dbcUpdateVersion : value,
      dbcUpdateMethod: "update-method:dbc" != name ? dbcUpdateMethod : value,
      dbcError: "error:dbc" != name ? dbcError : value,
      dbcErrorMessage: "error-message:dbc" != name ? dbcErrorMessage : value,
      dbcDownloadProgress:
          "download-progress:dbc" != name ? dbcDownloadProgress : value,
      dbcInstallProgress:
          "install-progress:dbc" != name ? dbcInstallProgress : value,
      mdbStatus: "status:mdb" != name ? mdbStatus : value,
      mdbUpdateVersion: "update-version:mdb" != name ? mdbUpdateVersion : value,
      mdbUpdateMethod: "update-method:mdb" != name ? mdbUpdateMethod : value,
      mdbError: "error:mdb" != name ? mdbError : value,
      mdbErrorMessage: "error-message:mdb" != name ? mdbErrorMessage : value,
      mdbDownloadProgress:
          "download-progress:mdb" != name ? mdbDownloadProgress : value,
      mdbInstallProgress:
          "install-progress:mdb" != name ? mdbInstallProgress : value,
    );
  }

  @override
  OtaData updateSet(String name, Set<dynamic> value) {
    return OtaData(
      dbcStatus: dbcStatus,
      dbcUpdateVersion: dbcUpdateVersion,
      dbcUpdateMethod: dbcUpdateMethod,
      dbcError: dbcError,
      dbcErrorMessage: dbcErrorMessage,
      dbcDownloadProgress: dbcDownloadProgress,
      dbcInstallProgress: dbcInstallProgress,
      mdbStatus: mdbStatus,
      mdbUpdateVersion: mdbUpdateVersion,
      mdbUpdateMethod: mdbUpdateMethod,
      mdbError: mdbError,
      mdbErrorMessage: mdbErrorMessage,
      mdbDownloadProgress: mdbDownloadProgress,
      mdbInstallProgress: mdbInstallProgress,
    );
  }

  List<Object?> get props => [
        dbcStatus,
        dbcUpdateVersion,
        dbcUpdateMethod,
        dbcError,
        dbcErrorMessage,
        dbcDownloadProgress,
        dbcInstallProgress,
        mdbStatus,
        mdbUpdateVersion,
        mdbUpdateMethod,
        mdbError,
        mdbErrorMessage,
        mdbDownloadProgress,
        mdbInstallProgress
      ];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("OtaData(");
    buf.writeln("	dbcStatus = $dbcStatus");
    buf.writeln("	dbcUpdateVersion = $dbcUpdateVersion");
    buf.writeln("	dbcUpdateMethod = $dbcUpdateMethod");
    buf.writeln("	dbcError = $dbcError");
    buf.writeln("	dbcErrorMessage = $dbcErrorMessage");
    buf.writeln("	dbcDownloadProgress = $dbcDownloadProgress");
    buf.writeln("	dbcInstallProgress = $dbcInstallProgress");
    buf.writeln("	mdbStatus = $mdbStatus");
    buf.writeln("	mdbUpdateVersion = $mdbUpdateVersion");
    buf.writeln("	mdbUpdateMethod = $mdbUpdateMethod");
    buf.writeln("	mdbError = $mdbError");
    buf.writeln("	mdbErrorMessage = $mdbErrorMessage");
    buf.writeln("	mdbDownloadProgress = $mdbDownloadProgress");
    buf.writeln("	mdbInstallProgress = $mdbInstallProgress");
    buf.writeln(")");

    return buf.toString();
  }
}
