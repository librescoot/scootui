import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../services/toast_service.dart';
import '../../state/aux_battery.dart';
import '../../state/battery.dart';
import '../../state/cb_battery.dart';
import '../../state/vehicle.dart';
import '../../utils/condition_debouncer.dart';
import '../../utils/fault_codes.dart';

// Battery icon dimensions (scaled from 144x144)
const double kBatteryIconWidth = 24.0;
const double kBatteryIconHeight = 24.0;

// Scale factor for converting from 144x144 to our icon size
const double kScaleFactor = kBatteryIconWidth / 144.0;

// Charge level rectangle dimensions (scaled from 144x144)
// Made larger: x-1, y-1, w+2, h+1
const double kChargeRectX = 23.0 * kScaleFactor;
const double kChargeRectY = 41.0 * kScaleFactor;
const double kChargeRectHeight = 83.0 * kScaleFactor;
const double kChargeRectMaxWidth = 98.0 * kScaleFactor;

class BatteryStatusDisplay extends StatelessWidget {
  final BatteryData battery;

  const BatteryStatusDisplay({super.key, required this.battery});

  @override
  Widget build(BuildContext context) {
    // Get theme information
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    // Determine battery color based on charge level
    Color getBatteryColor() {
      if (battery.present) {
        if (battery.charge <= 10) {
          return const Color(0xFFFF0000); // Red for critical
        } else if (battery.charge <= 20) {
          return const Color(0xFFFF7900); // Orange for warning
        }
      }
      return isDark ? Colors.white : Colors.black; // Normal
    }

    final iconColor = getBatteryColor();
    final textColor = iconColor;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    // Check for battery fault
    final hasFault = battery.present && battery.fault.isNotEmpty;

    // Determine which icon to show and what text to display
    Widget batteryIcon;
    String? labelText;

    if (!battery.present) {
      // Battery not present - show absent icon
      batteryIcon = SvgPicture.asset(
        'assets/icons/librescoot-main-battery-absent.svg',
        width: kBatteryIconWidth,
        height: kBatteryIconHeight,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else if (battery.state == BatteryState.asleep) {
      // Battery is asleep - show normal charge icon with asleep mask and overlay
      final chargeWidth = (battery.charge / 100.0) * kChargeRectMaxWidth;

      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          // Base battery icon with charge level
          Stack(
            alignment: Alignment.center,
            children: [
              // Base battery icon
              SvgPicture.asset(
                'assets/icons/librescoot-main-battery-blank.svg',
                width: kBatteryIconWidth,
                height: kBatteryIconHeight,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),

              // Charge level rectangle
              Positioned(
                left: kChargeRectX,
                top: kChargeRectY,
                child: Container(
                  width: chargeWidth,
                  height: kChargeRectHeight,
                  color: iconColor,
                ),
              ),
            ],
          ),

          // Apply asleep mask (draw inverted - mask areas in background color)
          SvgPicture.asset(
            'assets/icons/librescoot-main-battery-asleep-mask.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(backgroundColor, BlendMode.srcIn),
          ),

          // Apply asleep overlay
          SvgPicture.asset(
            'assets/icons/librescoot-main-battery-asleep-overlay.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ],
      );
      labelText = '${battery.charge}';
    } else if (battery.state == BatteryState.idle) {
      // Battery is idle - show normal charge icon with idle overlay
      final chargeWidth = (battery.charge / 100.0) * kChargeRectMaxWidth;

      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          // Base battery icon with charge level
          Stack(
            alignment: Alignment.center,
            children: [
              // Base battery icon
              SvgPicture.asset(
                'assets/icons/librescoot-main-battery-blank.svg',
                width: kBatteryIconWidth,
                height: kBatteryIconHeight,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),

              // Charge level rectangle
              Positioned(
                left: kChargeRectX,
                top: kChargeRectY,
                child: Container(
                  width: chargeWidth,
                  height: kChargeRectHeight,
                  color: iconColor,
                ),
              ),
            ],
          ),

          // Apply idle overlay
          SvgPicture.asset(
            'assets/icons/librescoot-overlay-idle.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: !isDark
                ? const ColorFilter.matrix([
                    // Invert colors for light theme
                    -1.0, 0.0, 0.0, 0.0, 255.0,
                    0.0, -1.0, 0.0, 0.0, 255.0,
                    0.0, 0.0, -1.0, 0.0, 255.0,
                    0.0, 0.0, 0.0, 1.0, 0.0,
                  ])
                : null,
          ),
        ],
      );
      labelText = '${battery.charge}';
    } else if (battery.charge <= 10) {
      // Critically empty battery - show empty icon
      batteryIcon = SvgPicture.asset(
        'assets/icons/librescoot-main-battery-empty.svg',
        width: kBatteryIconWidth,
        height: kBatteryIconHeight,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
      labelText = '${battery.charge}';
    } else {
      // Normal battery with charge level - draw charge state as a block
      final chargeWidth = (battery.charge / 100.0) * kChargeRectMaxWidth;

      batteryIcon = Stack(
        alignment: Alignment.center,
        children: [
          // Base battery icon
          SvgPicture.asset(
            'assets/icons/librescoot-main-battery-blank.svg',
            width: kBatteryIconWidth,
            height: kBatteryIconHeight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),

          // Charge level rectangle
          Positioned(
            left: kChargeRectX,
            top: kChargeRectY,
            child: Container(
              width: chargeWidth,
              height: kChargeRectHeight,
              color: iconColor,
            ),
          ),
        ],
      );
      labelText = '${battery.charge}';
    }

    // Wrap with fault overlay if there's a fault
    final finalIcon = hasFault
        ? Stack(
            alignment: Alignment.center,
            children: [
              batteryIcon,
              // Fault error overlay
              SvgPicture.asset(
                'assets/icons/librescoot-overlay-error.svg',
                width: kBatteryIconWidth,
                height: kBatteryIconHeight,
                colorFilter: !isDark
                    ? const ColorFilter.matrix([
                        // Invert colors for light theme
                        -1.0, 0.0, 0.0, 0.0, 255.0,
                        0.0, -1.0, 0.0, 0.0, 255.0,
                        0.0, 0.0, -1.0, 0.0, 255.0,
                        0.0, 0.0, 0.0, 1.0, 0.0,
                      ])
                    : null, // No filter for dark theme - use original colors
              ),
            ],
          )
        : batteryIcon;

    // Return the battery icon with text label beside it
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        finalIcon,
        if (labelText != null) ...[
          const SizedBox(width: 2),
          Text(
            labelText,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.1,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

class BatteryWarningIcon extends StatelessWidget {
  final String iconPath;
  final bool isDark;

  const BatteryWarningIcon({
    super.key,
    required this.iconPath,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark ? Colors.white : Colors.black;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Base battery blank icon
        SvgPicture.asset(
          iconPath,
          width: kBatteryIconWidth,
          height: kBatteryIconHeight,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),

        // Error overlay with built-in colors (white X on black circle)
        // Render with inversion for light theme to make it visible
        SvgPicture.asset(
          'assets/icons/librescoot-overlay-error.svg',
          width: kBatteryIconWidth,
          height: kBatteryIconHeight,
          colorFilter: !isDark
              ? const ColorFilter.matrix([
                  // Invert colors for light theme
                  -1.0, 0.0, 0.0, 0.0, 255.0,
                  0.0, -1.0, 0.0, 0.0, 255.0,
                  0.0, 0.0, -1.0, 0.0, 255.0,
                  0.0, 0.0, 0.0, 1.0, 0.0,
                ])
              : null, // No filter for dark theme - use original colors
        ),
      ],
    );
  }
}

class BatteryWarningIndicators extends StatefulWidget {
  const BatteryWarningIndicators({super.key});

  @override
  State<BatteryWarningIndicators> createState() =>
      _BatteryWarningIndicatorsState();
}

class _BatteryWarningIndicatorsState extends State<BatteryWarningIndicators> {
  bool _cbWarningShown = false;
  bool _auxLowChargeWarningShown = false;
  bool _auxLowVoltageWarningShown = false;
  bool _auxCriticalVoltageWarningShown = false;

  // Debouncers for each warning condition - require 3 seconds of consistent condition
  late final ConditionDebouncer _cbWarningDebouncer;
  late final ConditionDebouncer _auxLowChargeDebouncer;
  late final ConditionDebouncer _auxLowVoltageDebouncer;
  late final ConditionDebouncer _auxCriticalVoltageDebouncer;

  @override
  void initState() {
    super.initState();
    const debounceDelay = Duration(seconds: 3);
    _cbWarningDebouncer = ConditionDebouncer(delay: debounceDelay);
    _auxLowChargeDebouncer = ConditionDebouncer(delay: debounceDelay);
    _auxLowVoltageDebouncer = ConditionDebouncer(delay: debounceDelay);
    _auxCriticalVoltageDebouncer = ConditionDebouncer(delay: debounceDelay);
  }

  bool _shouldShowCbWarning(
      CbBatteryData cbBattery, BatteryData mainBattery, VehicleData vehicle) {
    final cbChargeOk = cbBattery.charge < 95;
    final cbNotCharging = cbBattery.chargeStatus == ChargeStatus.notCharging;
    final mainPresent = mainBattery.present;
    final mainNonZero = mainBattery.charge > 0;
    final mainActive = mainBattery.state == BatteryState.active;
    final seatboxClosed = vehicle.seatboxLock == SeatboxLock.closed;

    return cbChargeOk &&
        cbNotCharging &&
        mainPresent &&
        mainNonZero &&
        mainActive &&
        seatboxClosed;
  }

  bool _shouldShowAuxLowChargeWarning(
      AuxBatteryData auxBattery, BatteryData mainBattery, VehicleData vehicle) {
    final auxLowCharge = auxBattery.charge <= 25;
    final auxNotCharging =
        auxBattery.chargeStatus == AuxChargeStatus.notCharging;
    final mainPresent = mainBattery.present;
    final mainNonZero = mainBattery.charge > 0;
    final mainActive = mainBattery.state == BatteryState.active;
    final seatboxClosed = vehicle.seatboxLock == SeatboxLock.closed;

    return auxLowCharge &&
        auxNotCharging &&
        mainPresent &&
        mainNonZero &&
        mainActive &&
        seatboxClosed;
  }

  bool _shouldShowAuxLowVoltageWarning(
      AuxBatteryData auxBattery, BatteryData mainBattery, VehicleData vehicle) {
    final lowVoltage = auxBattery.voltage < 11500;
    final notCharging = auxBattery.chargeStatus == AuxChargeStatus.notCharging;
    final mainPresent = mainBattery.present;
    final seatboxClosed = vehicle.seatboxLock == SeatboxLock.closed;

    return lowVoltage && notCharging && mainPresent && seatboxClosed;
  }

  bool _shouldShowAuxCriticalVoltageWarning(
      AuxBatteryData auxBattery, BatteryData mainBattery, VehicleData vehicle) {
    final criticalVoltage = auxBattery.voltage < 11000; // 11.0V = 11000mV
    final mainPresent = mainBattery.present;
    final seatboxClosed = vehicle.seatboxLock == SeatboxLock.closed;

    return criticalVoltage && mainPresent && seatboxClosed;
  }

  void _showToastIfNeeded(String message, bool wasShown, Function(bool) setShown) {
    if (!wasShown) {
      ToastService.showWarning(message);
      setShown(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:isDark) = ThemeCubit.watch(context);
    final cbBattery = CbBatterySync.watch(context);
    final auxBattery = AuxBatterySync.watch(context);
    final mainBattery = Battery0Sync.watch(context);
    final vehicle = VehicleSync.watch(context);

    // Check warning conditions and apply debouncing
    final cbCondition = _shouldShowCbWarning(cbBattery, mainBattery, vehicle);
    final auxLowChargeCondition =
        _shouldShowAuxLowChargeWarning(auxBattery, mainBattery, vehicle);
    final auxLowVoltageCondition =
        _shouldShowAuxLowVoltageWarning(auxBattery, mainBattery, vehicle);
    final auxCriticalVoltageCondition =
        _shouldShowAuxCriticalVoltageWarning(auxBattery, mainBattery, vehicle);

    // Apply debouncing - warnings only show after condition is true for 3 seconds
    final showCbWarning = _cbWarningDebouncer.update(cbCondition);
    final showAuxLowChargeWarning =
        _auxLowChargeDebouncer.update(auxLowChargeCondition);
    final showAuxLowVoltageWarning =
        _auxLowVoltageDebouncer.update(auxLowVoltageCondition);
    final showAuxCriticalVoltageWarning =
        _auxCriticalVoltageDebouncer.update(auxCriticalVoltageCondition);
    final showAnyAuxWarning = showAuxLowChargeWarning ||
        showAuxLowVoltageWarning ||
        showAuxCriticalVoltageWarning;

    // Show toast notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showCbWarning) {
        _showToastIfNeeded("CB Battery not charging", _cbWarningShown,
            (shown) => _cbWarningShown = shown);
      } else {
        _cbWarningShown = false;
      }

      if (showAuxLowChargeWarning) {
        _showToastIfNeeded("AUX Battery low and not charging", _auxLowChargeWarningShown,
            (shown) => _auxLowChargeWarningShown = shown);
      } else {
        _auxLowChargeWarningShown = false;
      }

      if (showAuxLowVoltageWarning) {
        _showToastIfNeeded("AUX Battery voltage low", _auxLowVoltageWarningShown,
            (shown) => _auxLowVoltageWarningShown = shown);
      } else {
        _auxLowVoltageWarningShown = false;
      }

      if (showAuxCriticalVoltageWarning) {
        final message = mainBattery.present
            ? "AUX Battery voltage very low - may need replacement"
            : "AUX Battery voltage very low - insert main battery to charge";
        _showToastIfNeeded(message, _auxCriticalVoltageWarningShown,
            (shown) => _auxCriticalVoltageWarningShown = shown);
      } else {
        _auxCriticalVoltageWarningShown = false;
      }
    });

    final List<Widget> warningIcons = [];

    if (showCbWarning) {
      warningIcons.add(
        BatteryWarningIcon(
          iconPath: 'assets/icons/librescoot-cb-battery-blank.svg',
          isDark: isDark,
        ),
      );
    }

    if (showAnyAuxWarning) {
      warningIcons.add(
        BatteryWarningIcon(
          iconPath: 'assets/icons/librescoot-aux-battery-blank.svg',
          isDark: isDark,
        ),
      );
    }

    if (warningIcons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < warningIcons.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          warningIcons[i],
        ],
        const SizedBox(width: 8), // Space after warning icons
      ],
    );
  }
}

