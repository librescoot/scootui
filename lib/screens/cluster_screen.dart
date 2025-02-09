import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/vehicle_state.dart';
import '../services/redis_service.dart';
import '../services/menu_manager.dart';
import '../theme_config.dart';

// Import widgets
import '../widgets/status_bars/top_status_bar.dart';
import '../widgets/general/warning_indicators.dart';
import '../widgets/speedometer/speedometer_display.dart';
import '../widgets/power/power_display.dart';
import '../widgets/general/odometer_display.dart';
import '../widgets/menu/menu_overlay.dart';
import '../widgets/status_bars/bottom_status_bar.dart';

class ClusterScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeSwitch;

  const ClusterScreen({
    super.key, 
    this.onThemeSwitch,
  });

  @override
  State<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends State<ClusterScreen> {
  final VehicleState _vehicleState = VehicleState();
  late RedisService _redis;
  late MenuManager _menuManager;
  late Timer _clockTimer;
  String _currentTime = '';
  String? _errorMessage;
  Timer? _reconnectTimer;
  String? _bluetoothPinCode;

  // Track previous odometer values for animation
  double _previousTrip = 0.0;
  double _previousTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _setupRedis();
    _startClock();
    _updateTime();
  }

Future<void> _setupRedis() async {
  _redis = RedisService(
    'dummyhost',  // this will be ignored
    6379, 
    _vehicleState,
    onConnectionLost: (message) {
      setState(() {
        _errorMessage = message;
      });
    },
    onConnectionRestored: () {
      setState(() {
        _errorMessage = null;
      });
    },
    onThemeSwitch: widget.onThemeSwitch,
    onBrakeEvent: (brake, state) {
      if (state == 'on') {
        if (brake == 'brake:left') {
          _menuManager.handleLeftBrake(_vehicleState.isParked, state);
        } else if (brake == 'brake:right') {
          _menuManager.handleRightBrake();
        }
      }
    },
    onBluetoothPinCodeEvent: (pinCode) {
      print('DEBUG: onBluetoothPinCodeEvent called with pin code: $pinCode');
      setState(() {
        _bluetoothPinCode = pinCode;
      });
    },
  );
  
  _menuManager = MenuManager((mode) {
    widget.onThemeSwitch?.call(mode);
  }, _vehicleState, _redis);
  
  await _connectToRedis();
}

  Future<void> _connectToRedis() async {
    try {
      await _redis.connect();
      setState(() {
        _errorMessage = null;
      });
      _reconnectTimer?.cancel();
    } catch (e) {
      debugPrint('Failed to connect to Redis: $e');
      setState(() {
        _errorMessage = 'Connection to MDB failed';
      });
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        _connectToRedis();
      });
    }
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _reconnectTimer?.cancel();
    _redis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Store current odometer values before update
    final currentTrip = _vehicleState.odometerKm;
    final currentTotal = _vehicleState.odometerKm;

    // Update previous values for next animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousTrip = currentTrip;
      _previousTotal = currentTotal;
    });

    return Container(
      width: 480,
      height: 480,
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Main content layout
          Column(
            children: [
              // Status bar at top
              StatusBar(
                state: _vehicleState,
                currentTime: _currentTime,
              ),

              // Warning indicators
              WarningIndicators(
                state: _vehicleState,
              ),

              // Main speedometer area
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Speedometer
                    SpeedometerDisplay(
                      state: _vehicleState,
                    ),

                    // Power display at bottom of speedometer area
                    Positioned(
                      bottom: 20,
                      left: 40,
                      right: 40,
                      child: PowerDisplay(
                        state: _vehicleState,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom area with trip/total distance
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
                child: AnimatedOdometerDisplay(
                  state: _vehicleState,
                  previousTrip: _previousTrip,
                  previousTotal: _previousTotal,
                ),
              ),
            ],
          ),

          // Error message overlay
          if (_errorMessage != null)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.red.withOpacity(0.8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Bluetooth pin code notification
          if (_bluetoothPinCode != null)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.withOpacity(0.8),
                child: Text(
                  'Bluetooth Pin Code: $_bluetoothPinCode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
          // Menu overlay
          ListenableBuilder(
            listenable: _menuManager,
            builder: (context, child) {
              return MenuOverlay(
                vehicleState: _vehicleState,
                isVisible: _menuManager.isMenuVisible,
                menuItems: _menuManager.menuItems,
                selectedIndex: _menuManager.selectedIndex,
                isInSubmenu: _menuManager.isInSubmenu,
                onThemeChanged: (mode) {
                  widget.onThemeSwitch?.call(mode);
                  _menuManager.updateThemeMode(mode);
                },
                onClose: () => _menuManager.closeMenu(),
              );
            },
          ),
        ],
      ),
    );
  }
}