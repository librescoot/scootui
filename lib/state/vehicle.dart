import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';
import './enums.dart';

part 'vehicle.g.dart';

enum BlinkerState { off, left, right, both }

enum BlinkerSwitch { off, left, right }

enum HandleBarLockSensor { locked, unlocked }

enum SeatboxLock { open, closed }

enum ScooterState {
  standBy,
  readyToDrive,
  off,
  parked,
  booting,
  shuttingDown,
  hibernating,
  hibernatingImminent,
  suspending,
  suspendingImminent,
  updating,
  waitingSeatbox,
  waitingHibernation,
  waitingHibernationAdvanced,
  waitingHibernationSeatbox,
  waitingHibernationConfirm
}

enum Kickstand { up, down }

enum HandleBarPosition { onPlace }

@StateClass("vehicle", Duration(seconds: 1))
class VehicleData with $VehicleData {
  @override
  @StateField(name: "blinker:state", defaultValue: "off")
  BlinkerState blinkerState;

  @override
  @StateField(
    name: "blinker:switch",
    defaultValue: "off",
    interval: Duration(seconds: 2),
  )
  BlinkerSwitch blinkerSwitch;

  @override
  @StateField(
    name: "brake:left",
    defaultValue: "off",
    interval: Duration(seconds: 30),
  )
  Toggle brakeLeft;

  @override
  @StateField(
    name: "brake:right",
    defaultValue: "off",
    interval: Duration(seconds: 30),
  )
  Toggle brakeRight;

  @override
  @StateField(defaultValue: "down")
  Kickstand kickstand;

  @override
  @StateField(defaultValue: "off")
  ScooterState state;

  @override
  @StateField(name: "handlebar:lock-sensor", defaultValue: "locked")
  HandleBarLockSensor handleBarLockSensor;

  @override
  @StateField(name: "handlebar:position", defaultValue: "onPlace")
  HandleBarPosition handleBarPosition;

  @override
  @StateField(name: "seatbox:button", defaultValue: "off")
  Toggle seatboxButton;

  @override
  @StateField(
    name: "seatbox:lock",
    defaultValue: "closed",
    interval: Duration(seconds: 30),
  )
  SeatboxLock seatboxLock;

  @override
  @StateField(defaultValue: "off")
  Toggle hornButton;

  @override
  @StateField(name: "unable-to-drive", defaultValue: "off")
  Toggle isUnableToDrive;

  VehicleData({
    this.blinkerSwitch = BlinkerSwitch.off,
    this.blinkerState = BlinkerState.off,
    this.state = ScooterState.off,
    this.kickstand = Kickstand.down,
    this.handleBarLockSensor = HandleBarLockSensor.locked,
    this.brakeLeft = Toggle.off,
    this.brakeRight = Toggle.off,
    this.hornButton = Toggle.off,
    this.seatboxLock = SeatboxLock.closed,
    this.handleBarPosition = HandleBarPosition.onPlace,
    this.seatboxButton = Toggle.off,
    this.isUnableToDrive = Toggle.off,
  });
}
