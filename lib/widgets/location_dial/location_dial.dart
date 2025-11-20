import 'package:flutter/material.dart';
import 'dart:async';

class LocationDialController {
  final _scrollController = StreamController<ScrollAction>.broadcast();
  final _nextController = StreamController<void>.broadcast();
  final _stopScrollController = StreamController<void>.broadcast();
  final _resetController = StreamController<void>.broadcast();

  Stream<ScrollAction> get scrollEvents => _scrollController.stream;
  Stream<void> get nextEvents => _nextController.stream;
  Stream<void> get stopScrollEvents => _stopScrollController.stream;
  Stream<void> get resetEvents => _resetController.stream;

  LocationDialInputState? _state;

  void _attachState(LocationDialInputState state) {
    _state = state;
  }

  void scroll({bool isLongPress = false}) =>
      _scrollController.add(ScrollAction(isLongPress));
  void next() => _nextController.add(null);
  void stopScroll() => _stopScrollController.add(null);
  void reset() => _resetController.add(null);

  String getCode() => _state?.getCode() ?? '';

  void dispose() {
    _scrollController.close();
    _nextController.close();
    _stopScrollController.close();
    _resetController.close();
  }
}

class ScrollAction {
  final bool isLongPress;
  ScrollAction(this.isLongPress);
}

class LocationDialInput extends StatefulWidget {
  final int length;
  final LocationDialController controller;
  final void Function(String) onSubmit;
  final void Function(String)? onComplete;
  final void Function()? onCancel;

  const LocationDialInput({
    super.key,
    required this.length,
    required this.controller,
    required this.onSubmit,
    this.onComplete,
    this.onCancel,
  }) : assert(length >= 4 && length <= 6, 'Length must be between 4 and 6');

  @override
  State<LocationDialInput> createState() => LocationDialInputState();
}

class LocationDialInputState extends State<LocationDialInput>
    with TickerProviderStateMixin {
  late List<int> _currentValues;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _currentDialIndex = 0;
  Timer? _scrollTimer;
  bool _isScrolling = false;
  static const _base32Chars = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  @override
  void initState() {
    super.initState();
    widget.controller._attachState(this);
    _currentValues = List.filled(widget.length, 0);
    _controllers = List.generate(
      widget.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    widget.controller.scrollEvents.listen((action) {
      if (action.isLongPress) {
        _startScrolling();
      } else {
        _singleScroll();
      }
    });
    widget.controller.nextEvents.listen((_) => _handleNext());
    widget.controller.resetEvents.listen((_) => _handleReset());
    widget.controller.stopScrollEvents.listen((_) => _stopScrolling());
  }

  String getCode() {
    return _currentValues.map((value) => _base32Chars[value]).join();
  }

  void _handleReset() {
    setState(() {
      _currentValues = List.filled(widget.length, 0);
      _currentDialIndex = 0;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _singleScroll() {
    setState(() {
      _currentValues[_currentDialIndex] =
          (_currentValues[_currentDialIndex] + 1) % 32;
      _controllers[_currentDialIndex].forward(from: 0);
    });
  }

  void _startScrolling() {
    if (_isScrolling) return;
    _isScrolling = true;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _singleScroll();
    });
  }

  void _stopScrolling() {
    _isScrolling = false;
    _scrollTimer?.cancel();
  }

  void _handleNext() {
    if (_currentDialIndex < widget.length - 1) {
      setState(() {
        _currentDialIndex++;
      });
    } else {
      final code = getCode();
      widget.onComplete?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark
          ? Colors.black.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: _DialRow(
        length: widget.length,
        currentValues: _currentValues,
        currentDialIndex: _currentDialIndex,
        theme: theme,
        isDark: isDark,
        controllers: _controllers,
        animations: _animations,
      ),
    );
  }
}

class _DialRow extends StatelessWidget {
  final int length;
  final List<int> currentValues;
  final int currentDialIndex;
  final ThemeData theme;
  final bool isDark;
  final List<AnimationController> controllers;
  final List<Animation<double>> animations;

  const _DialRow({
    required this.length,
    required this.currentValues,
    required this.currentDialIndex,
    required this.theme,
    required this.isDark,
    required this.controllers,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return _DialBox(
          value: currentValues[index],
          isActive: currentDialIndex == index,
          theme: theme,
          isDark: isDark,
          controller: controllers[index],
          animation: animations[index],
        );
      }),
    );
  }
}

class LocationDialConfirmation extends StatelessWidget {
  final String code;

  const LocationDialConfirmation({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark
          ? Colors.black.withOpacity(0.9)
          : Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Destination Code',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            code,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Press Right Brake to Confirm',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Press Left Brake to Edit',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialBox extends StatelessWidget {
  final int value;
  final bool isActive;
  final ThemeData theme;
  final bool isDark;
  final AnimationController controller;
  final Animation<double> animation;

  const _DialBox({
    required this.value,
    required this.isActive,
    required this.theme,
    required this.isDark,
    required this.controller,
    required this.animation,
  });

  String _getCharAtOffset(int offset) {
    final index = (value + offset) % 32;
    return LocationDialInputState._base32Chars[index < 0 ? index + 32 : index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary
              : (isDark ? Colors.white24 : Colors.black12),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            if (!controller.isAnimating) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isActive) ...[
                    Text(
                      _getCharAtOffset(1),
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    LocationDialInputState._base32Chars[value],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getCharAtOffset(-1),
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ],
              );
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -30 + (animation.value * 30)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _getCharAtOffset(1),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocationDialInputState._base32Chars[value],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCharAtOffset(-1),
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
