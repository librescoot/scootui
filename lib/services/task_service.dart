import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'toast_service.dart';

part 'task_service.freezed.dart';

@freezed
sealed class TaskStatus<T> with _$TaskStatus {
  const factory TaskStatus.pending() = TaskPending;
  const factory TaskStatus.running(
      {String? step, double? progress, Duration? eta}) = TaskRunning;
  const factory TaskStatus.completed({required T result}) = TaskCompleted;
  const factory TaskStatus.error({required String message}) = TaskError;
}

// A task is like a more sophisticated future, that allows for tracking progress,
// cancellation, and detailed steps.
abstract class Task<T> {
  Task()
      : _status = TaskStatus.pending(),
        id = Random().nextInt(1 << 32).toString(),
        _lastProgressValue = 0.0; // Initialize for EWMA

  late final SendPort sendPort;
  TaskStatus<T> _status;
  Isolate? _isolate;
  DateTime? _startTime;
  Completer<TaskStatus>? _completer; // Use raw type to avoid type issues

  // For EWMA ETA calculation
  static const double _ewmaAlpha =
      2.0 / 21.0; // Smoothing factor (N=20 periods for smoother ETA)
  double? _ewmaTimePerProgressUnit; // EWMA of microseconds per unit of progress
  DateTime? _lastProgressUpdateTime;
  double _lastProgressValue =
      0.0; // Initial progress is 0, initialized in constructor

  final String id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is! Task<T>) return false;

    return this.id == other.id;
  }

  String get name;

  void emit(TaskStatus<T> status) {
    if (status == _status) return;
    _status = status;
    sendPort.send(_status);
  }

  @protected
  void step(String name) {
    final current = _status;
    if (_startTime == null) {
      // First event (step or progress) that indicates task is starting
      final now = DateTime.now();
      _startTime = now;
      _lastProgressUpdateTime =
          now; // Initialize for first EWMA calculation window
      // _lastProgressValue is already 0.0 from constructor
      // _ewmaTimePerProgressUnit is null
    }

    emit(switch (current) {
      TaskPending() => TaskStatus.running(step: name),
      TaskRunning() => current.copyWith(step: name),
      _ => current
    });
  }

  @protected
  void progress(double newProgress) {
    final currentStatus = _status;
    Duration? calculatedEta;

    final currentTime = DateTime.now();

    if (_startTime == null) {
      // If progress is called before any step and task hasn't "started"
      _startTime = currentTime;
      _lastProgressUpdateTime = currentTime;
    }

    if (_lastProgressUpdateTime != null) {
      if (newProgress >= 1.0) {
        calculatedEta = Duration.zero;
        // Optionally, could set _ewmaTimePerProgressUnit = 0 or null here
      } else {
        final elapsedSinceLastUpdate =
            currentTime.difference(_lastProgressUpdateTime!);
        final progressDelta = newProgress - _lastProgressValue;

        // Only update EWMA if progress has advanced meaningfully and sufficient time has passed.
        // Threshold for progressDelta (e.g., 0.01% = 1e-4) and time (e.g. 1ms = 1000us).
        if (progressDelta > 1e-4 &&
            elapsedSinceLastUpdate.inMicroseconds > 1000) {
          final currentTimePerUnit =
              elapsedSinceLastUpdate.inMicroseconds / progressDelta;

          if (_ewmaTimePerProgressUnit == null ||
              _ewmaTimePerProgressUnit! <= 0) {
            _ewmaTimePerProgressUnit = currentTimePerUnit;
          } else {
            _ewmaTimePerProgressUnit = (_ewmaAlpha * currentTimePerUnit) +
                ((1 - _ewmaAlpha) * _ewmaTimePerProgressUnit!);
          }
        }

        // Always try to calculate ETA if EWMA is available and progress is ongoing.
        if (_ewmaTimePerProgressUnit != null && _ewmaTimePerProgressUnit! > 0) {
          final remainingProgress = 1.0 - newProgress;
          if (remainingProgress > 1e-9) {
            // Ensure there's progress remaining
            final etaMicroseconds =
                (_ewmaTimePerProgressUnit! * remainingProgress).round();
            calculatedEta = Duration(microseconds: etaMicroseconds);
          } else {
            // Progress is effectively 1.0, but newProgress < 1.0 check above might not catch all fp issues.
            calculatedEta = Duration.zero;
          }
        }
        // If _ewmaTimePerProgressUnit is still null or not positive, calculatedEta remains null.
        // This means ETA will only show up after the first valid EWMA calculation.
      }
    }

    // Update tracking variables for the next call
    _lastProgressUpdateTime = currentTime;
    // Update _lastProgressValue only if newProgress is greater, to handle out-of-order or non-increasing progress reports gracefully.
    if (newProgress > _lastProgressValue) {
      _lastProgressValue = newProgress;
    }

    emit(switch (currentStatus) {
      TaskPending() =>
        TaskStatus.running(progress: newProgress, eta: calculatedEta),
      TaskRunning() =>
        currentStatus.copyWith(progress: newProgress, eta: calculatedEta),
      _ => currentStatus
    });
  }

  Future<void> _start(SendPort port) async {
    final token = RootIsolateToken.instance;
    if (token == null) {
      throw Exception(
          "RootIsolateToken is not available. Ensure this runs in the main isolate.");
    }

    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    _isolate = await Isolate.spawn(_isolateRun, port);
  }

  void _isolateRun(SendPort port) async {
    sendPort = port;
    emit(TaskStatus.pending());

    try {
      final result = await run();
      emit(TaskStatus.completed(result: result));
    } catch (e, stackTrace) {
      emit(TaskStatus.error(message: e.toString()));
      print('Task error: $e\n$stackTrace');
    }
  }

  void cancel() {
    _isolate?.kill();
    _completer?.completeError(Exception('Task cancelled'));
  }

  /// Waits for the task to complete and returns the final status.
  /// Throws a TimeoutException if the task doesn't complete within the given duration.
  Future<TaskStatus<T>> wait([Duration? timeout]) {
    // If the task is already in a terminal state, return immediately
    switch (_status) {
      case TaskCompleted():
      case TaskError():
        return Future.value(_status);
      default:
      // Wait for completion
    }

    // If completer hasn't been created yet, create it now
    _completer ??= Completer<TaskStatus>();

    if (timeout != null) {
      return _completer!.future.timeout(
        timeout,
        onTimeout: () {
          cancel();
          throw TimeoutException(
              'Task did not complete within $timeout', timeout);
        },
      ).then(
          (status) => status as TaskStatus<T>); // Cast back to the correct type
    }

    return _completer!.future.then(
        (status) => status as TaskStatus<T>); // Cast back to the correct type
  }

  Future<T> run();
}

