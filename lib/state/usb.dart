import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'usb.g.dart';

@StateClass("usb", Duration(seconds: 5))
class UsbData with $UsbData {
  @override
  @StateField(defaultValue: "idle")
  String status;

  @override
  @StateField(defaultValue: "normal")
  String mode;

  UsbData({
    this.status = "idle",
    this.mode = "normal",
  });
}
