import 'package:flutter/material.dart';

import '../../cubits/theme_cubit.dart';

class ControlHints extends StatelessWidget {
  final String? leftAction;
  final String? rightAction;

  const ControlHints({
    required this.leftAction,
    required this.rightAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlHint(
            control: 'Left Brake',
            action: leftAction,
            isDark: isDark,
          ),
          _ControlHint(
            control: 'Right Brake',
            action: rightAction,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ControlHint extends StatelessWidget {
  final String control;
  final String? action;
  final bool isDark;

  const _ControlHint({
    required this.control,
    required this.action,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    if (action == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          control,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          action,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
