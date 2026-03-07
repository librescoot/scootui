import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../cubits/mdb_cubits.dart';
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
            setState(() => _animKey = UniqueKey());
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
    final iconName = isLeft
        ? 'librescoot-turn-left.svg'
        : 'librescoot-turn-right.svg';

    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: CustomAnimationBuilder<int>(
          control: Control.loop,
          tween: TweenSequence<int>([
            TweenSequenceItem(
              tween: IntTween(begin: 0, end: 255)
                  .chain(CurveTween(curve: Curves.easeInOutExpo)),
              weight: 250,
            ),
            TweenSequenceItem(
              tween: IntTween(begin: 255, end: 0)
                  .chain(CurveTween(curve: Curves.easeInOutExpo)),
              weight: 250,
            ),
            TweenSequenceItem(
              tween: ConstantTween<int>(0),
              weight: 228,
            ),
          ]),
          duration: const Duration(milliseconds: 728),
          builder: (context, value, _) => SvgPicture.asset(
            'assets/icons/$iconName',
            colorFilter: ColorFilter.mode(
              Colors.green.withAlpha(value),
              BlendMode.srcIn,
            ),
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
