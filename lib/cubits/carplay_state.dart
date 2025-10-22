part of 'carplay_cubit.dart';

@freezed
sealed class CarPlayState with _$CarPlayState {
  const factory CarPlayState.disconnected() = CarPlayDisconnected;
  const factory CarPlayState.connecting() = CarPlayConnecting;
  const factory CarPlayState.connected({
    required RTCVideoRenderer renderer,
  }) = CarPlayConnected;
  const factory CarPlayState.error({
    required String message,
  }) = CarPlayError;
}