class SeatboxIndicator extends StatelessWidget {
  const SeatboxIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = VehicleSync.watch(context);
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    final iconColor = isDark ? Colors.white : Colors.black;

    // Show seatbox open icon when seatbox:lock is not "closed"
    final showSeatboxOpen = vehicle.seatboxLock != SeatboxLock.closed;

    if (!showSeatboxOpen) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/librescoot-seatbox-open.svg',
          width: kBatteryIconWidth,
          height: kBatteryIconHeight,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class CombinedBatteryDisplay extends StatefulWidget {
  final bool showNonPresentBattery1;

  const CombinedBatteryDisplay({
    super.key,
    this.showNonPresentBattery1 = false,
  });

  @override
  State<CombinedBatteryDisplay> createState() => _CombinedBatteryDisplayState();
}

class _CombinedBatteryDisplayState extends State<CombinedBatteryDisplay> {
  int? _lastSoc;
  Set<int>? _lastBattery0Fault;
  Set<int>? _lastBattery1Fault;

  void _checkBatteryWarnings(BatteryData battery) {
    final soc = battery.charge;

    // Don't show warnings if battery is not present
    if (!battery.present) {
      _lastSoc = soc;
      return;
    }

    if (_lastSoc == null || _lastSoc == soc) {
      _lastSoc = soc;
      return;
    }

    // Only show toasts when crossing thresholds downward
    if (soc < _lastSoc!) {
      String? message;
      if (soc == 0 && _lastSoc! > 0) {
        message = "Battery empty. Recharge battery";
      } else if (soc < 5 && _lastSoc! >= 5) {
        message = "Max speed is reduced. Battery is below 5%";
      } else if (soc <= 10 && _lastSoc! > 10) {
        message = "Battery low. Power reduced. Please recharge battery";
      } else if (soc < 20 && _lastSoc! >= 20) {
        message = "Battery low. Power reduced. Recharge battery";
      }

      if (message != null) {
        ToastService.showWarning(message);
      }
    }

    _lastSoc = soc;
  }

