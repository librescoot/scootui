import 'dart:async';

import 'package:flutter/material.dart';

import '../repositories/mdb_repository.dart';
import 'main_screen.dart';

class SimulatorScreen extends StatefulWidget {
  final MDBRepository repository;

  const SimulatorScreen({
    super.key,
    required this.repository,
  });

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  // Engine values
  int _simulatedSpeed = 0;
  int _simulatedRpm = 0;
  int _simulatedMotorCurrent = 0;
  double _simulatedOdometer = 0.0;

  // Battery values
  int _simulatedBatteryCharge0 = 100;
  int _simulatedBatteryCharge1 = 100;
  bool _battery0Present = true;
  bool _battery1Present = true;

  // System values
  int _signalQuality = 0;
  String? _errorMessage;
  StreamSubscription? _connectionStateSubscription;

  // GPS values
  double _gpsLatitude = 0.0;
  double _gpsLongitude = 0.0;
  double _gpsCourse = 0.0;
  double _gpsSpeed = 0.0;
  double _gpsAltitude = 0.0;

  // Navigation values
  String _navigationDestination = '';
  String _navigationLatitude = '';
  String _navigationLongitude = '';
  String _navigationAddress = '';
  String _navigationTimestamp = '';

  // Current states
  String _blinkerState = 'off';
  String _handlebarPosition = 'unlocked';
  String _kickstandState = 'up';
  String _vehicleState = 'parked';
  String _leftBrakeState = 'off';
  String _rightBrakeState = 'off';
  String _seatboxButtonState = 'off';
  String _seatboxLockState = 'open';
  String _bluetoothStatus = 'disconnected';
  String _internetStatus = 'disconnected';
  String _internetAccessTech = 'UNKNOWN';
  String _cloudStatus = 'disconnected';
  String _gpsState = 'off';

  // OTA status fields (per component)
  String _dbcStatus = 'idle';
  String _dbcUpdateVersion = '';
  String _dbcUpdateMethod = '';
  int _dbcDownloadProgress = 0;
  String _mdbStatus = 'idle';
  String _mdbUpdateVersion = '';
  String _mdbUpdateMethod = '';
  int _mdbDownloadProgress = 0;

  // Battery states
  String _battery0State = 'unknown';
  String _battery1State = 'unknown';

  // Motor states
  int _motorVoltage = 50000; // 50V in mV
  int _motorRpm = 0;
  int _motorTemperature = 25; // °C
  String _motorThrottle = 'off';
  String _motorKers = 'off';
  String _motorKersReasonOff = 'none';

  // Battery fault codes (Sets to match production behavior)
  Set<int> _battery0Fault = {};
  Set<int> _battery1Fault = {};

  // CB Battery values
  int _cbBatteryCharge = 100;
  bool _cbBatteryPresent = true;
  String _cbBatteryChargeStatus = 'not-charging';

  // AUX Battery values
  int _auxBatteryCharge = 100; // Valid values: 0, 25, 50, 75, 100
  int _auxBatteryVoltage = 12500; // 12.5V in mV
  String _auxBatteryChargeStatus = 'not-charging';

  // Expanded sections
  bool _vehicleStateExpanded = false;

  // GPS timestamp simulation
  Timer? _gpsTimestampTimer;

  // Card builders
  late final List<Widget Function()> _cardBuilders = [
    _buildMotorCard,
    _buildBattery0Card,
    _buildBattery1Card,
    _buildVehicleStateCard,
    _buildVehicleSwitchesCard,
    _buildBrakesCard,
    _buildConnectivityCard,
    _buildGpsCard,
    _buildNavigationCard,
    _buildCbBatteryCard,
    _buildAuxBatteryCard,
    _buildEcuExtendedCard,
    _buildOtaMdbCard,
    _buildOtaDbcCard,
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
    _setupConnectionStateListener();
  }

  void _setupConnectionStateListener() {
    try {
      final dynamic repo = widget.repository;
      if (repo.connectionStateStream != null) {
        _connectionStateSubscription = (repo.connectionStateStream as Stream).listen((connectionState) {
          final stateStr = connectionState.toString().split('.').last;
          if (stateStr == 'connected' && _errorMessage != null) {
            // Retry loading values when reconnected
            _loadInitialValues();
          }
        });
      }
    } catch (e) {
      // Repository doesn't support connection state monitoring
    }
  }

  Future<void> _loadInitialValues() async {
    try {
      // Load current values from Redis
      await _loadCurrentValues();

      // Initialize values if not already set
      await _initializeValues();

      // Clear error if successful
      _clearErrorMessage();
    } catch (e) {
      // Error already set by _loadCurrentValues, or set it here
      if (_errorMessage == null) {
        setState(() {
          _errorMessage = 'Error initializing: $e';
        });
      }
    }
  }

