class VehicleState {
  double currentSpeed = 0.0;
  int rpm = 0;
  double motorVoltage = 0.0;
  double motorCurrent = 0.0;
  bool throttleActive = false;
  String blinkerState = 'off';
  int odometer = 0;
  int _lastOdometer = 0;  // To track changes for trip calculation
  double tripDistance = 0.0;  // Trip distance in kilometers
  String handlebarPosition = 'unlocked';
  String handlebarLockSensor = 'unlocked';
  String kickstandState = 'up';
  String seatboxButton = 'released';
  String vehicleState = '';
  String seatboxLock = '';
  
  // Brake states
  bool leftBrakeActive = false;
  bool rightBrakeActive = false;
  bool get isBraking => leftBrakeActive || rightBrakeActive;
  
  // Primary driving battery (battery:0)
  bool battery0Present = false;
  String battery0State = 'unknown';
  double battery0Voltage = 0.0;
  double battery0Current = 0.0;
  double battery0Charge = 0.0;
  String battery0TempState = 'unknown';
  int battery0CycleCount = 0;
  int battery0StateOfHealth = 0;
  String battery0SerialNumber = '';
  String battery0ManufacturingDate = '';
  String battery0FwVersion = '';
  List<String> battery0Faults = [];

  // Secondary driving battery (battery:1)
  bool battery1Present = false;
  String battery1State = 'unknown';
  double battery1Voltage = 0.0;
  double battery1Current = 0.0;
  double battery1Charge = 0.0;
  String battery1TempState = 'unknown';
  int battery1CycleCount = 0;
  int battery1StateOfHealth = 0;
  String battery1SerialNumber = '';
  String battery1ManufacturingDate = '';
  String battery1FwVersion = '';
  List<String> battery1Faults = [];
  
  // Communication board battery state (cb-battery)
  double cbBatteryVoltage = 0.0;
  double cbBatteryCurrent = 0.0;
  int cbBatteryTimeToFull = 0;
  double cbBatteryTemp = 0.0;
  double cbBatteryRemainingCapacity = 0.0;
  double cbBatteryFullCapacity = 0.0;

  // Aux battery
  double auxBatteryVoltage = 0.0;
  String auxBatteryChargeStatus = '';

  // System state
  bool isConnected = false;
  String internetTech = '';
  int signalQuality = 0;
  String mdbVersion = '';
  String nrfFwVersion = '';
  bool isUnableToDrive = false;

  // Bluetooth connection status
  bool isBluetoothConnected = false;
  String blePin = '';

  double get powerOutput => motorVoltage * motorCurrent / 1000;
  
  // Combined battery charge calculation
  double get totalBatteryCharge {
    if (battery0Present && battery1Present) {
      return (battery0Charge + battery1Charge) / 2;
    } else if (battery0Present) {
      return battery0Charge;
    } else if (battery1Present) {
      return battery1Charge;
    }
    return 0.0;
  }

  double get odometerKm => odometer / 1000;
  bool get isParked => vehicleState == 'parked';

  void updateFromRedis(String channel, String key, dynamic value) {
    switch (channel) {
      case 'engine-ecu':
        _updateEngineState(key, value);
        break;
      case 'vehicle':
        _updateVehicleState(key, value);
        break;
      case 'cb-battery':
        _updateCBBatteryState(key, value);
        break;
      case 'internet':
        _updateInternetState(key, value);
        break;
      case 'aux-battery':
        _updateAuxBatteryState(key, value);
        break;
      case 'battery:0':
        _updateBattery0State(key, value);
        break;
      case 'battery:1':
        _updateBattery1State(key, value);
        break;
      case 'ble':
        _updateBluetoothState(key, value);
        break;
    }
  }

  void _updateBluetoothState(String key, dynamic value) {
    switch (key) {
      case 'status':
        isBluetoothConnected = value.toString() == 'connected';
        break;
      case 'pin-code':
        blePin = value.toString();
        break;
    }
  }

  void _updateEngineState(String key, dynamic value) {
    switch (key) {
      case 'speed':
        currentSpeed = double.tryParse(value.toString()) ?? currentSpeed;
        break;
      case 'rpm':
        rpm = int.tryParse(value.toString()) ?? rpm;
        break;
      case 'motor:voltage':
        motorVoltage = double.tryParse(value.toString()) ?? motorVoltage;
        break;
      case 'motor:current':
        motorCurrent = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'throttle':
        throttleActive = value == 'on';
        break;
      case 'odometer':
        final newOdometer = int.tryParse(value.toString()) ?? odometer;
        // Calculate trip distance increase
        if (_lastOdometer > 0) {  // Skip first update to avoid huge initial value
          final increase = (newOdometer - _lastOdometer) / 1000.0;  // Convert to km
          if (increase >= 0) {  // Only count positive changes
            tripDistance += increase;
          }
        }
        _lastOdometer = newOdometer;
        odometer = newOdometer;
        break;
      case 'brake:left':
        leftBrakeActive = value == 'pressed';
        break;
      case 'brake:right':
        rightBrakeActive = value == 'pressed';
        break;
    }
  }

