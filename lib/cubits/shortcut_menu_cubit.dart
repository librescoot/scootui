import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/mdb_repository.dart';
import '../state/vehicle.dart';
import 'debug_overlay_cubit.dart';
import 'mdb_cubits.dart';
import 'screen_cubit.dart';
import 'theme_cubit.dart';
// import 'trip_cubit.dart'; // Commented out since resetTrip is removed

enum ShortcutMenuState {
  hidden,
  visible,
  confirmingSelection,
}

enum ShortcutMenuItem {
  toggleHazards,
  toggleView,
  toggleTheme,
  toggleDebugOverlay,
  // resetTrip, // Commented out for now
}

// Centralized menu items structure with metadata
class MenuItemData {
  final ShortcutMenuItem item;
  final String label;
  final IconData icon;
  final String description;

  const MenuItemData({
    required this.item,
    required this.label,
    required this.icon,
    required this.description,
  });
}

class MenuItems {
  static const List<MenuItemData> items = [
    MenuItemData(
      item: ShortcutMenuItem.toggleHazards,
      label: 'Hazards',
      icon: Icons.warning_amber_rounded,
      description: 'Toggle hazard lights',
    ),
    MenuItemData(
      item: ShortcutMenuItem.toggleView,
      label: 'View',
      icon: Icons.remove_red_eye_outlined,
      description: 'Switch between cluster and map view',
    ),
    MenuItemData(
      item: ShortcutMenuItem.toggleTheme,
      label: 'Theme',
      icon: Icons.brightness_6,
      description: 'Cycle theme: dark → light → auto',
    ),
    MenuItemData(
      item: ShortcutMenuItem.toggleDebugOverlay,
      label: 'Debug',
      icon: Icons.bug_report,
      description: 'Toggle debug overlay',
    ),
  ];

  static MenuItemData getItemData(ShortcutMenuItem item) {
    return items.firstWhere((data) => data.item == item);
  }

  static IconData getViewToggleIcon(bool isClusterView) {
    return isClusterView ? Icons.map_outlined : Icons.speed;
  }

  static IconData getThemeToggleIcon(bool isAutoMode, ThemeMode currentTheme) {
    if (isAutoMode) {
      // auto → dark (next state is dark)
      return Icons.dark_mode;
    } else if (currentTheme == ThemeMode.dark) {
      // dark → light (next state is light)
      return Icons.light_mode;
    } else {
      // light → auto (next state is auto)
      return Icons.contrast;
    }
  }
}

class ShortcutMenuCubit extends Cubit<ShortcutMenuState> {
  final VehicleSync _vehicleSync;
  final ScreenCubit _screenCubit;
  final ThemeCubit _themeCubit;
  final DebugOverlayCubit _debugOverlayCubit;
  // final TripCubit _tripCubit; // Commented out since resetTrip is removed
  final MDBRepository _mdbRepository;

  late final StreamSubscription<VehicleData> _vehicleSubscription;
  StreamSubscription<(String, String)>? _buttonEventsSubscription;

  // Button press tracking
  DateTime? _buttonPressStartTime;
  DateTime? _lastTapTime; // Changed from _buttonReleaseTime to track tap-to-tap
  Timer? _longPressTimer;
  Timer? _selectionTimer;
  Timer? _cycleTimer;

  // Menu state - using ValueNotifier for more reliable updates
  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier<int>(0);
  bool _isConfirming = false;

  // Constants
  static const Duration _doublePressDuration = Duration(milliseconds: 500);
  static const Duration _longPressDuration = Duration(milliseconds: 500);
  static const Duration _itemCycleDuration = Duration(milliseconds: 750);
  static const Duration _confirmDuration = Duration(seconds: 1);

  // List of menu items from centralized structure
  final List<ShortcutMenuItem> _menuItems = MenuItems.items.map((data) => data.item).toList();