  Future<void> _loadCurrentValues() async {
    try {
      // Load vehicle states
      final blinkerState =
          await widget.repository.get('vehicle', 'blinker:state');
      final handlebarPosition =
          await widget.repository.get('vehicle', 'handlebar:position');
      final kickstandState =
          await widget.repository.get('vehicle', 'kickstand');
      final vehicleState = await widget.repository.get('vehicle', 'state');
      final leftBrakeState =
          await widget.repository.get('vehicle', 'brake:left');
      final rightBrakeState =
          await widget.repository.get('vehicle', 'brake:right');
      final seatboxLockState =
          await widget.repository.get('vehicle', 'seatbox:lock');

      // Load system states
      final bluetoothStatus = await widget.repository.get('ble', 'status');
      final internetStatus = await widget.repository.get('internet', 'status');
      final internetAccessTech = await widget.repository.get('internet', 'access-tech');
      final signalQuality =
          await widget.repository.get('internet', 'signal-quality');
      final cloudStatus = await widget.repository.get('internet', 'unu-cloud');
      final gpsState = await widget.repository.get('gps', 'state');

      // OTA status fields
      final dbcStatus = await widget.repository.get('ota', 'status:dbc');
      final dbcUpdateVersion = await widget.repository.get('ota', 'update-version:dbc');
      final dbcUpdateMethod = await widget.repository.get('ota', 'update-method:dbc');
      final dbcDownloadProgress = await widget.repository.get('ota', 'download-progress:dbc');
      final mdbStatus = await widget.repository.get('ota', 'status:mdb');
      final mdbUpdateVersion = await widget.repository.get('ota', 'update-version:mdb');
      final mdbUpdateMethod = await widget.repository.get('ota', 'update-method:mdb');
      final mdbDownloadProgress = await widget.repository.get('ota', 'download-progress:mdb');

      // Load battery states
      final battery0Present =
          await widget.repository.get('battery:0', 'present');
      final battery0Charge = await widget.repository.get('battery:0', 'charge');
      final battery0State = await widget.repository.get('battery:0', 'state');

      final battery1Present =
          await widget.repository.get('battery:1', 'present');
      final battery1Charge = await widget.repository.get('battery:1', 'charge');
      final battery1State = await widget.repository.get('battery:1', 'state');

      // Load motor states
      final motorVoltage = await widget.repository.get('engine-ecu', 'motor:voltage');
      final motorRpm = await widget.repository.get('engine-ecu', 'rpm');
      final motorTemperature = await widget.repository.get('engine-ecu', 'temperature');
      final motorThrottle = await widget.repository.get('engine-ecu', 'throttle');
      final motorKers = await widget.repository.get('engine-ecu', 'kers');
      final motorKersReasonOff = await widget.repository.get('engine-ecu', 'kers-reason-off');

      // Load battery fault codes from Sets
      final battery0FaultMembers =
          await widget.repository.getSetMembers('battery:0:fault');
      final battery1FaultMembers =
          await widget.repository.getSetMembers('battery:1:fault');

      // Load CB battery values
      final cbBatteryPresent =
          await widget.repository.get('cb-battery', 'present');
      final cbBatteryCharge =
          await widget.repository.get('cb-battery', 'charge');
      final cbBatteryChargeStatus =
          await widget.repository.get('cb-battery', 'charge-status');

      // Load AUX battery values
      final auxBatteryCharge =
          await widget.repository.get('aux-battery', 'charge');
      final auxBatteryVoltage =
          await widget.repository.get('aux-battery', 'voltage');
      final auxBatteryChargeStatus =
          await widget.repository.get('aux-battery', 'charge-status');

      // Load engine values
      final speed = await widget.repository.get('engine-ecu', 'speed');
      final rpm = await widget.repository.get('engine-ecu', 'rpm');
      final odometer = await widget.repository.get('engine-ecu', 'odometer');

      // Load GPS values
      final gpsLatitude = await widget.repository.get('gps', 'latitude');
      final gpsLongitude = await widget.repository.get('gps', 'longitude');
      final gpsCourse = await widget.repository.get('gps', 'course');
      final gpsSpeed = await widget.repository.get('gps', 'speed');
      final gpsAltitude = await widget.repository.get('gps', 'altitude');

      // Load navigation values
      final navigationDestination = await widget.repository.get('navigation', 'destination');
      final navigationLatitude = await widget.repository.get('navigation', 'latitude');
      final navigationLongitude = await widget.repository.get('navigation', 'longitude');
      final navigationAddress = await widget.repository.get('navigation', 'address');
      final navigationTimestamp = await widget.repository.get('navigation', 'timestamp');

      // Update state with loaded values
      setState(() {
        if (blinkerState != null) _blinkerState = blinkerState;
        if (handlebarPosition != null) _handlebarPosition = handlebarPosition;
        if (kickstandState != null) _kickstandState = kickstandState;
        if (vehicleState != null) _vehicleState = vehicleState;
        if (leftBrakeState != null) _leftBrakeState = leftBrakeState;
        if (rightBrakeState != null) _rightBrakeState = rightBrakeState;
        if (seatboxLockState != null) _seatboxLockState = seatboxLockState;

        if (bluetoothStatus != null) _bluetoothStatus = bluetoothStatus;
        if (internetStatus != null) _internetStatus = internetStatus;
        if (internetAccessTech != null) _internetAccessTech = internetAccessTech;
        if (signalQuality != null)
          _signalQuality = int.tryParse(signalQuality) ?? 0;
        if (cloudStatus != null) _cloudStatus = cloudStatus;
        if (gpsState != null) _gpsState = gpsState;

        // OTA status fields
        if (dbcStatus != null) _dbcStatus = dbcStatus;
        if (dbcUpdateVersion != null) _dbcUpdateVersion = dbcUpdateVersion;
        if (dbcUpdateMethod != null) _dbcUpdateMethod = dbcUpdateMethod;
        if (dbcDownloadProgress != null) _dbcDownloadProgress = int.tryParse(dbcDownloadProgress) ?? 0;
        if (mdbStatus != null) _mdbStatus = mdbStatus;
        if (mdbUpdateVersion != null) _mdbUpdateVersion = mdbUpdateVersion;
        if (mdbUpdateMethod != null) _mdbUpdateMethod = mdbUpdateMethod;
        if (mdbDownloadProgress != null) _mdbDownloadProgress = int.tryParse(mdbDownloadProgress) ?? 0;

        if (battery0Present != null)
          _battery0Present = battery0Present.toLowerCase() == 'true';
        if (battery0Charge != null)
          _simulatedBatteryCharge0 = int.tryParse(battery0Charge) ?? 100;
        if (battery0State != null) _battery0State = battery0State;

        if (battery1Present != null)
          _battery1Present = battery1Present.toLowerCase() == 'true';
        if (battery1Charge != null)
          _simulatedBatteryCharge1 = int.tryParse(battery1Charge) ?? 100;
        if (battery1State != null) _battery1State = battery1State;

        if (motorVoltage != null)
          _motorVoltage = int.tryParse(motorVoltage) ?? 50000;
        if (motorRpm != null)
          _motorRpm = int.tryParse(motorRpm) ?? 0;
        if (motorTemperature != null)
          _motorTemperature = int.tryParse(motorTemperature) ?? 25;
        if (motorThrottle != null) _motorThrottle = motorThrottle;
        if (motorKers != null) _motorKers = motorKers;
        if (motorKersReasonOff != null) _motorKersReasonOff = motorKersReasonOff;

        // Battery fault codes
        _battery0Fault = battery0FaultMembers
            .map((m) => int.tryParse(m) ?? 0)
            .where((f) => f != 0)
            .toSet();
        _battery1Fault = battery1FaultMembers
            .map((m) => int.tryParse(m) ?? 0)
            .where((f) => f != 0)
            .toSet();

        // CB battery values
        if (cbBatteryPresent != null)
          _cbBatteryPresent = cbBatteryPresent.toLowerCase() == 'true';
        if (cbBatteryCharge != null)
          _cbBatteryCharge = int.tryParse(cbBatteryCharge) ?? 100;
        if (cbBatteryChargeStatus != null)
          _cbBatteryChargeStatus = cbBatteryChargeStatus;

        // AUX battery values
        if (auxBatteryCharge != null) {
          final charge = int.tryParse(auxBatteryCharge) ?? 100;
          // Round to nearest 25% increment
          _auxBatteryCharge = ((charge / 25).round() * 25).clamp(0, 100);
        }
        if (auxBatteryVoltage != null)
          _auxBatteryVoltage = int.tryParse(auxBatteryVoltage) ?? 12500;
        if (auxBatteryChargeStatus != null)
          _auxBatteryChargeStatus = auxBatteryChargeStatus;

        if (speed != null) _simulatedSpeed = int.tryParse(speed) ?? 0;
        if (rpm != null) _simulatedRpm = int.tryParse(rpm) ?? 0;
        if (odometer != null) {
          final odometerValue = double.tryParse(odometer) ?? 0.0;
          _simulatedOdometer =
              odometerValue / 1000.0; // Convert from meters to km
        }

        if (gpsLatitude != null) _gpsLatitude = double.tryParse(gpsLatitude) ?? 0.0;
        if (gpsLongitude != null) _gpsLongitude = double.tryParse(gpsLongitude) ?? 0.0;
        if (gpsCourse != null) _gpsCourse = double.tryParse(gpsCourse) ?? 0.0;
        if (gpsSpeed != null) _gpsSpeed = double.tryParse(gpsSpeed) ?? 0.0;
        if (gpsAltitude != null) _gpsAltitude = double.tryParse(gpsAltitude) ?? 0.0;

        if (navigationDestination != null) _navigationDestination = navigationDestination;
        if (navigationLatitude != null) _navigationLatitude = navigationLatitude;
        if (navigationLongitude != null) _navigationLongitude = navigationLongitude;
        if (navigationAddress != null) _navigationAddress = navigationAddress;
        if (navigationTimestamp != null) _navigationTimestamp = navigationTimestamp;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading values: $e';
      });
    }
  }

