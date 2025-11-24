import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../state/engine.dart';
import '../../state/settings.dart';
import '../indicators/speed_limit_indicator.dart';

class SpeedometerDisplay extends StatefulWidget {
  final double maxArcSpeed;
  final double colorTransitionStartSpeed;

  const SpeedometerDisplay({
    super.key,
    this.maxArcSpeed = 60.0,
    this.colorTransitionStartSpeed = 55.0,
  });

  @override
  State<SpeedometerDisplay> createState() => _SpeedometerDisplayState();
}

class _SpeedometerDisplayState extends State<SpeedometerDisplay> with TickerProviderStateMixin {
  late AnimationController _speedController;
  late AnimationController _colorController;
  late AnimationController _overspeedPulseController;
  late AnimationController _accelerationPulseController;
  late Animation<Color?> _colorAnimation;

  double _lastSpeed = 0.0;
  double _animationStartSpeed = 0.0;
  double _targetSpeed = 0.0;
  bool _isRegenerating = false;
  bool _isOverSpeed = false;
  bool _isAccelerating = false;
  bool _lastAccelerationState = false;
  int _accelerationDebounceFrames = 0;

  @override
  void initState() {
    super.initState();

    // Speed animation controller
    _speedController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(() {
        // Force rebuild on animation updates
        if (mounted) setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Only update _lastSpeed when animation completes
          if (mounted) {
            setState(() {
              _lastSpeed = _targetSpeed;
            });
          }
        }
      });

    // Color animation controller
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    // Overspeed pulse animation controller (repeating pulse)
    _overspeedPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    // Acceleration pulse animation controller (subtle pulse while accelerating)
    _accelerationPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    // Dispose controllers first to stop any pending animations
    try {
      _speedController.dispose();
    } catch (e) {
      print("SpeedometerDisplay: Error disposing speed controller: $e");
    }

    try {
      _colorController.dispose();
    } catch (e) {
      print("SpeedometerDisplay: Error disposing color controller: $e");
    }

    try {
      _overspeedPulseController.dispose();
    } catch (e) {
      print("SpeedometerDisplay: Error disposing overspeed pulse controller: $e");
    }

    try {
      _accelerationPulseController.dispose();
    } catch (e) {
      print("SpeedometerDisplay: Error disposing acceleration pulse controller: $e");
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engineData = EngineSync.watch(context);
    final settings = SettingsSync.watch(context);
    final theme = ThemeCubit.watch(context);

    // Get the correct speed based on settings
    final speed = _getDisplaySpeed(engineData, settings);

    // Check if we're regenerating by monitoring the motor current
    // Negative current indicates regenerative braking
    final bool regenerating = engineData.motorCurrent < 0;

    if (_isRegenerating != regenerating) {
      setState(() {
        _isRegenerating = regenerating;
      });

      // Set up color animation based on new state
      final Color fromColor =
          _isRegenerating ? (theme.isDark ? Colors.grey.shade800 : Colors.grey.shade200) : Colors.red.withOpacity(0.3);

      final Color toColor =
          _isRegenerating ? Colors.red.withOpacity(0.3) : (theme.isDark ? Colors.grey.shade800 : Colors.grey.shade200);

      _colorAnimation = ColorTween(
        begin: fromColor,
        end: toColor,
      ).animate(CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ));

      // Start color animation
      _colorController.reset();
      _colorController.forward();
    }

    // Check if speed is outside the arc range
    final bool isOverSpeed = speed > widget.maxArcSpeed;

    if (_isOverSpeed != isOverSpeed) {
      setState(() {
        _isOverSpeed = isOverSpeed;
      });

      if (_isOverSpeed) {
        // Start pulsing animation when over speed
        _overspeedPulseController.repeat(reverse: true);
      } else {
        // Stop pulsing when back under speed limit
        _overspeedPulseController.stop();
        _overspeedPulseController.reset();
      }
    }

    // Check if we're accelerating (positive motor current, not regenerating)
    final bool isAccelerating = engineData.motorCurrent > 0 && !regenerating;

    // Debounce acceleration state changes to prevent animation restarts
    if (isAccelerating != _lastAccelerationState) {
      _accelerationDebounceFrames++;
      if (_accelerationDebounceFrames >= 3) {
        // Only update state after 3 consecutive frames of the same state
        _lastAccelerationState = isAccelerating;
        _accelerationDebounceFrames = 0;

        if (_isAccelerating != isAccelerating) {
          setState(() {
            _isAccelerating = isAccelerating;
          });

          if (_isAccelerating) {
            // Start pulsing animation when accelerating
            _accelerationPulseController.repeat(reverse: true);
          } else {
            // Stop pulsing when not accelerating
            _accelerationPulseController.stop();
            _accelerationPulseController.reset();
          }
        }
      }
    } else {
      // Reset debounce counter if state is stable
      _accelerationDebounceFrames = 0;
    }

