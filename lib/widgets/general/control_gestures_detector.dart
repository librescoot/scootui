import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../state/enums.dart';
import '../../state/vehicle.dart';

enum ControlKey { left, right }

class ControlGestureDetector extends StatefulWidget {
  final Widget child;
  final Stream<VehicleData> stream;
  final Duration? cooldown;

  final VoidCallback? onLeftPress;
  final VoidCallback? onLeftRelease;
  final VoidCallback? onLeftTap;
  final VoidCallback? onLeftDoubleTap;
  final VoidCallback? onLeftHold;

  final VoidCallback? onRightPress;
  final VoidCallback? onRightRelease;
  final VoidCallback? onRightTap;
  final VoidCallback? onRightDoubleTap;
  final VoidCallback? onRightHold;

  final Duration doubleTapDelay;
  final Duration holdDelay;

  /// Seed the previous-state tracking with the actual current vehicle data so
  /// that a brake already held when this widget is created is not treated as a
  /// new press once the cooldown expires.
  final VehicleData? initialData;

  /// When true, all input is ignored until both brakes have been seen in the
  /// released state. Use this when the screen is opened by a brake press so
  /// that same press does not immediately trigger an action.
  final bool requireInitialRelease;

  const ControlGestureDetector({
    super.key,
    required this.stream,
    required this.child,
    this.initialData,
    this.onLeftPress,
    this.onLeftRelease,
    this.onLeftTap,
    this.onLeftDoubleTap,
    this.onLeftHold,
    this.onRightPress,
    this.onRightRelease,
    this.onRightTap,
    this.onRightDoubleTap,
    this.onRightHold,
    this.doubleTapDelay = const Duration(milliseconds: 300),
    this.holdDelay = const Duration(milliseconds: 500),
    this.cooldown = const Duration(milliseconds: 100),
    this.requireInitialRelease = false,
  });

  @override
  State<ControlGestureDetector> createState() => _ControlGestureDetectorState();
}

class _ControlGestureDetectorState extends State<ControlGestureDetector> {
  late final StreamSubscription<VehicleData> _sub;
  late final DateTime _activationTime;
  late bool _armed;

  late final Map<ControlKey, Toggle> _prev;

  final Map<ControlKey, DateTime?> _pressStart = {
    ControlKey.left: null,
    ControlKey.right: null,
  };

  final Map<ControlKey, Timer?> _holdTimers = {};
  final Map<ControlKey, Timer?> _doubleTapTimers = {};
  final Map<ControlKey, bool> _waitingSecondTap = {
    ControlKey.left: false,
    ControlKey.right: false,
  };

  @override
  void initState() {
    super.initState();
    _activationTime = widget.cooldown != null
        ? DateTime.now().add(widget.cooldown!)
        : DateTime.now();
    _armed = !widget.requireInitialRelease;
    _prev = {
      ControlKey.left: widget.initialData?.brakeLeft ?? Toggle.off,
      ControlKey.right: widget.initialData?.brakeRight ?? Toggle.off,
    };
    _sub = widget.stream.listen(_handleUpdate);
  }

  void _handleUpdate(VehicleData data) {
    // ignore controls when the scooter is not parked
    if (data.state != ScooterState.parked) return;

    // ignore controls if the cooldown period has not elapsed
    if (DateTime.now().isBefore(_activationTime)) return;

    // if waiting for initial release, keep _prev in sync and wait
    if (!_armed) {
      if (data.brakeLeft == Toggle.off && data.brakeRight == Toggle.off) {
        _armed = true;
      }
      _prev[ControlKey.left] = data.brakeLeft;
      _prev[ControlKey.right] = data.brakeRight;
      return;
    }

    _handleKey(
      key: ControlKey.left,
      prev: _prev[ControlKey.left]!,
      curr: data.brakeLeft,
      onPress: widget.onLeftPress,
      onRelease: widget.onLeftRelease,
      onTap: widget.onLeftTap,
      onDoubleTap: widget.onLeftDoubleTap,
      onHold: widget.onLeftHold,
    );

    _handleKey(
      key: ControlKey.right,
      prev: _prev[ControlKey.right]!,
      curr: data.brakeRight,
      onPress: widget.onRightPress,
      onRelease: widget.onRightRelease,
      onTap: widget.onRightTap,
      onDoubleTap: widget.onRightDoubleTap,
      onHold: widget.onRightHold,
    );

    _prev[ControlKey.left] = data.brakeLeft;
    _prev[ControlKey.right] = data.brakeRight;
  }

  void _handleKey({
    required ControlKey key,
    required Toggle prev,
    required Toggle curr,
    VoidCallback? onPress,
    VoidCallback? onRelease,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onHold,
  }) {
    final isPress = prev == Toggle.off && curr == Toggle.on;
    final isRelease = prev == Toggle.on && curr == Toggle.off;

    if (isPress) {
      _pressStart[key] = DateTime.now();
      onPress?.call();

      _holdTimers[key]?.cancel();
      _holdTimers[key] = Timer(widget.holdDelay, () {
        _waitingSecondTap[key] = false;
        onHold?.call();
      });
    }

    if (isRelease) {
      _holdTimers[key]?.cancel();
      onRelease?.call();

      final duration =
          DateTime.now().difference(_pressStart[key] ?? DateTime.now());

      if (duration < widget.holdDelay) {
        if (_waitingSecondTap[key] == true) {
          _doubleTapTimers[key]?.cancel();
          _waitingSecondTap[key] = false;
          onDoubleTap?.call();
        } else {
          _waitingSecondTap[key] = true;
          _doubleTapTimers[key] = Timer(widget.doubleTapDelay, () {
            _waitingSecondTap[key] = false;
            onTap?.call();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    for (var t in _holdTimers.values) {
      t?.cancel();
    }
    for (var t in _doubleTapTimers.values) {
      t?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