  String _formatBatteryFaults(Set<int> faultCodes) {
    if (faultCodes.isEmpty) return "";

    if (faultCodes.length == 1) {
      // Single fault: show with full description
      return FaultFormatter.formatSingleFault(faultCodes.first);
    }

    // Multiple faults: show comma-separated list
    return FaultFormatter.formatMultipleFaults(faultCodes);
  }

  void _checkBatteryFaults(BatteryData battery0, BatteryData battery1) {
    // Check for new battery:0 fault (main battery)
    if (battery0.present &&
        battery0.fault.isNotEmpty &&
        (_lastBattery0Fault == null || _lastBattery0Fault != battery0.fault)) {
      if (mounted) {
        final faultMessage = _formatBatteryFaults(battery0.fault);
        final hasCritical = FaultFormatter.hasAnyCritical(battery0.fault);
        final title = battery0.fault.length > 1
            ? FaultFormatter.getMultipleFaultsTitle(battery0.fault)
            : "Battery 0";

        if (hasCritical) {
          ToastService.showError("$title: $faultMessage");
        } else {
          ToastService.showWarning("$title: $faultMessage");
        }
      }
    }
    _lastBattery0Fault = battery0.fault;

    // Check for new battery:1 fault (secondary battery)
    if (battery1.present &&
        battery1.fault.isNotEmpty &&
        (_lastBattery1Fault == null || _lastBattery1Fault != battery1.fault)) {
      if (mounted) {
        final faultMessage = _formatBatteryFaults(battery1.fault);
        final hasCritical = FaultFormatter.hasAnyCritical(battery1.fault);
        final title = battery1.fault.length > 1
            ? FaultFormatter.getMultipleFaultsTitle(battery1.fault)
            : "Battery 1";

        if (hasCritical) {
          ToastService.showError("$title: $faultMessage");
        } else {
          ToastService.showWarning("$title: $faultMessage");
        }
      }
    }
    _lastBattery1Fault = battery1.fault;
  }

  @override
  Widget build(BuildContext context) {
    final battery0 = Battery0Sync.watch(context); // battery:0 (main battery)
    final battery1 = Battery1Sync.watch(context);
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    // Check for battery warnings
    _checkBatteryWarnings(battery0);

    // Check for battery faults
    _checkBatteryFaults(battery0, battery1);

    // Show turtle icon when battery is present and ≤20%
    final showTurtle = battery0.present && battery0.charge <= 20;
    final iconColor = isDark ? Colors.white : Colors.black;

    // Show battery:1 only if present or explicitly requested
    final showBattery1 = battery1.present || widget.showNonPresentBattery1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BatteryStatusDisplay(battery: battery0),
        if (showBattery1) ...[
          const SizedBox(width: 8),
          BatteryStatusDisplay(battery: battery1),
        ],
        const SizedBox(width: 8),
        const SeatboxIndicator(),
        const BatteryWarningIndicators(),
        if (showTurtle) ...[
          SvgPicture.asset(
            'assets/icons/librescoot-turtle-mode.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ],
      ],
    );
  }
}
