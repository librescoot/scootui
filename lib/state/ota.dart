import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'ota.g.dart';

@StateClass("ota", Duration(seconds: 5))
class OtaData with $OtaData {
  @override
  @StateField(name: "status", defaultValue: "unknown")
  String otaStatus;

  @override
  @StateField(name: "update-type", defaultValue: "none")
  String updateType;

  @override
  @StateField(name: "status:dbc", defaultValue: "")
  String dbcStatus;

  @override
  @StateField(name: "status:mdb", defaultValue: "")
  String mdbStatus;

  @override
  @StateField(name: "update-version:dbc", defaultValue: "")
  String dbcUpdateVersion;

  @override
  @StateField(name: "error:dbc", defaultValue: "")
  String dbcError;

  @override
  @StateField(name: "error-message:dbc", defaultValue: "")
  String dbcErrorMessage;

  @override
  @StateField(name: "download-progress:dbc", defaultValue: "0")
  String dbcDownloadProgress;

  OtaData({
    this.otaStatus = "none",
    this.updateType = "none",
    this.dbcStatus = "",
    this.mdbStatus = "",
    this.dbcUpdateVersion = "",
    this.dbcError = "",
    this.dbcErrorMessage = "",
    this.dbcDownloadProgress = "0",
  });
}
