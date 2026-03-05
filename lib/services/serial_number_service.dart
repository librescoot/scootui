import 'dart:io';

class SerialNumberService {
  /// Reads the device serial number from system files.
  /// Tries /sys/devices/soc0/serial_number first (DBC / i.MX6),
  /// falls back to FSL OTP fuses (MDB / i.MX6 with fsl_otp driver).
  /// Returns the serial number as a 64-bit integer, or null on failure.
  static Future<int?> readSerialNumber() async {
    // DBC path: single 64-bit hex string
    final soc0 = File('/sys/devices/soc0/serial_number');
    if (await soc0.exists()) {
      try {
        final content = (await soc0.readAsString()).trim();
        final value = int.tryParse(content, radix: 16);
        if (value != null && value != 0) return value;
      } catch (e) {
        print('Error reading soc0 serial number: $e');
      }
    }

    // MDB path: two 32-bit fuse words combined
    final fuseFiles = ['/sys/fsl_otp/HW_OCOTP_CFG0', '/sys/fsl_otp/HW_OCOTP_CFG1'];
    try {
      int serialNumber = 0;
      for (final path in fuseFiles) {
        final file = File(path);
        if (!await file.exists()) return null;
        final content = (await file.readAsString()).trim();
        final hex = content.startsWith('0x') ? content.substring(2) : content;
        final value = int.tryParse(hex, radix: 16);
        if (value == null) return null;
        serialNumber += value;
      }
      if (serialNumber != 0) return serialNumber;
    } catch (e) {
      print('Error reading fsl_otp serial number: $e');
    }

    return null;
  }
}