  // Reset trip distance to 0
  void resetTrip() {
    tripDistance = 0.0;
    _lastOdometer = odometer;  // Reset last odometer to current value
  }

  void _updateVehicleState(String key, dynamic value) {
    switch (key) {
      case 'blinker:state':
        blinkerState = value.toString();
        break;
      case 'handlebar:position':
        handlebarPosition = value.toString();
        break;
      case 'handlebar:lock-sensor':
        handlebarLockSensor = value.toString();
        break;
      case 'kickstand':
        kickstandState = value.toString();
        break;
      case 'seatbox:button':
        seatboxButton = value.toString();
        break;
      case 'state':
        vehicleState = value.toString();
        break;
      case 'seatbox:lock':
        seatboxLock = value.toString();
        break;
    }
  }

  void _updateBatteryState(
    bool isBattery0,
    String key,
    dynamic value,
    bool present,
    String state,
    double voltage,
    double current,
    double charge,
    String tempState,
    int cycleCount,
    int stateOfHealth,
    String serialNumber,
    String manufacturingDate,
    String fwVersion,
    List<String> faults,
  ) {
    switch (key) {
      case 'present':
        present = value == 'true';
        break;
      case 'state':
        state = value.toString();
        break;
      case 'voltage':
        voltage = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'current':
        current = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'charge':
        charge = double.tryParse(value.toString()) ?? charge;
        break;
      case 'temperature-state':
        tempState = value.toString();
        break;
      case 'cycle-count':
        cycleCount = int.tryParse(value.toString()) ?? cycleCount;
        break;
      case 'state-of-health':
        stateOfHealth = int.tryParse(value.toString()) ?? stateOfHealth;
        break;
      case 'serial-number':
        serialNumber = value.toString();
        break;
      case 'manufacturing-date':
        manufacturingDate = value.toString();
        break;
      case 'fw-version':
        fwVersion = value.toString();
        break;
      case 'fault':
        if (value is List) {
          faults = value.map((e) => e.toString()).toList();
        }
        break;
    }

    if (isBattery0) {
      battery0Present = present;
      battery0State = state;
      battery0Voltage = voltage;
      battery0Current = current;
      battery0Charge = charge;
      battery0TempState = tempState;
      battery0CycleCount = cycleCount;
      battery0StateOfHealth = stateOfHealth;
      battery0SerialNumber = serialNumber;
      battery0ManufacturingDate = manufacturingDate;
      battery0FwVersion = fwVersion;
      battery0Faults = faults;
    } else {
      battery1Present = present;
      battery1State = state;
      battery1Voltage = voltage;
      battery1Current = current;
      battery1Charge = charge;
      battery1TempState = tempState;
      battery1CycleCount = cycleCount;
      battery1StateOfHealth = stateOfHealth;
      battery1SerialNumber = serialNumber;
      battery1ManufacturingDate = manufacturingDate;
      battery1FwVersion = fwVersion;
      battery1Faults = faults;
    }
  }

  void _updateBattery0State(String key, dynamic value) {
    _updateBatteryState(
      true,
      key,
      value,
      battery0Present,
      battery0State,
      battery0Voltage,
      battery0Current,
      battery0Charge,
      battery0TempState,
      battery0CycleCount,
      battery0StateOfHealth,
      battery0SerialNumber,
      battery0ManufacturingDate,
      battery0FwVersion,
      battery0Faults,
    );
  }

  void _updateBattery1State(String key, dynamic value) {
    _updateBatteryState(
      false,
      key,
      value,
      battery1Present,
      battery1State,
      battery1Voltage,
      battery1Current,
      battery1Charge,
      battery1TempState,
      battery1CycleCount,
      battery1StateOfHealth,
      battery1SerialNumber,
      battery1ManufacturingDate,
      battery1FwVersion,
      battery1Faults,
    );
  }

  void _updateCBBatteryState(String key, dynamic value) {
    switch (key) {
      case 'cell-voltage':
        cbBatteryVoltage = (int.tryParse(value.toString()) ?? 0) / 1000000;
        break;
      case 'current':
        cbBatteryCurrent = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'temperature':
        cbBatteryTemp = double.tryParse(value.toString()) ?? cbBatteryTemp;
        break;
      case 'remaining-capacity':
        cbBatteryRemainingCapacity = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'full-capacity':
        cbBatteryFullCapacity = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'time-to-full':
        cbBatteryTimeToFull = int.tryParse(value.toString()) ?? cbBatteryTimeToFull;
        break;
    }
  }

  void _updateInternetState(String key, dynamic value) {
    switch (key) {
      case 'status':
        isConnected = value == 'connected';
        break;
      case 'access-tech':
        internetTech = value.toString();
        break;
      case 'signal-quality':
        signalQuality = int.tryParse(value.toString()) ?? signalQuality;
        break;
    }
  }

  void _updateAuxBatteryState(String key, dynamic value) {
    switch (key) {
      case 'voltage':
        auxBatteryVoltage = (int.tryParse(value.toString()) ?? 0) / 1000;
        break;
      case 'charge-status':
        auxBatteryChargeStatus = value.toString();
        break;
    }
  }
}