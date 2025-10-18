import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'ota.g.dart';

@StateClass("ota", Duration(seconds: 5))
class OtaData with $OtaData {
  // DBC component fields
  @override
  @StateField(name: "status:dbc", defaultValue: "idle")
  String dbcStatus;

  @override
  @StateField(name: "update-version:dbc", defaultValue: "")
  String dbcUpdateVersion;

  @override
  @StateField(name: "update-method:dbc", defaultValue: "")
  String dbcUpdateMethod;

  @override
  @StateField(name: "error:dbc", defaultValue: "")
  String dbcError;

  @override
  @StateField(name: "error-message:dbc", defaultValue: "")
  String dbcErrorMessage;

  @override
  @StateField(name: "download-progress:dbc", defaultValue: "0")
  String dbcDownloadProgress;

  // MDB component fields
  @override
  @StateField(name: "status:mdb", defaultValue: "idle")
  String mdbStatus;

  @override
  @StateField(name: "update-version:mdb", defaultValue: "")
  String mdbUpdateVersion;

  @override
  @StateField(name: "update-method:mdb", defaultValue: "")
  String mdbUpdateMethod;

  @override
  @StateField(name: "error:mdb", defaultValue: "")
  String mdbError;

  @override
  @StateField(name: "error-message:mdb", defaultValue: "")
  String mdbErrorMessage;

  @override
  @StateField(name: "download-progress:mdb", defaultValue: "0")
  String mdbDownloadProgress;

  OtaData({
    this.dbcStatus = "idle",
    this.dbcUpdateVersion = "",
    this.dbcUpdateMethod = "",
    this.dbcError = "",
    this.dbcErrorMessage = "",
    this.dbcDownloadProgress = "0",
    this.mdbStatus = "idle",
    this.mdbUpdateVersion = "",
    this.mdbUpdateMethod = "",
    this.mdbError = "",
    this.mdbErrorMessage = "",
    this.mdbDownloadProgress = "0",
  });
}
