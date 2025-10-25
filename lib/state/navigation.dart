import 'package:equatable/equatable.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'navigation.g.dart';

@StateClass("navigation", Duration(seconds: 5))
class NavigationData extends Equatable with $NavigationData {
  @override
  @StateField()
  final String latitude;

  @override
  @StateField()
  final String longitude;

  @override
  @StateField()
  final String address;

  @override
  @StateField()
  final String timestamp;

  @override
  @StateField()
  final String destination;

  NavigationData({
    this.latitude = "",
    this.longitude = "",
    this.address = "",
    this.timestamp = "",
    this.destination = "",
  });

  /// Check if navigation has a valid destination
  bool get hasDestination =>
      (latitude.isNotEmpty && longitude.isNotEmpty) || destination.isNotEmpty;

  /// Get latitude as double
  double? get latitudeDouble {
    if (latitude.isEmpty) return null;
    return double.tryParse(latitude);
  }

  /// Get longitude as double
  double? get longitudeDouble {
    if (longitude.isEmpty) return null;
    return double.tryParse(longitude);
  }
}