    // If the speed has changed and we're not currently animating
    if (speed != _targetSpeed && !_speedController.isAnimating) {
      // Store the starting point (current displayed value) and target
      _animationStartSpeed = _lastSpeed;
      _targetSpeed = speed;

      // Start a new animation
      _speedController.reset();
      _speedController.forward();
    }

    // Calculate the animated speed value
    double animatedSpeed;

    if (_speedController.isAnimating) {
      // Apply easing curve for smooth motion
      final curvedValue = Curves.easeInOutCubic.transform(_speedController.value);
      animatedSpeed = _animationStartSpeed + (curvedValue * (_targetSpeed - _animationStartSpeed));
    } else {
      // Not animating, use the last stable value
      animatedSpeed = _lastSpeed;
    }

    // Get the current animated background color
    Color backgroundColor;
    if (_colorController.isAnimating && _colorAnimation.value != null) {
      backgroundColor = _colorAnimation.value!;
    } else {
      backgroundColor =
          _isRegenerating ? Colors.red.withOpacity(0.3) : (theme.isDark ? Colors.grey.shade800 : Colors.grey.shade200);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
        ),
        // Main speedometer gauge
        CustomPaint(
          size: const Size(300, 240), // Width: full diameter, Height: reduced to visual arc bounds
          painter: _SpeedometerPainter(
            progress: math.min(animatedSpeed / widget.maxArcSpeed, 1.0),
            isDark: theme.isDark,
            isRegenerating: _isRegenerating,
            backgroundColor: backgroundColor,
            maxArcSpeed: widget.maxArcSpeed,
            animatedSpeed: animatedSpeed,
            colorTransitionStartSpeed: widget.colorTransitionStartSpeed,
            isOverSpeed: animatedSpeed > widget.maxArcSpeed,
            overspeedPulseValue: _overspeedPulseController.value,
            isAccelerating: _isAccelerating,
            accelerationPulseValue: _accelerationPulseController.value,
          ),
        ),
        // Speed display and indicators
        Transform.translate(
          offset: const Offset(
              0, 40), // Adjusted for new widget size: arc center (150) - widget center (120) + original offset (10)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated speed text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: animatedSpeed.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 96,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    color: theme.isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'km/h',
                  style: TextStyle(
                    fontSize: 22,
                    height: 0.9,
                    color: theme.isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),

              // Speed limit indicator
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpeedLimitIndicator(iconSize: 27),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 140,
                    child: RoadNameDisplay(
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gets the correct speed value based on settings
  double _getDisplaySpeed(EngineData engineData, SettingsData settings) {
    if (settings.showRawSpeedBool) {
      // Use raw speed if available and not null, otherwise fall back to processed speed
      final rawSpeedValue = engineData.rawSpeed;
      if (rawSpeedValue != null) {
        return rawSpeedValue.toDouble();
      }
    }

    return engineData.speed.toDouble();
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final bool isRegenerating;
  final Color backgroundColor;
  final double maxArcSpeed;
  final double animatedSpeed;
  final double colorTransitionStartSpeed;
  final bool isOverSpeed;
  final double overspeedPulseValue;
  final bool isAccelerating;
  final double accelerationPulseValue;
  static const double _startAngle = 150 * math.pi / 180;
  static const double _sweepAngle = 240 * math.pi / 180;

  _SpeedometerPainter({
    required this.progress,
    required this.isDark,
    required this.isRegenerating,
    required this.backgroundColor,
    required this.maxArcSpeed,
    required this.animatedSpeed,
    required this.colorTransitionStartSpeed,
    required this.isOverSpeed,
    required this.overspeedPulseValue,
    required this.isAccelerating,
    required this.accelerationPulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Center the circle horizontally but position it so the arc fits in the canvas
    final center = Offset(size.width / 2, 150); // 150 = radius, positions circle center
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
      _startAngle,
      _sweepAngle,
      false,
      bgPaint,
    );

    // Speed arc
    if (progress > 0) {
      Color arcColor;
      if (isOverSpeed) {
        // Pulse between purple and pink when over speed
        final pulseIntensity = (math.sin(overspeedPulseValue * math.pi * 2) + 1) / 2;
        arcColor = Color.lerp(Colors.purple, Colors.pink, pulseIntensity) ?? Colors.purple;
      } else if (animatedSpeed >= colorTransitionStartSpeed) {
        // Gradually transition from blue to purple starting at colorTransitionStartSpeed
        final transitionRange = maxArcSpeed - colorTransitionStartSpeed;
        final transitionProgress = (animatedSpeed - colorTransitionStartSpeed) / transitionRange;
        final clampedProgress = math.min(transitionProgress, 1.0);
        var baseColor = Color.lerp(Colors.blue, Colors.purple, clampedProgress) ?? Colors.blue;

        // Apply acceleration pulse if accelerating
        if (isAccelerating) {
          final accelPulseIntensity = (math.sin(accelerationPulseValue * math.pi * 2) + 1) / 2;
          // Create a slightly lighter version of the base color (very subtle)
          final slightlyLighterColor = baseColor.withOpacity(0.96);
          arcColor = Color.lerp(baseColor, slightlyLighterColor, accelPulseIntensity) ?? baseColor;
        } else {
          arcColor = baseColor;
        }
      } else {
        // Below transition speed - blue
        if (isAccelerating) {
          // Pulse between blue and a slightly lighter blue when accelerating
          final accelPulseIntensity = (math.sin(accelerationPulseValue * math.pi * 2) + 1) / 2;
          arcColor = Color.lerp(Colors.blue, Colors.blue.shade400, accelPulseIntensity) ?? Colors.blue;
        } else {
          arcColor = Colors.blue;
        }
      }

      final speedPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        _startAngle,
        progress * _sweepAngle,
        false,
        speedPaint,
      );
    }

    // Draw tick marks
    _drawTicks(canvas, center, radius, isDark);

    // Draw speed labels
    _drawSpeedLabels(canvas, center, radius, isDark);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, bool isDark) {
    final tickPaint = Paint()
      ..color = isDark ? Colors.white30 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final minorSpeedStep = 5.0; // 5 km/h per tick
    final majorSpeedStep = 10.0; // 10 km/h per major tick
    final totalTicks = (maxArcSpeed / minorSpeedStep).ceil() + 1;

    for (int i = 0; i <= totalTicks; i++) {
      final speedValue = (i * minorSpeedStep).toInt();
      final isMajorTick = speedValue % majorSpeedStep == 0;

      // Skip if speed value would exceed max arc range
      if (speedValue > maxArcSpeed) continue;

      final angle = _startAngle + (speedValue / maxArcSpeed) * _sweepAngle;
      final tickLength = isMajorTick ? 8.0 : 4.0;
      final tickWidth = isMajorTick ? 1.5 : 1.0;

      // Draw tick
      tickPaint.strokeWidth = tickWidth;
      final start = Offset(
        center.dx + (radius - 26) * math.cos(angle),
        center.dy + (radius - 26) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 26 - tickLength) * math.cos(angle),
        center.dy + (radius - 26 - tickLength) * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  void _drawSpeedLabels(Canvas canvas, Offset center, double radius, bool isDark) {
    final labelSpeeds = [0.0, 30.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 120.0];

    for (final speed in labelSpeeds) {
      // Skip if speed exceeds arc range
      if (speed > maxArcSpeed) continue;

      final angle = _startAngle + (speed / maxArcSpeed) * _sweepAngle;

      // Position label close to the ticks, just inside them
      final labelPosition = Offset(
        center.dx + (radius - 44) * math.cos(angle),
        center.dy + (radius - 44) * math.sin(angle),
      );

      // Create text painter for the speed label
      final textPainter = TextPainter(
        text: TextSpan(
          text: speed.toInt().toString(),
          style: TextStyle(
            color: isDark ? Colors.white30 : Colors.black12,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Center the text at the calculated position
      final textOffset = Offset(
        labelPosition.dx - textPainter.width / 2,
        labelPosition.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(_SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isRegenerating != isRegenerating ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.animatedSpeed != animatedSpeed ||
        oldDelegate.colorTransitionStartSpeed != colorTransitionStartSpeed ||
        oldDelegate.isOverSpeed != isOverSpeed ||
        oldDelegate.overspeedPulseValue != overspeedPulseValue ||
        oldDelegate.isAccelerating != isAccelerating ||
        oldDelegate.accelerationPulseValue != accelerationPulseValue;
  }
}
