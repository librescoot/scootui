part of 'map_cubit.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.loading({
    required LatLng position,
    @Default(0) double orientation,
    required MapController controller,
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
    required MbTiles mbTiles,
    required Theme theme,
    void Function()? onReady,
    @Default(false) bool isReady,
    @Default(null) Route? route,
  }) = MapOffline;

  const factory MapState.online({
    required LatLng position,
    required double orientation,
    required MapController controller,
    void Function()? onReady,
    @Default(false) bool isReady,
    @Default(null) Route? route,
  }) = MapOnline;
}