  ShortcutMenuCubit({
    required VehicleSync vehicleSync,
    required ScreenCubit screenCubit,
    required ThemeCubit themeCubit,
    required DebugOverlayCubit debugOverlayCubit,
    // required TripCubit tripCubit, // Commented out since resetTrip is removed
    required MDBRepository mdbRepository,
  })  : _vehicleSync = vehicleSync,
        _screenCubit = screenCubit,
        _themeCubit = themeCubit,
        _debugOverlayCubit = debugOverlayCubit,
        // _tripCubit = tripCubit, // Commented out since resetTrip is removed
        _mdbRepository = mdbRepository,
        super(ShortcutMenuState.hidden) {
    // Listen for vehicle state changes via hash polling
    _vehicleSubscription = _vehicleSync.stream.listen(_handleVehicleStateChange);

    // Subscribe to direct button events channel for more responsive UI
    _buttonEventsSubscription = _mdbRepository.subscribe("buttons").listen(_handleButtonEvent);
  }

  void _handleButtonEvent((String channel, String message) event) {
    final buttonEvent = event.$2;

    // Parse the button event
    final parts = buttonEvent.split(':');
    if (parts.length < 2) return;

    final button = parts[0];
    final state = parts[1];

    // Only handle seatbox button for menu operations
    if (button == 'seatbox') {
      // Skip if not in ready-to-drive state
      if (_vehicleSync.state.state != ScooterState.readyToDrive) {
        return;
      }

      if (state == 'on') {
        _handleButtonPress();
      } else if (state == 'off') {
        _handleButtonRelease();
      }
    }
  }

  void _handleVehicleStateChange(VehicleData vehicleData) {
    // If we're no longer in drive mode, hide the menu
    if (vehicleData.state != ScooterState.readyToDrive && state != ShortcutMenuState.hidden) {
      emit(ShortcutMenuState.hidden);
    }
  }

