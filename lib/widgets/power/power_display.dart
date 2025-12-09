import 'package:flutter/material.dart';

import '../../cubits/theme_cubit.dart';
import '../../state/enums.dart';

class PowerDisplay extends StatefulWidget {
  final double powerOutput;
  final double motorCurrent;
  final PowerDisplayMode displayMode;
  final double maxRegenPower;
  final double maxDischargePower;
  final double maxRegenCurrent;
  final double maxDischargeCurrent;
  final double boostThresholdCurrent;

  const PowerDisplay({
    super.key,
    required this.powerOutput,
    required this.motorCurrent,
    this.displayMode = PowerDisplayMode.kw,
    this.maxRegenPower = 0.54, // 0.54kW max regen (10A × 54V)
    this.maxDischargePower = 4.0, // 4kW max discharge
    this.maxRegenCurrent = 10.0, // 10A max regen
    this.maxDischargeCurrent = 80.0, // 80A max discharge
    this.boostThresholdCurrent = 50.0, // 50A threshold for boost color
  });

  @override
  State<PowerDisplay> createState() => _PowerDisplayState();
}

class _PowerDisplayState extends State<PowerDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _powerController;
  late Animation<double> _powerAnimation;
  double _lastValue = 0.0;

  double _getCurrentValue() {
    return widget.displayMode == PowerDisplayMode.kw
        ? widget.powerOutput / 1000 // Convert W to kW
        : widget.motorCurrent / 1000; // Convert mA to A
  }

  @override
  void initState() {
    super.initState();
    _powerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _powerAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _powerController,
        curve: Curves.easeOutCubic,
      ),
    );
    _lastValue = _getCurrentValue();
  }

  @override
  void dispose() {
    _powerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PowerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newValue = _getCurrentValue();

    // Only animate if value has changed significantly
    if ((newValue - _lastValue).abs() > 0.01) {
      _powerAnimation = Tween<double>(
        begin: _lastValue,
        end: newValue,
      ).animate(
        CurvedAnimation(
          parent: _powerController,
          curve: Curves.easeOutCubic,
        ),
      );

      _powerController.forward(from: 0.0);
      _lastValue = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    return AnimatedBuilder(
      animation: _powerAnimation,
      builder: (context, child) {
        final value = _powerAnimation.value;
        final isRegenerating = value < 0;
        final absValue = value.abs();

        // Get max values and unit based on display mode
        final bool isAmpsMode = widget.displayMode == PowerDisplayMode.amps;
        final maxRegen = isAmpsMode ? widget.maxRegenCurrent : widget.maxRegenPower;
        final maxDischarge = isAmpsMode ? widget.maxDischargeCurrent : widget.maxDischargePower;
        final unit = isAmpsMode ? 'A' : 'kW';

        // Calculate width factor based on power direction
        final maxValue = isRegenerating ? maxRegen : maxDischarge;
        final progress = (absValue / maxValue).clamp(0.0, 1.0);

        // Determine bar color based on mode and value
        Color barColor;
        if (isRegenerating) {
          barColor = Colors.green.shade600; // Regen is always green
        } else if (isAmpsMode && value > widget.boostThresholdCurrent) {
          barColor = Colors.orange.shade600; // Boost mode (50A-80A)
        } else {
          barColor = Colors.blue.shade600; // Normal discharge
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REGEN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'DISCHARGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            SizedBox(
              height: 24, // Increased height to accommodate label
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;

                  // Calculate asymmetric layout
                  final totalRange = maxRegen + maxDischarge;
                  final regenWidth = totalWidth * (maxRegen / totalRange);
                  final dischargeWidth = totalWidth * (maxDischarge / totalRange);
                  final zeroPoint = regenWidth; // Zero point is at end of regen section

                  // Calculate actual bar width based on power direction and magnitude
                  final barWidth = isRegenerating
                      ? regenWidth * progress // Regen: grows leftward from zero point
                      : dischargeWidth * progress; // Discharge: grows rightward from zero point

                  final midThreshold = 0.15;

                  // Calculate position for the value label
                  double labelPosition;
                  if (absValue <= midThreshold) {
                    // When value is close to zero, position near zero point
                    labelPosition = zeroPoint - 20; // Center around zero point
                  } else if (isRegenerating) {
                    // For regenerating, position label at the left edge of the bar
                    labelPosition = (zeroPoint - barWidth) - 20;
                  } else {
                    // For discharging, position label at the right edge of the bar
                    labelPosition = (zeroPoint + barWidth) - 20;
                  }

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Bar positioned at the top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 4,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background bar
                              Container(
                                height: 4,
                                width: totalWidth,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // Power indicator
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                left: isRegenerating ? zeroPoint - barWidth : zeroPoint,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  height: 4,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // Zero marker (positioned at zero point, not center)
                              Positioned(
                                left: zeroPoint - 1, // Center the 2px wide marker
                                child: Container(
                                  width: 2,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.38), // Slightly more prominent
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Value with animated text (positioned below the bar)
                      Positioned(
                        left: labelPosition.clamp(0, totalWidth - 40), // Prevent overflowing
                        top: 8, // Position below the bar
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(
                            begin: _lastValue.abs(),
                            end: absValue,
                          ),
                          builder: (context, animValue, child) {
                            return Text(
                              '${animValue.toStringAsFixed(isAmpsMode ? 0 : 1)} $unit',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
