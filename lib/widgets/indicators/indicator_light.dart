import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../cubits/theme_cubit.dart';

typedef IndicatorIcon = Widget Function(Color color, double size);

class IndicatorLight extends StatelessWidget {
  static IndicatorIcon svgAsset(String iconName) {
    return (Color color, double size) => SvgPicture.asset(
          'assets/icons/$iconName',
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
          width: size,
          height: size,
        );
  }

  static IndicatorIcon iconData(IconData icon) {
    return (Color color, double size) => Icon(
          icon,
          color: color,
          size: size,
        );
  }

  final IndicatorIcon icon;
  final double size;
  final bool isActive;
  final bool blinking;
  final Color activeColor;

  const IndicatorLight({
    super.key,
    required this.icon,
    this.size = 24,
    this.isActive = true,
    this.blinking = false,
    this.activeColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: this should probably not live in here, but it's easier for now
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    final inactiveColor = isDark ? Colors.white12 : Colors.black12;

    render(final Color color) => icon(color, size);

    return Stack(children: [
      render(isActive && !blinking ? activeColor : inactiveColor),
      if (blinking && isActive)
        CustomAnimationBuilder<int>(
          control: Control.loop,
          tween: TweenSequence<int>([
            // Fade up: 0ms to 250ms
            TweenSequenceItem(
              tween: IntTween(begin: 0, end: 255)
                  .chain(CurveTween(curve: Curves.easeInOutExpo)),
              weight: 250,
            ),
            // Fade down: 250ms to 500ms
            TweenSequenceItem(
              tween: IntTween(begin: 255, end: 0)
                  .chain(CurveTween(curve: Curves.easeInOutExpo)),
              weight: 250,
            ),
            // Stay dark: 500ms to 800ms
            TweenSequenceItem(
              tween: ConstantTween<int>(0),
              weight: 300,
            ),
          ]),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) => render(activeColor.withAlpha(value)),
        ),
    ]);
  }
}