  void _clearErrorMessage() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _initializeValues() async {
    // Initialize engine values
    await _updateEngineValues();

    // Initialize battery values
    await _updateBatteryValues();

    // Initialize CB and AUX battery values
    await _updateCbBatteryValues();
    await _updateAuxBatteryValues();

    // Initialize vehicle states if not already set
    await Future.wait([
      _publishEvent('vehicle', 'blinker:state', _blinkerState),
      _publishEvent('vehicle', 'handlebar:position', _handlebarPosition),
      _publishEvent('vehicle', 'handlebar:lock-sensor', _handlebarPosition),
      _publishEvent('vehicle', 'kickstand', _kickstandState),
      _publishEvent('vehicle', 'state', _vehicleState),
      _publishEvent('vehicle', 'brake:left', _leftBrakeState),
      _publishEvent('vehicle', 'brake:right', _rightBrakeState),
      _publishEvent('vehicle', 'seatbox:button', _seatboxButtonState),
    ]);

    // Initialize system states if not already set
    await Future.wait([
      _publishEvent('ble', 'status', _bluetoothStatus),
      _publishEvent('internet', 'modem-state', _internetStatus),
      _publishEvent('internet', 'status', _internetStatus),
      _publishEvent('internet', 'signal-quality', _signalQuality.toString()),
      _publishEvent('internet', 'unu-cloud', _cloudStatus),
      _publishEvent('gps', 'state', _gpsState),
    ]);

    // Initialize OTA status fields
    await _updateOtaValues();

    // Start GPS timestamp simulation if GPS is already fix-established
    if (_gpsState == 'fix-established') {
      _startGpsTimestampSimulation();
    }
  }

  Future<void> _updateEngineValues() async {
    final futures = [
      _publishEvent('engine-ecu', 'speed', _simulatedSpeed.toString()),
      _publishEvent('engine-ecu', 'rpm', _simulatedRpm.toString()),
      _publishEvent('engine-ecu', 'motor:current',
          (_simulatedMotorCurrent * 1000).toString()),
      _publishEvent(
          'engine-ecu', 'odometer', (_simulatedOdometer * 1000).toString()),
    ];
    await Future.wait(futures);
  }

