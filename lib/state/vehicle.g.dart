// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// StateGenerator
// **************************************************************************

final $_BlinkerStateMap = {
  "off": BlinkerState.off,
  "left": BlinkerState.left,
  "right": BlinkerState.right,
  "both": BlinkerState.both,
};

final $_BlinkerSwitchMap = {
  "off": BlinkerSwitch.off,
  "left": BlinkerSwitch.left,
  "right": BlinkerSwitch.right,
};

final $_ToggleMap = {
  "on": Toggle.on,
  "off": Toggle.off,
};

final $_KickstandMap = {
  "up": Kickstand.up,
  "down": Kickstand.down,
};

final $_ScooterStateMap = {
  "stand-by": ScooterState.standBy,
  "ready-to-drive": ScooterState.readyToDrive,
  "off": ScooterState.off,
  "parked": ScooterState.parked,
  "booting": ScooterState.booting,
  "shutting-down": ScooterState.shuttingDown,
  "hibernating": ScooterState.hibernating,
  "hibernating-imminent": ScooterState.hibernatingImminent,
  "suspending": ScooterState.suspending,
  "suspending-imminent": ScooterState.suspendingImminent,
  "updating": ScooterState.updating,
  "waiting-seatbox": ScooterState.waitingSeatbox,
  "waiting-hibernation": ScooterState.waitingHibernation,
  "waiting-hibernation-advanced": ScooterState.waitingHibernationAdvanced,
  "waiting-hibernation-seatbox": ScooterState.waitingHibernationSeatbox,
  "waiting-hibernation-confirm": ScooterState.waitingHibernationConfirm,
};

final $_HandleBarLockSensorMap = {
  "locked": HandleBarLockSensor.locked,
  "unlocked": HandleBarLockSensor.unlocked,
};

final $_HandleBarPositionMap = {
  "on-place": HandleBarPosition.onPlace,
};

final $_SeatboxLockMap = {
  "open": SeatboxLock.open,
  "closed": SeatboxLock.closed,
};

