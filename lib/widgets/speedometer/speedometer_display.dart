import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late Ticker _speedTicker;
  late AnimationController _colorController;
  late AnimationController _overspeedPulseController;
  late AnimationController _accelerationPulseController;
  late Animation<Color?> _colorAnimation;

  final ValueNotifier<double> _speedNotifier = ValueNotifier(0.0);
  double _targetSpeed = 0.0;
  Duration _lastTickTime = Duration.zero;

  static const double _timeConstantMs = 100.0;
  static const double _snapThreshold = 0.3;

  bool _isRegenerating = false;
  bool _isOverSpeed = false;
  bool _isAccelerating = false;
  bool _lastAccelerationState = false;
  int _accelerationDebounceFrames = 0;

  List<_LabelPainter>? _cachedLabelPainters;
  bool? _cachedIsDark;

  @override
  void initState() {
    super.initState();

    _speedTicker = createTicker(_onTick);

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _overspeedPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _accelerationPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _colorAnimation = const AlwaysStoppedAnimation<Color?>(null);
  }

  void _onTick(Duration elapsed) {
    final dtMs = (elapsed - _lastTickTime).inMicroseconds / 1000.0;
    _lastTickTime = elapsed;
    if (dtMs <= 0) return;

    final diff = _targetSpeed - _speedNotifier.value;
    if (diff.abs() < _snapThreshold) {
      if (_speedNotifier.value != _targetSpeed) {
        _speedNotifier.value = _targetSpeed;
      }
      _speedTicker.stop();
      _lastTickTime = Duration.zero;
      return;
    }
    final alpha = 1.0 - math.exp(-dtMs / _timeConstantMs);
    _speedNotifier.value += diff * alpha;
  }

  void _ensureTickerRunning() {
    if (!_speedTicker.isActive) {
      _lastTickTime = Duration.zero;
      _speedTicker.start();
    }
  }

  @override
  void dispose() {
    _speedTicker.dispose();
    _speedNotifier.dispose();
    _colorController.dispose();
    _overspeedPulseController.dispose();
    _accelerationPulseController.dispose();
    super.dispose();
  }

  void _updateAnimationState(EngineData engineData, SettingsData settings, bool isDark) {
    if (!mounted) return;

    final speed = _getDisplaySpeed(engineData, settings);
    if (speed != _targetSpeed) {
      _targetSpeed = speed;
      _ensureTickerRunning();
    }

    final regenerating = engineData.motorCurrent < 0;
    final isAccelerating = engineData.motorCurrent > 0 && !regenerating;

    if (_isRegenerating != regenerating) {
      _isRegenerating = regenerating;

      final fromColor = _isRegenerating
          ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
          : Colors.red.withOpacity(0.3);
      final toColor = _isRegenerating
          ? Colors.red.withOpacity(0.3)
          : (isDark ? Colors.grey.shade800 : Colors.grey.shade200);

      _colorAnimation = ColorTween(begin: fromColor, end: toColor).animate(
        CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
      );
      _colorController.reset();
      _colorController.forward();
    }

    final isOverSpeed = speed > widget.maxArcSpeed;
    if (_isOverSpeed != isOverSpeed) {
      _isOverSpeed = isOverSpeed;
      if (_isOverSpeed) {
        _overspeedPulseController.repeat(reverse: true);
      } else {
        _overspeedPulseController.stop();
        _overspeedPulseController.reset();
      }
    }

    if (isAccelerating != _lastAccelerationState) {
      _accelerationDebounceFrames++;
      if (_accelerationDebounceFrames >= 3) {
        _lastAccelerationState = isAccelerating;
        _accelerationDebounceFrames = 0;
        if (_isAccelerating != isAccelerating) {
          _isAccelerating = isAccelerating;
          if (_isAccelerating) {
            _accelerationPulseController.repeat(reverse: true);
          } else {
            _accelerationPulseController.stop();
            _accelerationPulseController.reset();
          }
        }
      }
    } else {
      _accelerationDebounceFrames = 0;
    }
  }

  List<_LabelPainter> _buildLabelPainters(bool isDark) {
    if (_cachedLabelPainters != null && _cachedIsDark == isDark) {
      return _cachedLabelPainters!;
    }

    final labelSpeeds = [0.0, 30.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 120.0];
    final painters = <_LabelPainter>[];

    for (final speed in labelSpeeds) {
      if (speed > widget.maxArcSpeed) continue;

      final angle = _SpeedometerPainter._startAngle + (speed / widget.maxArcSpeed) * _SpeedometerPainter._sweepAngle;
      final tp = TextPainter(
        text: TextSpan(
          text: speed.toInt().toString(),
          style: TextStyle(
            color: isDark ? Colors.white30 : Colors.black12,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painters.add(_LabelPainter(angle: angle, painter: tp));
    }

    _cachedLabelPainters = painters;
    _cachedIsDark = isDark;
    return painters;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EngineSync, EngineData>(
      listener: (context, engineData) {
        _updateAnimationState(
          engineData,
          context.read<SettingsSync>().state,
          context.read<ThemeCubit>().state.isDark,
        );
      },
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, theme) {
          final labelPainters = _buildLabelPainters(theme.isDark);

          return ExcludeSemantics(
            child: AnimatedBuilder(
            animation: Listenable.merge([
              _overspeedPulseController,
              _accelerationPulseController,
              _colorController,
            ]),
            builder: (context, _) {
              return ValueListenableBuilder<double>(
              valueListenable: _speedNotifier,
              builder: (context, animatedSpeed, _) {
              Color backgroundColor;
              if (_colorController.isAnimating && _colorAnimation.value != null) {
                backgroundColor = _colorAnimation.value!;
              } else {
                backgroundColor = _isRegenerating
                    ? Colors.red.withOpacity(0.3)
                    : (theme.isDark ? Colors.grey.shade800 : Colors.grey.shade200);
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                  CustomPaint(
                    size: const Size(300, 240),
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
                      labelPainters: labelPainters,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
            },
          );
          },
          ),
          );
        },
      ),
    );
  }

  double _getDisplaySpeed(EngineData engineData, SettingsData settings) {
    if (settings.showRawSpeedBool) {
      final rawSpeedValue = engineData.rawSpeed;
      if (rawSpeedValue != null) {
        return rawSpeedValue.toDouble();
      }
    }
    return engineData.speed.toDouble();
  }
}

class _LabelPainter {
  final double angle;
  final TextPainter painter;

  const _LabelPainter({required this.angle, required this.painter});
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
  final List<_LabelPainter> labelPainters;

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
    required this.labelPainters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 150);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

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

    if (progress > 0) {
      Color arcColor;
      if (isOverSpeed) {
        final pulseIntensity = (math.sin(overspeedPulseValue * math.pi * 2) + 1) / 2;
        arcColor = Color.lerp(Colors.purple, Colors.pink, pulseIntensity) ?? Colors.purple;
      } else if (animatedSpeed >= colorTransitionStartSpeed) {
        final transitionRange = maxArcSpeed - colorTransitionStartSpeed;
        final transitionProgress = (animatedSpeed - colorTransitionStartSpeed) / transitionRange;
        final clampedProgress = math.min(transitionProgress, 1.0);
        var baseColor = Color.lerp(Colors.blue, Colors.purple, clampedProgress) ?? Colors.blue;

        if (isAccelerating) {
          final accelPulseIntensity = (math.sin(accelerationPulseValue * math.pi * 2) + 1) / 2;
          arcColor = Color.lerp(baseColor, baseColor.withOpacity(0.96), accelPulseIntensity) ?? baseColor;
        } else {
          arcColor = baseColor;
        }
      } else {
        if (isAccelerating) {
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

    _drawTicks(canvas, center, radius, isDark);
    _drawSpeedLabels(canvas, center, radius);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, bool isDark) {
    final tickPaint = Paint()
      ..color = isDark ? Colors.white30 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const minorSpeedStep = 5.0;
    const majorSpeedStep = 10.0;
    final totalTicks = (maxArcSpeed / minorSpeedStep).ceil() + 1;

    for (int i = 0; i <= totalTicks; i++) {
      final speedValue = (i * minorSpeedStep).toInt();
      final isMajorTick = speedValue % majorSpeedStep == 0;

      if (speedValue > maxArcSpeed) continue;

      final angle = _startAngle + (speedValue / maxArcSpeed) * _sweepAngle;
      final tickLength = isMajorTick ? 8.0 : 4.0;

      tickPaint.strokeWidth = isMajorTick ? 1.5 : 1.0;
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

  void _drawSpeedLabels(Canvas canvas, Offset center, double radius) {
    for (final label in labelPainters) {
      final labelPosition = Offset(
        center.dx + (radius - 44) * math.cos(label.angle),
        center.dy + (radius - 44) * math.sin(label.angle),
      );
      final textOffset = Offset(
        labelPosition.dx - label.painter.width / 2,
        labelPosition.dy - label.painter.height / 2,
      );
      label.painter.paint(canvas, textOffset);
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
