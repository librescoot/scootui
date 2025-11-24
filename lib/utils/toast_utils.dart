import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ToastUtils {
  static void showToast(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.top,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.surface.withOpacity(0.95);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    showToastWidget(
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 480,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          margin: const EdgeInsets.only(top: 40.0), // Position right below status bar (40px)
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      duration: duration,
      position: ToastPosition.center, // Use center and align manually
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  static ToastFuture showPermanentToast(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.surface.withOpacity(0.95);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    return showToastWidget(
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 480,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          margin: const EdgeInsets.only(top: 40.0),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
      duration: const Duration(days: 365),
      position: ToastPosition.center,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    showToast(
      context,
      message,
      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.95),
      textColor: theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 15),
    );
  }

  static void showSuccessToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    showToast(
      context,
      message,
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.9),
      textColor: theme.colorScheme.onPrimaryContainer,
      duration: const Duration(seconds: 2),
    );
  }

  static void showInfoToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    showToast(
      context,
      message,
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.95),
      textColor: theme.colorScheme.onSecondaryContainer,
      duration: const Duration(seconds: 5),
    );
  }

  static void showWarningToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    showToast(
      context,
      message,
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.9),
      textColor: theme.colorScheme.onSecondaryContainer,
      duration: const Duration(seconds: 3),
    );
  }

  static void showPersistentErrorToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    showToast(
      context,
      message,
      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.95),
      textColor: theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 15),
    );
  }
}
