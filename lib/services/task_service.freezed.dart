// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskStatus<T> implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'TaskStatus<$T>'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TaskStatus<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskStatus<$T>()';
  }
}

/// @nodoc
class $TaskStatusCopyWith<T, $Res> {
  $TaskStatusCopyWith(TaskStatus<T> _, $Res Function(TaskStatus<T>) __);
}

/// @nodoc

class TaskPending<T> with DiagnosticableTreeMixin implements TaskStatus<T> {
  const TaskPending();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'TaskStatus<$T>.pending'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TaskPending<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskStatus<$T>.pending()';
  }
}

/// @nodoc

class TaskRunning<T> with DiagnosticableTreeMixin implements TaskStatus<T> {
  const TaskRunning({this.step, this.progress, this.eta});

  final String? step;
  final double? progress;
  final Duration? eta;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskRunningCopyWith<T, TaskRunning<T>> get copyWith =>
      _$TaskRunningCopyWithImpl<T, TaskRunning<T>>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'TaskStatus<$T>.running'))
      ..add(DiagnosticsProperty('step', step))
      ..add(DiagnosticsProperty('progress', progress))
      ..add(DiagnosticsProperty('eta', eta));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskRunning<T> &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.eta, eta) || other.eta == eta));
  }

  @override
  int get hashCode => Object.hash(runtimeType, step, progress, eta);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskStatus<$T>.running(step: $step, progress: $progress, eta: $eta)';
  }
}

/// @nodoc
abstract mixin class $TaskRunningCopyWith<T, $Res>
    implements $TaskStatusCopyWith<T, $Res> {
  factory $TaskRunningCopyWith(
          TaskRunning<T> value, $Res Function(TaskRunning<T>) _then) =
      _$TaskRunningCopyWithImpl;
  @useResult
  $Res call({String? step, double? progress, Duration? eta});
}

/// @nodoc
class _$TaskRunningCopyWithImpl<T, $Res>
    implements $TaskRunningCopyWith<T, $Res> {
  _$TaskRunningCopyWithImpl(this._self, this._then);

  final TaskRunning<T> _self;
  final $Res Function(TaskRunning<T>) _then;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? step = freezed,
    Object? progress = freezed,
    Object? eta = freezed,
  }) {
    return _then(TaskRunning<T>(
      step: freezed == step
          ? _self.step
          : step // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: freezed == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      eta: freezed == eta
          ? _self.eta
          : eta // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc

class TaskCompleted<T> with DiagnosticableTreeMixin implements TaskStatus<T> {
  const TaskCompleted({required this.result});

  final T result;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskCompletedCopyWith<T, TaskCompleted<T>> get copyWith =>
      _$TaskCompletedCopyWithImpl<T, TaskCompleted<T>>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'TaskStatus<$T>.completed'))
      ..add(DiagnosticsProperty('result', result));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskCompleted<T> &&
            const DeepCollectionEquality().equals(other.result, result));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(result));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskStatus<$T>.completed(result: $result)';
  }
}

/// @nodoc
abstract mixin class $TaskCompletedCopyWith<T, $Res>
    implements $TaskStatusCopyWith<T, $Res> {
  factory $TaskCompletedCopyWith(
          TaskCompleted<T> value, $Res Function(TaskCompleted<T>) _then) =
      _$TaskCompletedCopyWithImpl;
  @useResult
  $Res call({T result});
}

/// @nodoc
class _$TaskCompletedCopyWithImpl<T, $Res>
    implements $TaskCompletedCopyWith<T, $Res> {
  _$TaskCompletedCopyWithImpl(this._self, this._then);

  final TaskCompleted<T> _self;
  final $Res Function(TaskCompleted<T>) _then;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? result = freezed,
  }) {
    return _then(TaskCompleted<T>(
      result: freezed == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class TaskError<T> with DiagnosticableTreeMixin implements TaskStatus<T> {
  const TaskError({required this.message});

  final String message;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskErrorCopyWith<T, TaskError<T>> get copyWith =>
      _$TaskErrorCopyWithImpl<T, TaskError<T>>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'TaskStatus<$T>.error'))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskError<T> &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskStatus<$T>.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $TaskErrorCopyWith<T, $Res>
    implements $TaskStatusCopyWith<T, $Res> {
  factory $TaskErrorCopyWith(
          TaskError<T> value, $Res Function(TaskError<T>) _then) =
      _$TaskErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$TaskErrorCopyWithImpl<T, $Res> implements $TaskErrorCopyWith<T, $Res> {
  _$TaskErrorCopyWithImpl(this._self, this._then);

  final TaskError<T> _self;
  final $Res Function(TaskError<T>) _then;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(TaskError<T>(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
