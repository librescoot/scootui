import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../services/toast_service.dart';
import '../utils/toast_utils.dart';

class ToastListenerWrapper extends StatefulWidget {
  final Widget child;

  const ToastListenerWrapper({super.key, required this.child});

  @override
  State<ToastListenerWrapper> createState() => _ToastListenerWrapperState();
}

class _ToastListenerWrapperState extends State<ToastListenerWrapper> {
  late StreamSubscription<ToastEvent> _toastSubscription;
  late StreamSubscription<DismissToastEvent> _dismissSubscription;
  final Map<String, ToastFuture> _activeToasts = {};

  @override
  void initState() {
    super.initState();
    _toastSubscription = ToastService.events.listen((event) {
      if (mounted) {
        ToastFuture? toastFuture;

        switch (event.type) {
          case ToastType.info:
            ToastUtils.showInfoToast(context, event.message);
            break;
          case ToastType.error:
            ToastUtils.showErrorToast(context, event.message);
            break;
          case ToastType.success:
            ToastUtils.showSuccessToast(context, event.message);
            break;
          case ToastType.warning:
            ToastUtils.showWarningToast(context, event.message);
            break;
          case ToastType.permanentInfo:
            toastFuture = ToastUtils.showPermanentToast(context, event.message);
            break;
          case ToastType.permanentError:
            toastFuture = ToastUtils.showPermanentToast(
              context,
              event.message,
              backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.95),
              textColor: Theme.of(context).colorScheme.onErrorContainer,
            );
            break;
        }

        // Track permanent toasts by ID for dismissal
        if (event.id != null && toastFuture != null) {
          _activeToasts[event.id!] = toastFuture;
        }
      }
    });

    _dismissSubscription = ToastService.dismissEvents.listen((event) {
      final toastFuture = _activeToasts.remove(event.id);
      toastFuture?.dismiss();
    });
  }

  @override
  void dispose() {
    _toastSubscription.cancel();
    _dismissSubscription.cancel();
    ToastService.dispose(); // Optional: Dispose the service stream if app is closing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
