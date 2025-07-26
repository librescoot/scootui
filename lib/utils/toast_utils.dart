import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ToastUtils {
  static final Queue<_ToastItem> _toastQueue = Queue<_ToastItem>();
  static bool _isShowingToast = false;
  static Timer? _currentTimer;

  static void showToast(
    BuildContext context,
    String message, {
    ToastPosition position = ToastPosition.bottom,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface.withOpacity(0.90);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    // Add to queue
    _toastQueue.add(_ToastItem(
      message: message,
      backgroundColor: effectiveBackgroundColor,
      textColor: effectiveTextColor,
      duration: duration,
      position: position,
    ));

    // Process queue if not already processing
    if (!_isShowingToast) {
      _processQueue();
    }
  }

  static void _processQueue() {
    if (_toastQueue.isEmpty) {
      _isShowingToast = false;
      return;
    }

    _isShowingToast = true;
    final item = _toastQueue.removeFirst();

    // Dismiss any existing toasts
    dismissAllToast();

    showToastWidget(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          item.message,
          style: TextStyle(
            color: item.textColor,
            fontSize: 16.0,
          ),
        ),
      ),
      duration: item.duration,
      position: item.position,
      dismissOtherToast: true,
    );

    // Cancel any existing timer
    _currentTimer?.cancel();

    // Schedule next toast after current one finishes
    _currentTimer = Timer(item.duration, () {
      _processQueue();
    });
  }

  static void showErrorToast(BuildContext context, String message) {
    final theme = Theme.of(context);
    showToast(
      context,
      message,
      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.9),
      textColor: theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 3),
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
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.9),
      textColor: theme.colorScheme.onSecondaryContainer,
      duration: const Duration(seconds: 2),
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
}

class _ToastItem {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;
  final ToastPosition position;

  _ToastItem({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
    required this.position,
  });
}
