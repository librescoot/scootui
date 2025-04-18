part of 'map_cubit.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.loading({
    required LatLng position,
    @Default(0) double orientation,
    required MapController controller,
    @Default(null) Route? route,
    @Default(null) RouteInstruction? nextInstruction,
    @Default(null) LatLng? destination,
    @Default(false) bool isWorking,
  }) = MapLoading;

  const factory MapState.unavailable(
    String error, {
    required LatLng position,
    @Default(0) double orientation,
    required MapController controller,
    @Default(null) Route? route,
    @Default(null) RouteInstruction? nextInstruction,
    @Default(null) LatLng? destination,
  }) = MapUnavailable;

  const factory MapState.offline({
    required MapController controller,
    required LatLng position,
    required double orientation,
    required VectorTileProvider tiles,
    required Theme theme,
    void Function(TickerProvider)? onReady,
    @Default(false) bool isReady,
    @Default(null) Route? route,
    @Default(null) RouteInstruction? nextInstruction,
    @Default(null) LatLng? destination,
  }) = MapOffline;

  const factory MapState.online({
    required LatLng position,
    required double orientation,
    required MapController controller,
    void Function(TickerProvider)? onReady,
    @Default(false) bool isReady,
    @Default(null) Route? route,
    @Default(null) RouteInstruction? nextInstruction,
    @Default(null) LatLng? destination,
  }) = MapOnline;
}
