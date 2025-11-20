part of 'address_cubit.dart';

@freezed
sealed class AddressState with _$AddressState {
  const factory AddressState.loading(String message) = AddressStateLoading;
  const factory AddressState.error(String message) = AddressStateError;
  const factory AddressState.loaded(List<LatLng> addresses) =
      AddressStateLoaded;
}
