import 'package:equatable/equatable.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';

part 'battery.g.dart';

enum BatteryState { unknown, asleep, idle, active }

// Represents a battery fault code (0-13)
class BatteryFault {
  final int code;

  const BatteryFault(this.code);

  @override
  String toString() => "B${code.toString()}";
}

@StateClass("battery", Duration(seconds: 30))
class BatteryData extends Equatable with $BatteryData {
  @override
  @StateDiscriminator()
  final String id;

  @override
  @StateField()
  final bool present;

  @override
  @StateField(defaultValue: 'unknown')
  final BatteryState state;

  @override
  @StateField()
  final int voltage;

  @override
  @StateField()
  final int current;

  @override
  @StateField()
  final int charge;

  @override
  @StateField(name: "temperature:0")
  final int temperature0;

  @override
  @StateField(name: "temperature:1")
  final int temperature1;

  @override
  @StateField(name: "temperature:2")
  final int temperature2;

  @override
  @StateField(name: "temperature:3")
  final int temperature3;

  @override
  @StateField()
  final String temperatureState;

  @override
  @StateField(name: "fault")
  final List<BatteryFault> faults;

  @override
  @StateField()
  final int cycleCount;

  @override
  @StateField()
  final int stateOfHealth;

  @override
  @StateField()
  final String serialNumber;

  @override
  @StateField()
  final String manufacturingDate;

  @override
  @StateField(name: "fw-version")
  final String firmwareVersion;

  BatteryData({
    required this.id,
    this.present = false,
    this.state = BatteryState.unknown,
    this.voltage = 0,
    this.current = 0,
    this.charge = 0,
    this.cycleCount = 0,
    this.stateOfHealth = 0,
    this.serialNumber = "",
    this.firmwareVersion = "",
    this.manufacturingDate = "",
    this.temperature0 = 0,
    this.temperature1 = 0,
    this.temperature2 = 0,
    this.temperature3 = 0,
    this.temperatureState = "",
    this.faults = const [],
  });

  // Create a copy of this BatteryData with the given fields replaced
  BatteryData copyWith({
    String? id,
    bool? present,
    BatteryState? state,
    int? voltage,
    int? current,
    int? charge,
    int? temperature0,
    int? temperature1,
    int? temperature2,
    int? temperature3,
    String? temperatureState,
    List<BatteryFault>? faults,
    int? cycleCount,
    int? stateOfHealth,
    String? serialNumber,
    String? manufacturingDate,
    String? firmwareVersion,
  }) {
    return BatteryData(
      id: id ?? this.id,
      present: present ?? this.present,
      state: state ?? this.state,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      charge: charge ?? this.charge,
      temperature0: temperature0 ?? this.temperature0,
      temperature1: temperature1 ?? this.temperature1,
      temperature2: temperature2 ?? this.temperature2,
      temperature3: temperature3 ?? this.temperature3,
      temperatureState: temperatureState ?? this.temperatureState,
      faults: faults ?? this.faults,
      cycleCount: cycleCount ?? this.cycleCount,
      stateOfHealth: stateOfHealth ?? this.stateOfHealth,
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}