  Future<void> _updateBatteryValues() async {
    final futures = [
      _publishEvent('battery:0', 'present', _battery0Present.toString()),
      _publishEvent('battery:1', 'present', _battery1Present.toString()),
      if (_battery0Present)
        _publishEvent(
            'battery:0', 'charge', _simulatedBatteryCharge0.toString()),
      if (_battery1Present)
        _publishEvent(
            'battery:1', 'charge', _simulatedBatteryCharge1.toString()),
    ];
    await Future.wait(futures);

    // Update fault Sets
    await _updateBatteryFaults(0, _battery0Fault);
    await _updateBatteryFaults(1, _battery1Fault);
  }

  Future<void> _updateBatteryFaults(int batteryId, Set<int> faults) async {
    final setKey = 'battery:$batteryId:fault';
    final currentMembers = await widget.repository.getSetMembers(setKey);
    final currentFaults = currentMembers
        .map((m) => int.tryParse(m) ?? 0)
        .where((f) => f != 0)
        .toSet();

    // Add new faults
    for (final fault in faults) {
      if (!currentFaults.contains(fault)) {
        await widget.repository.addToSet(setKey, fault.toString());
      }
    }

    // Remove faults that are no longer present
    for (final fault in currentFaults) {
      if (!faults.contains(fault)) {
        await widget.repository.removeFromSet(setKey, fault.toString());
      }
    }

    // Publish to trigger PUBSUB update
    if (faults != currentFaults) {
      // For InMemoryRepository, we need to trigger the PUBSUB notification
      if (widget.repository is InMemoryMDBRepository) {
        await _publishEvent('battery:$batteryId', 'fault', '');
      }
    }
  }

  Future<void> _updateCbBatteryValues() async {
    final futures = [
      _publishEvent('cb-battery', 'present', _cbBatteryPresent.toString()),
      _publishEvent('cb-battery', 'charge', _cbBatteryCharge.toString()),
      _publishEvent('cb-battery', 'charge-status', _cbBatteryChargeStatus),
    ];
    await Future.wait(futures);
  }

  Future<void> _updateAuxBatteryValues() async {
    final futures = [
      _publishEvent('aux-battery', 'charge', _auxBatteryCharge.toString()),
      _publishEvent('aux-battery', 'voltage', _auxBatteryVoltage.toString()),
      _publishEvent('aux-battery', 'charge-status', _auxBatteryChargeStatus),
    ];
    await Future.wait(futures);
  }

  Future<void> _updateGpsValues() async {
    final futures = [
      _publishEvent('gps', 'latitude', _gpsLatitude.toStringAsFixed(6)),
      _publishEvent('gps', 'longitude', _gpsLongitude.toStringAsFixed(6)),
      _publishEvent('gps', 'course', _gpsCourse.toStringAsFixed(1)),
      _publishEvent('gps', 'speed', _gpsSpeed.toStringAsFixed(1)),
      _publishEvent('gps', 'altitude', _gpsAltitude.toStringAsFixed(1)),
    ];
    await Future.wait(futures);
  }

  Future<void> _updateNavigationValues() async {
    final futures = [
      _publishEvent('navigation', 'destination', _navigationDestination),
      _publishEvent('navigation', 'latitude', _navigationLatitude),
      _publishEvent('navigation', 'longitude', _navigationLongitude),
      _publishEvent('navigation', 'address', _navigationAddress),
      _publishEvent('navigation', 'timestamp', _navigationTimestamp),
    ];
    await Future.wait(futures);
  }

  Future<void> _updateOtaValues() async {
    final futures = [
      _publishEvent('ota', 'status:dbc', _dbcStatus),
      _publishEvent('ota', 'update-version:dbc', _dbcUpdateVersion),
      _publishEvent('ota', 'update-method:dbc', _dbcUpdateMethod),
      _publishEvent('ota', 'download-progress:dbc', _dbcDownloadProgress.toString()),
      _publishEvent('ota', 'status:mdb', _mdbStatus),
      _publishEvent('ota', 'update-version:mdb', _mdbUpdateVersion),
      _publishEvent('ota', 'update-method:mdb', _mdbUpdateMethod),
      _publishEvent('ota', 'download-progress:mdb', _mdbDownloadProgress.toString()),
    ];
    await Future.wait(futures);
  }

  Future<void> _publishEvent(String channel, String key, String value) async {
    try {
      await widget.repository.set(channel, key, value);
      _clearErrorMessage(); // Clear error when operation succeeds
    } catch (e) {
      // Silently ignore Redis errors in simulator - it will reconnect automatically
    }
  }

