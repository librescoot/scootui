import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/vehicle_state.dart';

class WarningIndicators extends StatelessWidget {
  final VehicleState state;

  const WarningIndicators({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left turn signal
          _IndicatorSvgIcon(
            iconPath: 'librescoot-turn-left.svg',
            isActive: state.blinkerState == 'left' || state.blinkerState == 'both',
            activeColor: Colors.green,
            size: 48,
            isBlinking: state.blinkerState == 'left' || state.blinkerState == 'both',
          ),

          // Center indicators
          _CenterIndicators(state: state),

          // Right turn signal
          _IndicatorSvgIcon(
            iconPath: 'librescoot-turn-right.svg',
            isActive: state.blinkerState == 'right' || state.blinkerState == 'both',
            activeColor: Colors.green,
            size: 48,
            isBlinking: state.blinkerState == 'right' || state.blinkerState == 'both',
          ),
        ],
      ),
    );
  }
}

class _IndicatorIcon extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final double size;
  final bool isBlinking;

  const _IndicatorIcon({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.size,
    this.isBlinking = false,
  });

  @override
  State<_IndicatorIcon> createState() => _IndicatorIconState();
}

class _IndicatorIconState extends State<_IndicatorIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(  
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, 
      ),
    );

    if (widget.isBlinking && widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_IndicatorIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking && widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.white24 : Colors.black26;

    if (!widget.isActive) {
      return Icon(
        widget.icon,
        color: inactiveColor,
        size: widget.size,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Icon(
          widget.icon,
          color: widget.activeColor.withOpacity(_animation.value),
          size: widget.size,
        );
      },
    );
  }
}

class _IndicatorSvgIcon extends StatefulWidget {
  final String iconPath;
  final bool isActive;
  final Color activeColor;
  final double size;
  final bool isBlinking;

  const _IndicatorSvgIcon({
    required this.iconPath,
    required this.isActive,
    required this.activeColor,
    required this.size,
    this.isBlinking = false,
  });

  @override
  State<_IndicatorSvgIcon> createState() => _IndicatorSvgIconState();
}

class _IndicatorSvgIconState extends State<_IndicatorSvgIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.isBlinking && widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_IndicatorSvgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking && widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.white24 : Colors.black26;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SvgPicture.asset(
          'assets/icons/${widget.iconPath}',
          colorFilter: ColorFilter.mode(
            widget.isActive 
              ? widget.activeColor.withOpacity(_animation.value)
              : inactiveColor,
            BlendMode.srcIn,
          ),
          width: widget.size,
          height: widget.size,
        );
      },
    );
  }
}

class _CenterIndicators extends StatelessWidget {
 final VehicleState state;
 final double baseSize;

 const _CenterIndicators({
   required this.state,
   this.baseSize = 36,
 });

 @override
 Widget build(BuildContext context) {
   return Row(
     mainAxisSize: MainAxisSize.min,
     children: [
       if (state.isUnableToDrive) 
         _IndicatorSvgIcon(
           iconPath: 'librescoot-engine-warning.svg',
           isActive: true,
           activeColor: Colors.yellow,
           size: baseSize,
         ),
         
       if (state.blinkerState == 'both')
         _IndicatorSvgIcon(
           iconPath: 'librescoot-hazards.svg', 
           isActive: true,
           activeColor: Colors.red,
           size: baseSize,
           isBlinking: true,
         ),
         
       if (state.isParked)
         _IndicatorSvgIcon(
           iconPath: 'librescoot-parking-brake.svg',
           isActive: true,
           activeColor: Colors.red,
           size: baseSize,
         ),
     ],
   );
 }
}