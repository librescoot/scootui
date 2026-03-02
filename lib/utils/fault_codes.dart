import '../services/l10n_service.dart';

enum FaultSeverity { critical, warning }

class FaultCode {
  final String code;
  final String description;
  final FaultSeverity severity;

  const FaultCode(this.code, this.description, this.severity);
}

class BatteryFaultCodes {
  // Critical battery faults
  static const signalWireBroken =
      FaultCode('B5', 'Signal wire broken', FaultSeverity.critical);
  static const criticalOverTemp =
      FaultCode('B6', 'Critical over-temperature', FaultSeverity.critical);
  static const shortCircuit =
      FaultCode('B14', 'Short circuit', FaultSeverity.critical);
  static const bmsNotFollowing =
      FaultCode('B32', 'BMS not following commands', FaultSeverity.critical);
  static const bmsCommError =
      FaultCode('B34', 'BMS communication error', FaultSeverity.critical);
  static const nfcReaderError =
      FaultCode('B35', 'NFC reader error', FaultSeverity.critical);

  // Warning battery faults
  static const overTempCharging =
      FaultCode('B1', 'Over-temperature while charging', FaultSeverity.warning);
  static const underTempCharging = FaultCode(
      'B2', 'Under-temperature while charging', FaultSeverity.warning);
  static const overTempDischarging = FaultCode(
      'B3', 'Over-temperature while discharging', FaultSeverity.warning);
  static const underTempDischarging = FaultCode(
      'B4', 'Under-temperature while discharging', FaultSeverity.warning);
  static const mosfetOverTemp =
      FaultCode('B8', 'MOSFET over-temperature', FaultSeverity.warning);
  static const cellOverVoltage =
      FaultCode('B9', 'Cell over-voltage', FaultSeverity.warning);
  static const cellUnderVoltage =
      FaultCode('B11', 'Cell under-voltage', FaultSeverity.warning);
  static const overCurrentCharging =
      FaultCode('B12', 'Over-current while charging', FaultSeverity.warning);
  static const overCurrentDischarging =
      FaultCode('B13', 'Over-current while discharging', FaultSeverity.warning);

  // Not used/classified
  static const packOverVoltage =
      FaultCode('B7', 'Pack over-voltage', FaultSeverity.warning);
  static const packUnderVoltage =
      FaultCode('B10', 'Pack under-voltage', FaultSeverity.warning);
  static const reserved1 = FaultCode('B15', 'Reserved', FaultSeverity.warning);
  static const reserved2 = FaultCode('B16', 'Reserved', FaultSeverity.warning);
  static const bmsZeroData =
      FaultCode('B33', 'BMS has zero data', FaultSeverity.critical);

  static final Map<int, FaultCode> _faultMap = {
    1: overTempCharging,
    2: underTempCharging,
    3: overTempDischarging,
    4: underTempDischarging,
    5: signalWireBroken,
    6: criticalOverTemp,
    7: packOverVoltage,
    8: mosfetOverTemp,
    9: cellOverVoltage,
    10: packUnderVoltage,
    11: cellUnderVoltage,
    12: overCurrentCharging,
    13: overCurrentDischarging,
    14: shortCircuit,
    15: reserved1,
    16: reserved2,
    32: bmsNotFollowing,
    33: bmsZeroData,
    34: bmsCommError,
    35: nfcReaderError,
  };

  static FaultCode? getFault(int code) => _faultMap[code];

  static String getLocalizedDescription(int code) {
    final l10n = L10nService.current;
    return switch (code) {
      1 => l10n.faultOverTempCharging,
      2 => l10n.faultUnderTempCharging,
      3 => l10n.faultOverTempDischarging,
      4 => l10n.faultUnderTempDischarging,
      5 => l10n.faultSignalWireBroken,
      6 => l10n.faultCriticalOverTemp,
      7 => l10n.faultPackOverVoltage,
      8 => l10n.faultMosfetOverTemp,
      9 => l10n.faultCellOverVoltage,
      10 => l10n.faultPackUnderVoltage,
      11 => l10n.faultCellUnderVoltage,
      12 => l10n.faultOverCurrentCharging,
      13 => l10n.faultOverCurrentDischarging,
      14 => l10n.faultShortCircuit,
      15 || 16 => l10n.faultReserved,
      32 => l10n.faultBmsNotFollowing,
      33 => l10n.faultBmsZeroData,
      34 => l10n.faultBmsCommError,
      35 => l10n.faultNfcReaderError,
      _ => l10n.faultUnknown,
    };
  }

  static bool isCritical(int code) {
    final fault = getFault(code);
    return fault?.severity == FaultSeverity.critical;
  }

  static bool isWarning(int code) {
    final fault = getFault(code);
    return fault?.severity == FaultSeverity.warning;
  }

  // Check if fault is relevant (classified as either critical or warning)
  static bool isRelevant(int code) {
    return _faultMap.containsKey(code) &&
        code != 33; // B33 is defined but not used
  }
}

class FaultFormatter {
  static String formatSingleFault(int code, {String prefix = 'B'}) {
    final fault = BatteryFaultCodes.getFault(code);
    if (fault != null) {
      return '${fault.code} - ${BatteryFaultCodes.getLocalizedDescription(code)}';
    }
    return '$prefix$code - ${L10nService.current.faultUnknown}';
  }

  static String formatMultipleFaults(Set<int> codes, {String prefix = 'B'}) {
    if (codes.isEmpty) return '';
    if (codes.length == 1) {
      return formatSingleFault(codes.first, prefix: prefix);
    }

    // Sort by severity (critical first), then by code number
    final sortedCodes = codes.toList()
      ..sort((a, b) {
        final aCritical = BatteryFaultCodes.isCritical(a);
        final bCritical = BatteryFaultCodes.isCritical(b);

        if (aCritical && !bCritical) return -1;
        if (!aCritical && bCritical) return 1;
        return a.compareTo(b);
      });

    return sortedCodes.map((code) => '$prefix$code').join(', ');
  }

  static bool hasAnyCritical(Set<int> codes) {
    return codes.any((code) => BatteryFaultCodes.isCritical(code));
  }

  static String getMultipleFaultsTitle(Set<int> codes) {
    if (hasAnyCritical(codes)) {
      return L10nService.current.faultMultipleCritical;
    }
    return L10nService.current.faultMultipleBattery;
  }
}
