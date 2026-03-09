import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/theme_cubit.dart';
import '../../state/settings.dart';
import '../../state/vehicle.dart';

/// Fullscreen blinking arrow overlay shown when a turn signal is active
/// (left or right, not hazards). Enabled when blinker style is 'overlay'.
class BlinkerOverlay extends StatefulWidget {
  const BlinkerOverlay({super.key});

  @override
  State<BlinkerOverlay> createState() => _BlinkerOverlayState();
}

class _BlinkerOverlayState extends State<BlinkerOverlay> {
  Key _animKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsSync, SettingsData>(
      buildWhen: (prev, curr) => prev.blinkerStyle != curr.blinkerStyle,
      builder: (context, settings) {
        if (!settings.blinkerOverlayEnabled) return const SizedBox.shrink();

        return BlocConsumer<VehicleSync, VehicleData>(
          listenWhen: (prev, curr) => prev.blinkerState != curr.blinkerState,
          listener: (context, _) {
            if (mounted) setState(() => _animKey = UniqueKey());
          },
          buildWhen: (prev, curr) => prev.blinkerState != curr.blinkerState,
          builder: (context, vehicle) {
            final state = vehicle.blinkerState;
            if (state != BlinkerState.left && state != BlinkerState.right) {
              return const SizedBox.shrink();
            }

            return IgnorePointer(
              child: _BlinkerOverlayContent(
                key: _animKey,
                isLeft: state == BlinkerState.left,
              ),
            );
          },
        );
      },
    );
  }
}

class _BlinkerOverlayContent extends StatelessWidget {
  final bool isLeft;

  const _BlinkerOverlayContent({super.key, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCubit.watch(context).isDark;
    final inactiveColor = isDark ? Colors.white12 : Colors.black12;
    final iconName = isLeft
        ? 'librescoot-turn-left.svg'
        : 'librescoot-turn-right.svg';

    svg(Color color) => SvgPicture.asset(
          'assets/icons/$iconName',
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 360,
          height: 360,
        );

    return Center(
      child: Stack(
        children: [
          svg(inactiveColor),
          CustomAnimationBuilder<int>(
            control: Control.loop,
            tween: TweenSequence<int>([
              TweenSequenceItem(
                tween: IntTween(begin: 0, end: 204)
                    .chain(CurveTween(curve: Curves.easeInOutExpo)),
                weight: 250,
              ),
              TweenSequenceItem(
                tween: IntTween(begin: 204, end: 0)
                    .chain(CurveTween(curve: Curves.easeInOutExpo)),
                weight: 250,
              ),
              TweenSequenceItem(
                tween: ConstantTween<int>(0),
                weight: 228,
              ),
            ]),
            duration: const Duration(milliseconds: 728),
            builder: (context, value, _) => svg(Colors.green.withAlpha(value)),
          ),
        ],
      ),
    );
  }
}
