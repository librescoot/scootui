// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'screen_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScreenState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState()';
  }
}

/// @nodoc
class $ScreenStateCopyWith<$Res> {
  $ScreenStateCopyWith(ScreenState _, $Res Function(ScreenState) __);
}

/// @nodoc

class ScreenCluster implements ScreenState {
  const ScreenCluster();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenCluster);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.cluster()';
  }
}

/// @nodoc

class ScreenMap implements ScreenState {
  const ScreenMap();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenMap);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.map()';
  }
}

/// @nodoc

class ScreenAddressSelection implements ScreenState {
  const ScreenAddressSelection();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenAddressSelection);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.addressSelection()';
  }
}

/// @nodoc

class ScreenOtaBackground implements ScreenState {
  const ScreenOtaBackground();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenOtaBackground);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.otaBackground()';
  }
}

/// @nodoc

class ScreenOta implements ScreenState {
  const ScreenOta();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenOta);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.ota()';
  }
}

/// @nodoc

class ScreenDebug implements ScreenState {
  const ScreenDebug();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenDebug);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.debug()';
  }
}

/// @nodoc

class ScreenCarPlay implements ScreenState {
  const ScreenCarPlay();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenCarPlay);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.carplay()';
  }
}

/// @nodoc

class ScreenShuttingDown implements ScreenState {
  const ScreenShuttingDown();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenShuttingDown);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.shuttingDown()';
  }
}

/// @nodoc

class ScreenAbout implements ScreenState {
  const ScreenAbout();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScreenAbout);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScreenState.about()';
  }
}

/// @nodoc

class ScreenNavigationSetup implements ScreenState {
  const ScreenNavigationSetup({this.setupMode = SetupMode.both});

  @JsonKey()
  final SetupMode setupMode;

  /// Create a copy of ScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScreenNavigationSetupCopyWith<ScreenNavigationSetup> get copyWith =>
      _$ScreenNavigationSetupCopyWithImpl<ScreenNavigationSetup>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScreenNavigationSetup &&
            (identical(other.setupMode, setupMode) ||
                other.setupMode == setupMode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, setupMode);

  @override
  String toString() {
    return 'ScreenState.navigationSetup(setupMode: $setupMode)';
  }
}

/// @nodoc
abstract mixin class $ScreenNavigationSetupCopyWith<$Res>
    implements $ScreenStateCopyWith<$Res> {
  factory $ScreenNavigationSetupCopyWith(ScreenNavigationSetup value,
          $Res Function(ScreenNavigationSetup) _then) =
      _$ScreenNavigationSetupCopyWithImpl;
  @useResult
  $Res call({SetupMode setupMode});
}

/// @nodoc
class _$ScreenNavigationSetupCopyWithImpl<$Res>
    implements $ScreenNavigationSetupCopyWith<$Res> {
  _$ScreenNavigationSetupCopyWithImpl(this._self, this._then);

  final ScreenNavigationSetup _self;
  final $Res Function(ScreenNavigationSetup) _then;

  /// Create a copy of ScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? setupMode = null,
  }) {
    return _then(ScreenNavigationSetup(
      setupMode: null == setupMode
          ? _self.setupMode
          : setupMode // ignore: cast_nullable_to_non_nullable
              as SetupMode,
    ));
  }
}

// dart format on