  void _handleButtonPress() {
    final now = DateTime.now();

    // If we're in confirming state, this is a confirmation press
    if (state == ShortcutMenuState.confirmingSelection) {
      _executeSelectedAction();
      _resetState();
      return;
    }

    // Check for double tap (toggle hazards) - but only if we're not already in a press sequence
    // We need to be careful here - only check for double tap if we're not currently tracking a press
    if (_buttonPressStartTime == null && _lastTapTime != null && now.difference(_lastTapTime!) < _doublePressDuration) {
      _executeAction(ShortcutMenuItem.toggleHazards);
      _resetState();
      return;
    }

    // If we're already tracking a press, ignore this event
    // This prevents multiple button press events from resetting our timer
    if (_buttonPressStartTime != null) {
      return;
    }

    // Start tracking this press
    _buttonPressStartTime = now;

    // Start long press timer
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDuration, () {
      // Long press detected, show menu
      // Reset selected index to 0
      selectedIndexNotifier.value = 0;

      // Show menu
      emit(ShortcutMenuState.visible);

      // Start cycling through menu items
      _startCyclingItems();
    });
  }

  void _handleButtonRelease() {
    // If we're not tracking a press, ignore this event
    if (_buttonPressStartTime == null) {
      return;
    }

    // Cancel the long press timer (if it's still active)
    _longPressTimer?.cancel();

    final now = DateTime.now();

    // Calculate hold duration
    final holdDuration = now.difference(_buttonPressStartTime!);

    // If menu is visible, handle selection
    if (state == ShortcutMenuState.visible) {
      // Now we can cancel the cycling timer since we're moving to confirmation state
      _cycleTimer?.cancel();

      _isConfirming = true;

      emit(ShortcutMenuState.confirmingSelection);

      // Start confirmation timer
      _selectionTimer?.cancel();
      _selectionTimer = Timer(_confirmDuration, () {
        // Timeout, hide menu
        _resetState();
      });
    }

    // If it was a short press, keep tracking for potential double press
    else if (holdDuration < _longPressDuration) {
      // Record this tap time for potential double tap detection (tap-to-tap timing)
      _lastTapTime = _buttonPressStartTime; // Use the original press time, not release time
    }

    _buttonPressStartTime = null;
  }

  void _startCyclingItems() {
    _cycleTimer?.cancel();

    // Start with the first item
    selectedIndexNotifier.value = 0;

    // Create a periodic timer that updates the selected index
    _cycleTimer = Timer.periodic(_itemCycleDuration, (timer) {
      // Cycle to next item
      final previousIndex = selectedIndexNotifier.value;
      final nextIndex = (previousIndex + 1) % _menuItems.length;

      // Update the notifier value to trigger UI updates
      selectedIndexNotifier.value = nextIndex;
    });
  }

  void _executeSelectedAction() {
    final currentIndex = selectedIndexNotifier.value;
    if (currentIndex >= 0 && currentIndex < _menuItems.length) {
      _executeAction(_menuItems[currentIndex]);
    }
  }

  void _executeAction(ShortcutMenuItem item) {
    switch (item) {
      case ShortcutMenuItem.toggleHazards:
        _vehicleSync.toggleHazardLights();
        break;
      case ShortcutMenuItem.toggleView:
        final currentState = _screenCubit.state;
        if (currentState is ScreenCluster) {
          _screenCubit.showMap();
        } else {
          _screenCubit.showCluster();
        }
        break;
      case ShortcutMenuItem.toggleTheme:
        _cycleTheme();
        break;
      case ShortcutMenuItem.toggleDebugOverlay:
        _debugOverlayCubit.toggleMode();
        break;
    }
  }

  void _cycleTheme() {
    final currentState = _themeCubit.state;
    if (currentState.isAutoMode) {
      // auto → dark
      _themeCubit.updateAutoTheme(false);
      _themeCubit.updateTheme(ThemeMode.dark);
    } else if (currentState.themeMode == ThemeMode.dark) {
      // dark → light
      _themeCubit.updateTheme(ThemeMode.light);
    } else {
      // light → auto
      _themeCubit.updateAutoTheme(true);
    }
  }

  void _resetState() {
    _longPressTimer?.cancel();
    _selectionTimer?.cancel();
    _cycleTimer?.cancel();

    selectedIndexNotifier.value = 0;
    _isConfirming = false;
    emit(ShortcutMenuState.hidden);
  }

  // Getters for UI
  int get selectedIndex => selectedIndexNotifier.value;
  List<ShortcutMenuItem> get menuItems => _menuItems;
  bool get isConfirming => _isConfirming;

  // For testing/debugging
  void manualToggleHazards() {
    _executeAction(ShortcutMenuItem.toggleHazards);
  }

  void manualToggleTheme() {
    _executeAction(ShortcutMenuItem.toggleTheme);
  }

  void manualToggleDebugOverlay() {
    _executeAction(ShortcutMenuItem.toggleDebugOverlay);
  }

  // void manualResetTrip() {
  //   _executeAction(ShortcutMenuItem.resetTrip);
  // }

  static ShortcutMenuCubit create(BuildContext context) {
    return ShortcutMenuCubit(
      vehicleSync: context.read<VehicleSync>(),
      screenCubit: context.read<ScreenCubit>(),
      themeCubit: context.read<ThemeCubit>(),
      debugOverlayCubit: context.read<DebugOverlayCubit>(),
      // tripCubit: context.read<TripCubit>(), // Commented out since resetTrip is removed
      mdbRepository: RepositoryProvider.of<MDBRepository>(context),
    );
  }

  @override
  Future<void> close() {
    _vehicleSubscription.cancel();
    _buttonEventsSubscription?.cancel();
    _longPressTimer?.cancel();
    _selectionTimer?.cancel();
    _cycleTimer?.cancel();
    selectedIndexNotifier.dispose();
    return super.close();
  }
}
