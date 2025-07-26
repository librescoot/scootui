import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../services/map_service.dart';

part 'address_repository.freezed.dart';
part 'address_repository.g.dart';

@freezed
abstract class Address with _$Address {
  const factory Address({
    required String id,
    required LatLng coordinates,
    // The x and y here are tile-local coordinates, which may not be needed
    // in the new design. Keeping them for now but can be removed.
    required double x,
    required double y,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

class AddressRepository {
  final MapService _mapService;

  AddressRepository(this._mapService);

  // This is a placeholder. It will eventually call the MapService.
  Future<Address?> findAddress(String id) async {
    // In the future, this will delegate to:
    return _mapService.findAddress(id);
  }
}