  void _startGpsTimestampSimulation() {
    _gpsTimestampTimer?.cancel();
    _gpsTimestampTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_gpsState == 'fix-established') {
        final currentTimestamp = DateTime.now().toIso8601String();
        await _publishEvent('gps', 'timestamp', currentTimestamp);
      }
    });
  }

  void _stopGpsTimestampSimulation() {
    _gpsTimestampTimer?.cancel();
    _gpsTimestampTimer = null;
  }

  // Button press/release methods
  Future<void> _seatboxButtonDown() async {
    print('Seatbox button DOWN');
    setState(() => _seatboxButtonState = 'on');
    // Update the hash state
    await _publishEvent('vehicle', 'seatbox:button', 'on');
    // Also publish a direct button event
    await _publishButtonEvent('seatbox:on');
  }

  Future<void> _seatboxButtonUp() async {
    print('Seatbox button UP');
    setState(() => _seatboxButtonState = 'off');
    // Update the hash state
    await _publishEvent('vehicle', 'seatbox:button', 'off');
    // Also publish a direct button event
    await _publishButtonEvent('seatbox:off');
  }

  // Helper method to publish a button event via PUBSUB
  Future<void> _publishButtonEvent(String event) async {
    try {
      await widget.repository.publishButtonEvent(event);
      print('Published button event: $event');
    } catch (e) {
      print('Error publishing button event: $e');
    }
  }

  Future<void> _simulateBrakeDoubleTap(String brake) async {
    // First press
    await _publishEvent('vehicle', 'brake:$brake', 'on');
    await _publishButtonEvent('brake:$brake:on');

    await Future.delayed(const Duration(milliseconds: 100));

    // First release
    await _publishEvent('vehicle', 'brake:$brake', 'off');
    await _publishButtonEvent('brake:$brake:off');

    await Future.delayed(const Duration(milliseconds: 100));

    // Second press
    await _publishEvent('vehicle', 'brake:$brake', 'on');
    await _publishButtonEvent('brake:$brake:on');

    await Future.delayed(const Duration(milliseconds: 100));

    // Second release
    await _publishEvent('vehicle', 'brake:$brake', 'off');
    await _publishButtonEvent('brake:$brake:off');
  }

  Future<void> _simulateBrakeTap(String brake) async {
    // Press
    await _publishEvent('vehicle', 'brake:$brake', 'on');
    await _publishButtonEvent('brake:$brake:on');

    await Future.delayed(const Duration(milliseconds: 100));

    // Release
    await _publishEvent('vehicle', 'brake:$brake', 'off');
    await _publishButtonEvent('brake:$brake:off');
  }

  @override
  void dispose() {
    _gpsTimestampTimer?.cancel();
    _connectionStateSubscription?.cancel();
    super.dispose();
  }

  // Card builder methods
  Widget _buildMotorCard() {
    return _buildSection(
      'Motor',
      [
        _buildSlider(
          'Speed (km/h)',
          _simulatedSpeed,
          0,
          100,
          (value) {
            setState(() => _simulatedSpeed = value.toInt());
            _updateEngineValues();
          },
        ),
        _buildSlider(
          'Motor Current (A)',
          _simulatedMotorCurrent,
          -10,
          100,
          (value) {
            setState(() => _simulatedMotorCurrent = value.toInt());
            _updateEngineValues();
          },
        ),
        _buildSlider(
          'Motor Voltage (V)',
          _motorVoltage,
          35000,
          60000,
          (value) {
            setState(() => _motorVoltage = value.toInt());
            _publishEvent('engine-ecu', 'motor:voltage', value.toInt().toString());
          },
          formatter: (v) => (v / 1000.0).toStringAsFixed(1),
          parser: (s) {
            final d = double.tryParse(s);
            return d != null ? (d * 1000).round() : null;
          },
        ),
      ],
    );
  }

  Widget _buildBattery0Card() {
    return _buildSection(
      'Battery 0',
      [
        if (_battery0Present)
          _buildSlider(
            'Charge (%)',
            _simulatedBatteryCharge0,
            0,
            100,
            (value) {
              setState(() => _simulatedBatteryCharge0 = value.toInt());
              _updateBatteryValues();
            },
          ),
        _buildSegmentedButton(
          'State',
          ['unknown', 'asleep', 'active', 'idle'],
          _battery0State,
          (value) {
            setState(() => _battery0State = value);
            _publishEvent('battery:0', 'state', value);
          },
        ),
        const SizedBox(height: 8),
        Text(
            'Fault Codes (Current: ${_battery0Fault.isEmpty ? "None" : _battery0Fault.map((f) => "B$f").join(", ")})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildFaultButton(0, 'Clear', 0),
            _buildFaultButton(0, 'B7', 7),
            _buildFaultButton(0, 'B13', 13),
            _buildFaultButton(0, 'B14', 14),
            _buildFaultButton(0, 'B32', 32),
            _buildFaultButton(0, 'B34', 34),
          ],
        ),
      ],
      titleTrailing: Checkbox(
        value: _battery0Present,
        onChanged: (value) {
          setState(() => _battery0Present = value ?? false);
          _updateBatteryValues();
        },
      ),
    );
  }

  Widget _buildBattery1Card() {
    return _buildSection(
      'Battery 1',
      [
        if (_battery1Present)
          _buildSlider(
            'Charge (%)',
            _simulatedBatteryCharge1,
            0,
            100,
            (value) {
              setState(() => _simulatedBatteryCharge1 = value.toInt());
              _updateBatteryValues();
            },
          ),
        _buildSegmentedButton(
          'State',
          ['unknown', 'asleep', 'active', 'idle'],
          _battery1State,
          (value) {
            setState(() => _battery1State = value);
            _publishEvent('battery:1', 'state', value);
          },
        ),
        const SizedBox(height: 8),
        Text(
            'Fault Codes (Current: ${_battery1Fault.isEmpty ? "None" : _battery1Fault.map((f) => "B$f").join(", ")})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildFaultButton(1, 'Clear', 0),
            _buildFaultButton(1, 'B7', 7),
            _buildFaultButton(1, 'B13', 13),
            _buildFaultButton(1, 'B14', 14),
            _buildFaultButton(1, 'B32', 32),
            _buildFaultButton(1, 'B34', 34),
          ],
        ),
      ],
      titleTrailing: Checkbox(
        value: _battery1Present,
        onChanged: (value) {
          setState(() => _battery1Present = value ?? false);
          _updateBatteryValues();
        },
      ),
    );
  }

  Widget _buildCbBatteryCard() {
    return _buildSection(
      'CB Battery',
      [
        if (_cbBatteryPresent)
          _buildSlider(
            'Charge (%)',
            _cbBatteryCharge,
            0,
            100,
            (value) {
              setState(() => _cbBatteryCharge = value.toInt());
              _updateCbBatteryValues();
            },
          ),
        _buildSegmentedButton(
          'Charge Status',
          ['not-charging', 'charging', 'unknown'],
          _cbBatteryChargeStatus,
          (value) {
            setState(() => _cbBatteryChargeStatus = value);
            _updateCbBatteryValues();
          },
        ),
      ],
      titleTrailing: Checkbox(
        value: _cbBatteryPresent,
        onChanged: (value) {
          setState(() => _cbBatteryPresent = value ?? false);
          _updateCbBatteryValues();
        },
      ),
    );
  }

  Widget _buildAuxBatteryCard() {
    return _buildSection(
      'AUX Battery',
      [
        _buildSegmentedButton(
          'Charge (%)',
          ['0', '25', '50', '75', '100'],
          _auxBatteryCharge.toString(),
          (value) {
            setState(() => _auxBatteryCharge = int.parse(value));
            _updateAuxBatteryValues();
          },
        ),
        _buildSlider(
          'Voltage (V)',
          _auxBatteryVoltage,
          9000,
          15000,
          (value) {
            setState(() => _auxBatteryVoltage = value.toInt());
            _updateAuxBatteryValues();
          },
          formatter: (v) => (v / 1000.0).toStringAsFixed(1),
          parser: (s) {
            final d = double.tryParse(s);
            return d != null ? (d * 1000).round() : null;
          },
        ),
        _buildSegmentedButton(
          'Charge Status',
          [
            'not-charging',
            'float-charge',
            'absorption-charge',
            'bulk-charge'
          ],
          _auxBatteryChargeStatus,
          (value) {
            setState(() => _auxBatteryChargeStatus = value);
            _updateAuxBatteryValues();
          },
        ),
      ],
    );
  }

  Widget _buildVehicleSwitchesCard() {
    return _buildSection(
      'Vehicle Switches',
      [
        _buildGroupHeading('Blinker'),
        _buildSegmentedButton(
          '',
          ['off', 'left', 'right', 'both'],
          _blinkerState,
          (value) {
            setState(() => _blinkerState = value);
            _publishEvent('vehicle', 'blinker:state', value);
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Handlebar'),
        _buildSegmentedButton(
          '',
          ['unlocked', 'locked'],
          _handlebarPosition,
          (value) {
            setState(() => _handlebarPosition = value);
            _publishEvent('vehicle', 'handlebar:position', value);
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Kickstand'),
        _buildSegmentedButton(
          '',
          ['up', 'down'],
          _kickstandState,
          (value) {
            setState(() => _kickstandState = value);
            _publishEvent('vehicle', 'kickstand', value);
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Seatbox'),
        Row(
          children: [
            Expanded(
              child: _buildSegmentedButton(
                '',
                ['open', 'closed'],
                _seatboxLockState,
                (value) {
                  setState(() => _seatboxLockState = value);
                  _publishEvent('vehicle', 'seatbox:lock', value);
                },
              ),
            ),
            const SizedBox(width: 4),
            Listener(
              onPointerDown: (_) => _seatboxButtonDown(),
              onPointerUp: (_) => _seatboxButtonUp(),
              onPointerCancel: (_) => _seatboxButtonUp(),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 32),
                  backgroundColor: _seatboxButtonState == 'on'
                      ? Colors.green.shade700
                      : Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: Text(
                  'Hold',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleStateCard() {
    return _buildSection(
      'Vehicle State',
      [
        _buildGroupHeading('State'),
        _buildSegmentedButton(
          '',
          [
            'stand-by',
            'parked',
            'ready-to-drive',
            'shutting-down',
            'booting',
            'updating',
            'off',
            'hibernating',
            'hibernating-imminent',
            'suspending',
            'suspending-imminent'
          ],
          _vehicleState,
          (value) {
            setState(() => _vehicleState = value);
            _publishEvent('vehicle', 'state', value);
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Hibernation States'),
        _buildSegmentedButton(
          '',
          ['waiting-hibernation', 'waiting-hibernation-advanced'],
          _vehicleState,
          (value) {
            setState(() => _vehicleState = value);
            _publishEvent('vehicle', 'state', value);
          },
        ),
        _buildSegmentedButton(
          '',
          ['waiting-hibernation-seatbox', 'waiting-hibernation-confirm'],
          _vehicleState,
          (value) {
            setState(() => _vehicleState = value);
            _publishEvent('vehicle', 'state', value);
          },
        ),
        _groupSpacer,
        _buildTextField(
          label: 'Odometer (km)',
          value: _simulatedOdometer.toStringAsFixed(1),
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null) {
              setState(() => _simulatedOdometer = parsedValue);
              _updateEngineValues();
            }
          },
        ),
      ],
    );
  }

  Widget _buildBrakesCard() {
    return _buildSection(
      'Brakes',
      [
        _buildGroupHeading('Left'),
        Row(
          children: [
            Expanded(
              child: _buildSegmentedButton(
                '',
                ['off', 'on'],
                _leftBrakeState,
                (value) {
                  setState(() => _leftBrakeState = value);
                  if (value == 'on') {
                    print('SIM: Left brake pressed via UI button');
                  } else {
                    print('SIM: Left brake released via UI button');
                  }
                  _publishEvent('vehicle', 'brake:left', value);
                  _publishButtonEvent('brake:left:$value');
                },
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _simulateBrakeTap('left'),
              child: const Text('Tap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _simulateBrakeDoubleTap('left'),
              child: const Text('2x', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        _groupSpacer,
        _buildGroupHeading('Right'),
        Row(
          children: [
            Expanded(
              child: _buildSegmentedButton(
                '',
                ['off', 'on'],
                _rightBrakeState,
                (value) {
                  setState(() => _rightBrakeState = value);
                  if (value == 'on') {
                    print('SIM: Right brake pressed via UI button');
                  } else {
                    print('SIM: Right brake released via UI button');
                  }
                  _publishEvent('vehicle', 'brake:right', value);
                  _publishButtonEvent('brake:right:$value');
                },
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _simulateBrakeTap('right'),
              child: const Text('Tap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _simulateBrakeDoubleTap('right'),
              child: const Text('2x', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectivityCard() {
    return _buildSection(
      'Connectivity',
      [
        _buildGroupHeading('Bluetooth'),
        _buildSegmentedButton(
          '',
          ['disconnected', 'connected'],
          _bluetoothStatus,
          (value) {
            setState(() => _bluetoothStatus = value);
            _publishEvent('ble', 'status', value);
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Internet'),
        _buildSegmentedButton(
          '',
          ['disconnected', 'connected'],
          _internetStatus,
          (value) {
            setState(() => _internetStatus = value);
            _publishEvent('internet', 'status', value);
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Signal Quality'),
        _buildSegmentedButton(
          '',
          ['UNKNOWN', '2G', '3G', '4G', '5G'],
          _internetAccessTech,
          (value) {
            setState(() => _internetAccessTech = value);
            _publishEvent('internet', 'access-tech', value);
          },
        ),
        _buildSlider(
          '',
          _signalQuality,
          0,
          100,
          (value) {
            setState(() => _signalQuality = value.toInt());
            _publishEvent(
                'internet', 'signal-quality', value.toInt().toString());
          },
        ),
        _groupSpacer,
        _buildGroupHeading('Cloud'),
        _buildSegmentedButton(
          '',
          ['disconnected', 'connected'],
          _cloudStatus,
          (value) {
            setState(() => _cloudStatus = value);
            _publishEvent('internet', 'unu-cloud', value);
          },
        ),
      ],
    );
  }

  Widget _buildGpsCard() {
    return _buildSection(
      'GPS',
      [
        _buildGroupHeading('GPS Status'),
        _buildSegmentedButton(
          '',
          ['off', 'searching', 'fix-established', 'error'],
          _gpsState,
          (value) {
            setState(() => _gpsState = value);
            _publishEvent('gps', 'state', value);

            if (value == 'fix-established') {
              _startGpsTimestampSimulation();
            } else {
              _stopGpsTimestampSimulation();
            }
          },
        ),
        _groupSpacer,
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Latitude',
                value: _gpsLatitude.toStringAsFixed(6),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                onSubmitted: (value) {
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    setState(() => _gpsLatitude = parsedValue);
                    _updateGpsValues();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'Longitude',
                value: _gpsLongitude.toStringAsFixed(6),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                onSubmitted: (value) {
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    setState(() => _gpsLongitude = parsedValue);
                    _updateGpsValues();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationCard() {
    return _buildSection(
      'Navigation',
      [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Latitude',
                value: _navigationLatitude,
                hintText: '52.5200',
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                onSubmitted: (value) {
                  setState(() => _navigationLatitude = value);
                  _updateNavigationValues();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'Longitude',
                value: _navigationLongitude,
                hintText: '13.4050',
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                onSubmitted: (value) {
                  setState(() => _navigationLongitude = value);
                  _updateNavigationValues();
                },
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              height: 32,
              width: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  if (_navigationLatitude.isNotEmpty && _navigationLongitude.isNotEmpty) {
                    setState(() => _navigationDestination = '$_navigationLatitude,$_navigationLongitude');
                    _updateNavigationValues();
                  }
                },
                child: const Text('↓', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          label: 'Address',
          value: _navigationAddress,
          hintText: 'Alexanderplatz, Berlin',
          onSubmitted: (value) {
            setState(() => _navigationAddress = value);
            _updateNavigationValues();
          },
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Timestamp'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      hintText: '2025-10-25T12:00:00Z',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    controller: TextEditingController(text: _navigationTimestamp),
                    onSubmitted: (value) {
                      setState(() => _navigationTimestamp = value);
                      _updateNavigationValues();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () {
                      final now = DateTime.now().toUtc();
                      final timestamp = now.toIso8601String().split('.')[0] + 'Z';
                      setState(() => _navigationTimestamp = timestamp);
                      _updateNavigationValues();
                    },
                    child: const Text('Now', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Destination (legacy)'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      hintText: '48.123456,11.123456',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    controller: TextEditingController(text: _navigationDestination),
                    onSubmitted: (value) {
                      setState(() => _navigationDestination = value);
                      _updateNavigationValues();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      final parts = _navigationDestination.split(',');
                      if (parts.length == 2) {
                        setState(() {
                          _navigationLatitude = parts[0].trim();
                          _navigationLongitude = parts[1].trim();
                        });
                        _updateNavigationValues();
                      }
                    },
                    child: const Text('↑', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 36),
          ),
          onPressed: () {
            setState(() {
              _navigationDestination = '';
              _navigationLatitude = '';
              _navigationLongitude = '';
              _navigationAddress = '';
              _navigationTimestamp = '';
            });
            _updateNavigationValues();
          },
          child: _buildLabel('Clear All'),
        ),
      ],
    );
  }

  Widget _buildOtaDbcCard() {
    return _buildSection(
      'OTA - DBC',
      [
        _buildGroupHeading('Status'),
        _buildSegmentedButton(
          '',
          ['idle', 'downloading', 'installing', 'rebooting', 'error'],
          _dbcStatus,
          (value) {
            setState(() => _dbcStatus = value);
            _updateOtaValues();
          },
        ),
        const SizedBox(height: 8),
        _buildSlider(
          'Download Progress (%)',
          _dbcDownloadProgress,
          0,
          100,
          (value) {
            setState(() => _dbcDownloadProgress = value.toInt());
            _updateOtaValues();
          },
        ),
        const SizedBox(height: 8),
        _buildGroupHeading('Update Method'),
        _buildSegmentedButton(
          '',
          ['', 'full', 'delta'],
          _dbcUpdateMethod,
          (value) {
            setState(() => _dbcUpdateMethod = value);
            _updateOtaValues();
          },
        ),
      ],
    );
  }

  Widget _buildOtaMdbCard() {
    return _buildSection(
      'OTA - MDB',
      [
        _buildGroupHeading('Status'),
        _buildSegmentedButton(
          '',
          ['idle', 'downloading', 'installing', 'rebooting', 'error'],
          _mdbStatus,
          (value) {
            setState(() => _mdbStatus = value);
            _updateOtaValues();
          },
        ),
        const SizedBox(height: 8),
        _buildSlider(
          'Download Progress (%)',
          _mdbDownloadProgress,
          0,
          100,
          (value) {
            setState(() => _mdbDownloadProgress = value.toInt());
            _updateOtaValues();
          },
        ),
        const SizedBox(height: 8),
        _buildGroupHeading('Update Method'),
        _buildSegmentedButton(
          '',
          ['', 'full', 'delta'],
          _mdbUpdateMethod,
          (value) {
            setState(() => _mdbUpdateMethod = value);
            _updateOtaValues();
          },
        ),
      ],
    );
  }

  Widget _buildEcuExtendedCard() {
    return _buildSection(
      'ECU Extended',
      [
        _buildSlider(
          'RPM',
          _motorRpm,
          0,
          1000,
          (value) {
            setState(() => _motorRpm = value.toInt());
            _publishEvent('engine-ecu', 'rpm', value.toInt().toString());
          },
        ),
        _buildSlider(
          'Temperature (°C)',
          _motorTemperature,
          -20,
          100,
          (value) {
            setState(() => _motorTemperature = value.toInt());
            _publishEvent('engine-ecu', 'temperature', value.toInt().toString());
          },
        ),
        const SizedBox(height: 8),
        _buildGroupHeading('Throttle'),
        _buildSegmentedButton(
          '',
          ['off', 'on'],
          _motorThrottle,
          (value) {
            setState(() => _motorThrottle = value);
            _publishEvent('engine-ecu', 'throttle', value);
          },
        ),
        const SizedBox(height: 8),
        _buildGroupHeading('KERS'),
        _buildSegmentedButton(
          '',
          ['off', 'on'],
          _motorKers,
          (value) {
            setState(() => _motorKers = value);
            _publishEvent('engine-ecu', 'kers', value);
          },
        ),
        const SizedBox(height: 8),
        _buildSmallLabel('KERS Reason Off'),
        _buildSegmentedButton(
          '',
          ['none', 'cold', 'hot'],
          _motorKersReasonOff,
          (value) {
            setState(() => _motorKersReasonOff = value);
            _publishEvent('engine-ecu', 'kers-reason-off', value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard cluster - fixed, doesn't scroll
                SizedBox(
                  width: 480,
                  child: _buildSection("Screen", [
                    SizedBox(
                      width: 480,
                      height: 480,
                      child: MainScreen(),
                    ),
                  ]),
                ),

                const SizedBox(width: 4),

                // Control cards - scrollable independently
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.start,
                      children: [
                        for (final builder in _cardBuilders)
                          SizedBox(
                            width: 258,
                            child: builder(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.red.withOpacity(0.8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, {Widget? titleTrailing}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (titleTrailing != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  titleTrailing,
                ],
              )
            else
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<double> onChanged, {
    String Function(int)? formatter,
    int? Function(String)? parser,
  }) {
    final displayFormatter = formatter ?? (v) => v.toString();
    final displayParser = parser ?? (s) => int.tryParse(s);
    final displayText = displayFormatter(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) _buildLabel(label),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: (max - min).toInt(),
                label: value.toStringAsFixed(1),
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: TextEditingController(text: displayText)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: displayText.length),
                  ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (text) {
                  final newValue = displayParser(text);
                  if (newValue != null && newValue >= min && newValue <= max) {
                    onChanged(newValue.toDouble());
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentedButton(
    String label,
    List<String> options,
    String selectedValue,
    ValueChanged<String> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) _buildLabel(label),
        if (label.isNotEmpty) const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
                foregroundColor:
                    isSelected ? Theme.of(context).colorScheme.onPrimary : null,
              ),
              onPressed: () => onSelected(option),
              child: Text(option, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFaultButton(int batteryId, String label, int faultCode) {
    final currentFaultSet = batteryId == 0 ? _battery0Fault : _battery1Fault;
    final isSelected = faultCode == 0
        ? currentFaultSet.isEmpty
        : currentFaultSet.contains(faultCode);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: isSelected
            ? (faultCode == 0 ? Colors.green : Colors.red.shade700)
            : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      onPressed: () async {
        setState(() {
          if (faultCode == 0) {
            // Clear all faults
            if (batteryId == 0) {
              _battery0Fault.clear();
            } else {
              _battery1Fault.clear();
            }
          } else {
            // Toggle individual fault
            if (batteryId == 0) {
              if (_battery0Fault.contains(faultCode)) {
                _battery0Fault.remove(faultCode);
              } else {
                _battery0Fault.add(faultCode);
              }
            } else {
              if (_battery1Fault.contains(faultCode)) {
                _battery1Fault.remove(faultCode);
              } else {
                _battery1Fault.add(faultCode);
              }
            }
          }
        });
        await _updateBatteryValues();
      },
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onSubmitted,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 4),
        TextField(
          keyboardType: keyboardType ?? TextInputType.text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          controller: TextEditingController(text: value),
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }

  Widget _buildGroupHeading(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12));
  }

  Widget _buildSmallLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12));
  }

  Widget get _groupSpacer => const SizedBox(height: 12);
}
