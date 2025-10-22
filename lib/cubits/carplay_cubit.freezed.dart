// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'carplay_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarPlayState implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'CarPlayState'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CarPlayState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CarPlayState()';
  }
}

/// @nodoc
class $CarPlayStateCopyWith<$Res> {
  $CarPlayStateCopyWith(CarPlayState _, $Res Function(CarPlayState) __);
}

/// @nodoc

class CarPlayDisconnected with DiagnosticableTreeMixin implements CarPlayState {
  const CarPlayDisconnected();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'CarPlayState.disconnected'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CarPlayDisconnected);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CarPlayState.disconnected()';
  }
}

/// @nodoc

class CarPlayConnecting with DiagnosticableTreeMixin implements CarPlayState {
  const CarPlayConnecting();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'CarPlayState.connecting'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CarPlayConnecting);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CarPlayState.connecting()';
  }
}

/// @nodoc

class CarPlayConnected with DiagnosticableTreeMixin implements CarPlayState {
  const CarPlayConnected({required this.controller});

  final VideoPlayerController controller;

  /// Create a copy of CarPlayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CarPlayConnectedCopyWith<CarPlayConnected> get copyWith =>
      _$CarPlayConnectedCopyWithImpl<CarPlayConnected>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CarPlayState.connected'))
      ..add(DiagnosticsProperty('controller', controller));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CarPlayConnected &&
            (identical(other.controller, controller) ||
                other.controller == controller));
  }

  @override
  int get hashCode => Object.hash(runtimeType, controller);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CarPlayState.connected(controller: $controller)';
  }
}

/// @nodoc
abstract mixin class $CarPlayConnectedCopyWith<$Res>
    implements $CarPlayStateCopyWith<$Res> {
  factory $CarPlayConnectedCopyWith(
          CarPlayConnected value, $Res Function(CarPlayConnected) _then) =
      _$CarPlayConnectedCopyWithImpl;
  @useResult
  $Res call({VideoPlayerController controller});
}

/// @nodoc
class _$CarPlayConnectedCopyWithImpl<$Res>
    implements $CarPlayConnectedCopyWith<$Res> {
  _$CarPlayConnectedCopyWithImpl(this._self, this._then);

  final CarPlayConnected _self;
  final $Res Function(CarPlayConnected) _then;

  /// Create a copy of CarPlayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? controller = null,
  }) {
    return _then(CarPlayConnected(
      controller: null == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController,
    ));
  }
}

/// @nodoc

class CarPlayError with DiagnosticableTreeMixin implements CarPlayState {
  const CarPlayError({required this.message});

  final String message;

  /// Create a copy of CarPlayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CarPlayErrorCopyWith<CarPlayError> get copyWith =>
      _$CarPlayErrorCopyWithImpl<CarPlayError>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CarPlayState.error'))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CarPlayError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CarPlayState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $CarPlayErrorCopyWith<$Res>
    implements $CarPlayStateCopyWith<$Res> {
  factory $CarPlayErrorCopyWith(
          CarPlayError value, $Res Function(CarPlayError) _then) =
      _$CarPlayErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$CarPlayErrorCopyWithImpl<$Res> implements $CarPlayErrorCopyWith<$Res> {
  _$CarPlayErrorCopyWithImpl(this._self, this._then);

  final CarPlayError _self;
  final $Res Function(CarPlayError) _then;

  /// Create a copy of CarPlayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(CarPlayError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
