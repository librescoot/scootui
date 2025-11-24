import 'dart:async';

enum ToastType { info, error, success, warning, permanentInfo, permanentError }

class ToastEvent {
  final String message;
  final ToastType type;
  final String? id;

  ToastEvent(this.message, this.type, {this.id});
}

class DismissToastEvent {
  final String id;
  DismissToastEvent(this.id);
}

class ToastService {
  // Private constructor to prevent instantiation
  ToastService._();

  static final _controller = StreamController<ToastEvent>.broadcast();
  static final _dismissController = StreamController<DismissToastEvent>.broadcast();

  static Stream<ToastEvent> get events => _controller.stream;
  static Stream<DismissToastEvent> get dismissEvents => _dismissController.stream;

  static void showInfo(String message) {
    _controller.add(ToastEvent(message, ToastType.info));
  }

  static void showError(String message) {
    _controller.add(ToastEvent(message, ToastType.error));
  }

  static void showSuccess(String message) {
    _controller.add(ToastEvent(message, ToastType.success));
  }

  static void showWarning(String message) {
    _controller.add(ToastEvent(message, ToastType.warning));
  }

  static void showPermanentInfo(String message, String id) {
    _controller.add(ToastEvent(message, ToastType.permanentInfo, id: id));
  }

  static void showPermanentError(String message, String id) {
    _controller.add(ToastEvent(message, ToastType.permanentError, id: id));
  }

  static void dismiss(String id) {
    _dismissController.add(DismissToastEvent(id));
  }

  // Call this in your main app's dispose or when no longer needed,
  // though for a global service, it might live for the app's lifetime.
  static void dispose() {
    _controller.close();
    _dismissController.close();
  }
}
