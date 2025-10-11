import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Utility class for responsive design calculations
class ResponsiveUtils {
  /// Default reference size (original design size)
  static const Size referenceSize = Size(480, 480);

  /// Minimum supported size
  static const Size minimumSize = Size(320, 320);

  /// Get scale factor based on screen size
  /// Uses the smaller dimension to maintain aspect ratio
  static double getScaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleX = size.width / referenceSize.width;
    final scaleY = size.height / referenceSize.height;

    // Use minimum scale to ensure content fits
    return math.min(scaleX, scaleY);
  }

  /// Scale a value based on screen size
  static double scale(BuildContext context, double value) {
    return value * getScaleFactor(context);
  }

  /// Scale font size with min/max constraints
  static double scaleFontSize(BuildContext context, double baseSize, {
    double? minSize,
    double? maxSize,
  }) {
    final scaled = scale(context, baseSize);
    if (minSize != null && scaled < minSize) return minSize;
    if (maxSize != null && scaled > maxSize) return maxSize;
    return scaled;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final scaleFactor = getScaleFactor(context);

    if (all != null) {
      return EdgeInsets.all(all * scaleFactor);
    }

    return EdgeInsets.only(
      left: (left ?? horizontal ?? 0) * scaleFactor,
      top: (top ?? vertical ?? 0) * scaleFactor,
      right: (right ?? horizontal ?? 0) * scaleFactor,
      bottom: (bottom ?? vertical ?? 0) * scaleFactor,
    );
  }

  /// Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  /// Check if screen is small (< 400px in smallest dimension)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final smallestDimension = math.min(size.width, size.height);
    return smallestDimension < 400;
  }

  /// Check if screen is large (> 600px in smallest dimension)
  static bool isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final smallestDimension = math.min(size.width, size.height);
    return smallestDimension > 600;
  }
}

/// Widget that rebuilds based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Size size, double scaleFactor) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);

    return builder(context, size, scaleFactor);
  }
}

/// Configuration for responsive screen sizes
class ScreenConfig {
  final Size defaultSize;
  final Size minSize;
  final Size? maxSize;
  final bool allowResize;

  const ScreenConfig({
    this.defaultSize = const Size(800, 600),
    this.minSize = const Size(320, 320),
    this.maxSize,
    this.allowResize = true,
  });

  /// Configuration for embedded devices (fixed size)
  static const ScreenConfig embedded = ScreenConfig(
    defaultSize: Size(480, 480),
    minSize: Size(480, 480),
    maxSize: Size(480, 480),
    allowResize: false,
  );

  /// Configuration for desktop (flexible size)
  static const ScreenConfig desktop = ScreenConfig(
    defaultSize: Size(800, 600),
    minSize: Size(480, 480),
    maxSize: Size(1920, 1080),
    allowResize: true,
  );

  /// Configuration for mobile/tablet
  static const ScreenConfig mobile = ScreenConfig(
    defaultSize: Size(480, 480),
    minSize: Size(320, 320),
    maxSize: Size(1024, 1024),
    allowResize: true,
  );
}