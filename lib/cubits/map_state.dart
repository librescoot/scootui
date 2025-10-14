part of 'map_cubit.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.loading({
    required LatLng position,
    @Default(0) double orientation,
    required MapController controller,
    @Default(false) bool isWorking,
  }) = MapLoading;

  const factory MapState.unavailable(
    String error, {
    required LatLng position,
    @Default(0) double orientation,
    required MapController controller,
  }) = MapUnavailable;

  const factory MapState.offline({
    required MapController controller,
    required LatLng position,
    required double orientation,
    required VectorTileProvider tiles,
    required Theme theme,
    required String themeMode,
    required String renderMode,
    void Function(TickerProvider)? onReady,
    @Default(false) bool isReady,
  }) = MapOffline;

  const factory MapState.online({
    required LatLng position,
    required double orientation,
    required MapController controller,
    void Function(TickerProvider)? onReady,
    @Default(false) bool isReady,
  }) = MapOnline;
}
