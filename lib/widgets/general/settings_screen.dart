import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../general/control_hints.dart';
import '../../cubits/theme_cubit.dart';

/// A reusable screen widget that provides a consistent layout for settings-style screens.
///
/// This widget provides:
/// - A fixed size container (480x480)
/// - A title at the top
/// - Main content area in the middle (expanded)
/// - Control hints at the bottom
///
/// Used by screens like AddressSelectionScreen, RegionSelectionScreen, etc.
class SettingsScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final String? leftAction;
  final String? rightAction;
  final double width;
  final double height;
  final EdgeInsets padding;

  const SettingsScreen({
    super.key,
    required this.title,
    required this.child,
    this.leftAction,
    this.rightAction,
    this.width = 480,
    this.height = 480,
    this.padding = const EdgeInsets.only(top: 40, bottom: 40),
  });

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    return Container(
      width: width,
      height: height,
      color: theme.scaffoldBackgroundColor,
      padding: padding,
      child: Column(
        children: [
          _buildTitle(isDark),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Center(
                child: child,
              ),
            ),
          ),
          ControlHints(
            leftAction: leftAction,
            rightAction: rightAction,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
