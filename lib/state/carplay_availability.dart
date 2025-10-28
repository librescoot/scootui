import 'package:equatable/equatable.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'carplay_availability.g.dart';

@StateClass("carplay", Duration(seconds: 2))
class CarPlayAvailabilityData extends Equatable with $CarPlayAvailabilityData {
  @override
  @StateField()
  final String dongle_available;

  @override
  @StateField()
  final String device_connected;

  @override
  @StateField()
  final String device_type;

  @override
  @StateField()
  final String error;

  CarPlayAvailabilityData({
    this.dongle_available = "",
    this.device_connected = "",
    this.device_type = "",
    this.error = "",
  });

  /// Check if the USB dongle is available
  bool get isDongleAvailable => dongle_available == "true";

  /// Check if a device is connected
  bool get isDeviceConnected => device_connected == "true";

  /// Check if device is iOS (CarPlay or iPhone Mirror)
  bool get isIOS => device_type == "ios";

  /// Check if device is Android (Android Auto, Android Mirror, or HiCar)
  bool get isAndroid => device_type == "android";

  /// Get display name for the menu
  String get displayName {
    if (isIOS) return "CarPlay";
    if (isAndroid) return "Android Auto";
    return "CarPlay / Android Auto";
  }

  /// Check if there's an error
  bool get hasError => error.isNotEmpty;
}
