import 'package:flutter/material.dart';

import '../../cubits/theme_cubit.dart';
import '../../l10n/l10n.dart';

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
            control: context.l10n.controlLeftBrake,
            action: leftAction,
            isDark: isDark,
          ),
          _ControlHint(
            control: context.l10n.controlRightBrake,
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
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white60 : Colors.black54,
            letterSpacing: 0.5,
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