class TaskService {
  final StreamController<List<(Task, TaskStatus)>> _ctrl =
      StreamController<List<(Task, TaskStatus)>>.broadcast();

  final LinkedHashMap<Task, TaskStatus> _tasks =
      LinkedHashMap<Task, TaskStatus>();

  // Queue for pending tasks
  final Queue<Task> _taskQueue = Queue<Task>();
  Task? _currentTask;

  void _emit() {
    _ctrl.add(tasks);
  }

  void addTask(Task task) {
    _tasks[task] = task._status;
    _emit();

    // Add to queue instead of starting immediately
    _taskQueue.add(task);

    // Process next task if no task is currently running
    _processNextTask();
  }

  void _processNextTask() {
    // If a task is already running or no tasks in queue, return
    if (_currentTask != null || _taskQueue.isEmpty) {
      return;
    }

    // Get next task from queue
    final task = _taskQueue.removeFirst();
    _currentTask = task;

    final port = ReceivePort();
    task._start(port.sendPort);

    // Create the completer here, before setting up the listener
    task._completer ??= Completer<TaskStatus>();

    // Track if we've shown the start toast for this task
    bool startToastShown = false;

    port.forEach((state) {
      _tasks[task] = state as TaskStatus;

      switch (state) {
        case TaskRunning():
          // Show toast only once when task starts running
          if (!startToastShown) {
            ToastService.showInfo('Started: ${task.name}');
            startToastShown = true;
          }
          _emit();
        case TaskCompleted():
          _tasks.remove(task);
          _emit();
          task._completer?.complete(state);
          port.close(); // Close the port after completion

          // Show success toast
          ToastService.showSuccess('Completed: ${task.name}');

          // Mark task as complete and process next
          _currentTask = null;
          _processNextTask();
        case TaskError(:final message):
          _tasks.remove(task);
          _emit();
          task._completer?.complete(state);
          port.close(); // Close the port after completion

          // Show error toast
          ToastService.showError('Failed: ${task.name} - $message');

          // Mark task as complete and process next
          _currentTask = null;
          _processNextTask();
        default:
      }
    });
  }

  void cancelTask(Task task) {
    // Remove from queue if pending
    if (_taskQueue.contains(task)) {
      _taskQueue.remove(task);
      _tasks.remove(task);
      _emit();
      return;
    }

    // Cancel if it's the current task
    if (_currentTask == task) {
      _tasks.remove(task);
      task.cancel();
      _currentTask = null;
      _processNextTask(); // Process next task after cancellation
    }
  }

  List<(Task, TaskStatus)> get tasks =>
      _tasks.entries.map((e) => (e.key, e.value)).toList();
  Stream<List<(Task, TaskStatus)>> get stream => _ctrl.stream;
}
