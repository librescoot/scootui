import 'dart:io';

class SerialNumberService {
  /// Reads the device serial number from system files.
  /// Tries /sys/devices/soc0/serial_number first (DBC / i.MX6),
  /// falls back to FSL OTP fuses (MDB / i.MX6 with fsl_otp driver).
  /// Returns the serial number as a 64-bit integer, or null on failure.
  static Future<int?> readSerialNumber() async {
    // DBC path: "%08X%08X" hex string (CFG1 upper 32 bits, CFG0 lower 32 bits)
    // Add CFG0 + CFG1 to match version-service's serial_number logic.
    final soc0 = File('/sys/devices/soc0/serial_number');
    if (await soc0.exists()) {
      try {
        final content = (await soc0.readAsString()).trim().padLeft(16, '0');
        final cfg1 = int.tryParse(content.substring(content.length - 16, content.length - 8), radix: 16);
        final cfg0 = int.tryParse(content.substring(content.length - 8), radix: 16);
        if (cfg1 != null && cfg0 != null) {
          final value = cfg0 + cfg1;
          if (value != 0) return value;
        }
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
