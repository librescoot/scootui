import 'package:flutter/material.dart';

import '../env_config.dart';

/// A container widget that scales its child based on the configured resolution
class ScaledContainer extends StatelessWidget {
  final Widget child;
  final bool scaleText;

  const ScaledContainer({
    super.key,
    required this.child,
    this.scaleText = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = EnvConfig.scaleFactor;

    // If scale factor is 1.0, no transformation needed
    if (scaleFactor == 1.0) {
      return child;
    }

    Widget scaledChild = Transform.scale(
      scale: scaleFactor,
      alignment: Alignment.center,
      child: child,
    );

    // Optionally scale text as well
    if (scaleText) {
      scaledChild = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: scaleFactor,
        ),
        child: scaledChild,
      );
    }

    return scaledChild;
  }
}

/// A specialized scaled container for the main app that ensures proper sizing
class AppScaledContainer extends StatelessWidget {
  final Widget child;

  const AppScaledContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final resolution = EnvConfig.resolution;

    // For embedded systems with DRM/GBM, we may want to use the full screen
    // but scale the content appropriately
    return SizedBox(
      width: resolution.width,
      height: resolution.height,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: EnvConfig.defaultResolution.width,
          height: EnvConfig.defaultResolution.height,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: EnvConfig.defaultResolution,
              textScaleFactor: 1.0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}