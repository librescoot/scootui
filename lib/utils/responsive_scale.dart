import 'package:flutter/material.dart';

import '../env_config.dart';

/// Utility class for responsive scaling of UI elements
class ResponsiveScale {
  /// Scale a value based on the current resolution scale factor
  static double scale(double value) {
    return value * EnvConfig.scaleFactor;
  }

  /// Scale text size based on the current resolution
  static double scaleText(double fontSize) {
    return fontSize * EnvConfig.scaleFactor;
  }

  /// Scale padding/margin values
  static EdgeInsets scaleEdgeInsets(EdgeInsets insets) {
    final factor = EnvConfig.scaleFactor;
    return EdgeInsets.only(
      left: insets.left * factor,
      top: insets.top * factor,
      right: insets.right * factor,
      bottom: insets.bottom * factor,
    );
  }

  /// Scale symmetric padding/margin
  static EdgeInsets scaleSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    final factor = EnvConfig.scaleFactor;
    return EdgeInsets.symmetric(
      horizontal: horizontal * factor,
      vertical: vertical * factor,
    );
  }

  /// Scale all sides equally
  static EdgeInsets scaleAll(double value) {
    return EdgeInsets.all(value * EnvConfig.scaleFactor);
  }

  /// Scale a Size object
  static Size scaleSize(Size size) {
    final factor = EnvConfig.scaleFactor;
    return Size(size.width * factor, size.height * factor);
  }

  /// Scale a radius value
  static Radius scaleRadius(double radius) {
    return Radius.circular(radius * EnvConfig.scaleFactor);
  }

  /// Scale a BorderRadius
  static BorderRadius scaleBorderRadius(double radius) {
    return BorderRadius.circular(radius * EnvConfig.scaleFactor);
  }

  /// Get scaled screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get scaled screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Calculate a value as percentage of screen width
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Calculate a value as percentage of screen height
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }
}

/// Extension methods for convenient scaling
extension ResponsiveDouble on num {
  /// Scale this value by the current scale factor
  double get scaled => ResponsiveScale.scale(toDouble());

  /// Use this value as scaled text size
  double get scaledText => ResponsiveScale.scaleText(toDouble());

  /// Use this value as scaled radius
  Radius get scaledRadius => ResponsiveScale.scaleRadius(toDouble());

  /// Use this value as scaled border radius
  BorderRadius get scaledBorderRadius => ResponsiveScale.scaleBorderRadius(toDouble());

  /// Use this value for all padding sides
  EdgeInsets get scaledPadding => ResponsiveScale.scaleAll(toDouble());
}