abstract mixin class $VehicleData implements Syncable<VehicleData> {
  BlinkerState get blinkerState;
  BlinkerSwitch get blinkerSwitch;
  Toggle get brakeLeft;
  Toggle get brakeRight;
  Kickstand get kickstand;
  ScooterState get state;
  String get stateRaw;
  HandleBarLockSensor get handleBarLockSensor;
  HandleBarPosition get handleBarPosition;
  Toggle get seatboxButton;
  SeatboxLock get seatboxLock;
  Toggle get hornButton;
  Toggle get isUnableToDrive;
  get syncSettings => SyncSettings(
      "vehicle",
      Duration(microseconds: 1000000),
      [
        SyncFieldSettings(
            name: "blinkerState",
            variable: "blinker:state",
            type: SyncFieldType.enum_,
            typeName: "BlinkerState",
            defaultValue: "off",
            interval: null),
        SyncFieldSettings(
            name: "blinkerSwitch",
            variable: "blinker:switch",
            type: SyncFieldType.enum_,
            typeName: "BlinkerSwitch",
            defaultValue: "off",
            interval: Duration(microseconds: 2000000)),
        SyncFieldSettings(
            name: "brakeLeft",
            variable: "brake:left",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: Duration(microseconds: 30000000)),
        SyncFieldSettings(
            name: "brakeRight",
            variable: "brake:right",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: Duration(microseconds: 30000000)),
        SyncFieldSettings(
            name: "kickstand",
            variable: "kickstand",
            type: SyncFieldType.enum_,
            typeName: "Kickstand",
            defaultValue: "down",
            interval: null),
        SyncFieldSettings(
            name: "state",
            variable: "state",
            type: SyncFieldType.enum_,
            typeName: "ScooterState",
            defaultValue: "off",
            interval: null),
        SyncFieldSettings(
            name: "stateRaw",
            variable: "state",
            type: SyncFieldType.string,
            typeName: "String",
            defaultValue: "",
            interval: null),
        SyncFieldSettings(
            name: "handleBarLockSensor",
            variable: "handlebar:lock-sensor",
            type: SyncFieldType.enum_,
            typeName: "HandleBarLockSensor",
            defaultValue: "locked",
            interval: null),
        SyncFieldSettings(
            name: "handleBarPosition",
            variable: "handlebar:position",
            type: SyncFieldType.enum_,
            typeName: "HandleBarPosition",
            defaultValue: "onPlace",
            interval: null),
        SyncFieldSettings(
            name: "seatboxButton",
            variable: "seatbox:button",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: null),
        SyncFieldSettings(
            name: "seatboxLock",
            variable: "seatbox:lock",
            type: SyncFieldType.enum_,
            typeName: "SeatboxLock",
            defaultValue: "closed",
            interval: Duration(microseconds: 30000000)),
        SyncFieldSettings(
            name: "hornButton",
            variable: "horn-button",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: null),
        SyncFieldSettings(
            name: "isUnableToDrive",
            variable: "unable-to-drive",
            type: SyncFieldType.enum_,
            typeName: "Toggle",
            defaultValue: "off",
            interval: null),
      ],
      "null",
      []);

  @override
  VehicleData update(String name, String value) {
    return VehicleData(
      blinkerState: "blinker:state" != name
          ? blinkerState
          : $_BlinkerStateMap[value] ?? BlinkerState.off,
      blinkerSwitch: "blinker:switch" != name
          ? blinkerSwitch
          : $_BlinkerSwitchMap[value] ?? BlinkerSwitch.off,
      brakeLeft:
          "brake:left" != name ? brakeLeft : $_ToggleMap[value] ?? Toggle.off,
      brakeRight:
          "brake:right" != name ? brakeRight : $_ToggleMap[value] ?? Toggle.off,
      kickstand: "kickstand" != name
          ? kickstand
          : $_KickstandMap[value] ?? Kickstand.down,
      state: "state" != name
          ? state
          : $_ScooterStateMap[value] ?? ScooterState.off,
      stateRaw: "state" != name ? stateRaw : value,
      handleBarLockSensor: "handlebar:lock-sensor" != name
          ? handleBarLockSensor
          : $_HandleBarLockSensorMap[value] ?? HandleBarLockSensor.locked,
      handleBarPosition: "handlebar:position" != name
          ? handleBarPosition
          : $_HandleBarPositionMap[value] ?? HandleBarPosition.onPlace,
      seatboxButton: "seatbox:button" != name
          ? seatboxButton
          : $_ToggleMap[value] ?? Toggle.off,
      seatboxLock: "seatbox:lock" != name
          ? seatboxLock
          : $_SeatboxLockMap[value] ?? SeatboxLock.closed,
      hornButton:
          "horn-button" != name ? hornButton : $_ToggleMap[value] ?? Toggle.off,
      isUnableToDrive: "unable-to-drive" != name
          ? isUnableToDrive
          : $_ToggleMap[value] ?? Toggle.off,
    );
  }

  @override
  VehicleData updateSet(String name, Set<dynamic> value) {
    return VehicleData(
      blinkerState: blinkerState,
      blinkerSwitch: blinkerSwitch,
      brakeLeft: brakeLeft,
      brakeRight: brakeRight,
      kickstand: kickstand,
      state: state,
      stateRaw: stateRaw,
      handleBarLockSensor: handleBarLockSensor,
      handleBarPosition: handleBarPosition,
      seatboxButton: seatboxButton,
      seatboxLock: seatboxLock,
      hornButton: hornButton,
      isUnableToDrive: isUnableToDrive,
    );
  }

  List<Object?> get props => [
        blinkerState,
        blinkerSwitch,
        brakeLeft,
        brakeRight,
        kickstand,
        state,
        stateRaw,
        handleBarLockSensor,
        handleBarPosition,
        seatboxButton,
        seatboxLock,
        hornButton,
        isUnableToDrive
      ];
  @override
  String toString() {
    final buf = StringBuffer();

    buf.writeln("VehicleData(");
    buf.writeln("	blinkerState = $blinkerState");
    buf.writeln("	blinkerSwitch = $blinkerSwitch");
    buf.writeln("	brakeLeft = $brakeLeft");
    buf.writeln("	brakeRight = $brakeRight");
    buf.writeln("	kickstand = $kickstand");
    buf.writeln("	state = $state");
    buf.writeln("	stateRaw = $stateRaw");
    buf.writeln("	handleBarLockSensor = $handleBarLockSensor");
    buf.writeln("	handleBarPosition = $handleBarPosition");
    buf.writeln("	seatboxButton = $seatboxButton");
    buf.writeln("	seatboxLock = $seatboxLock");
    buf.writeln("	hornButton = $hornButton");
    buf.writeln("	isUnableToDrive = $isUnableToDrive");
    buf.writeln(")");

    return buf.toString();
  }
}
