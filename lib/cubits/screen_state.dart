part of 'screen_cubit.dart';

@freezed
sealed class ScreenState with _$ScreenState {
  const factory ScreenState.cluster() = ScreenCluster;
  const factory ScreenState.map() = ScreenMap;
  const factory ScreenState.addressSelection() = ScreenAddressSelection;
  const factory ScreenState.otaBackground() = ScreenOtaBackground;
  const factory ScreenState.ota() = ScreenOta;
  const factory ScreenState.debug() = ScreenDebug;
  const factory ScreenState.shuttingDown() = ScreenShuttingDown;
  const factory ScreenState.downloadMap() = ScreenDownloadMap;
}
