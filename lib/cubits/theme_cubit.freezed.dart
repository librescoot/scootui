// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemeState {
  ThemeData get lightTheme;
  ThemeData get darkTheme;
  ThemeMode get themeMode;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ThemeStateCopyWith<ThemeState> get copyWith =>
      _$ThemeStateCopyWithImpl<ThemeState>(this as ThemeState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ThemeState &&
            (identical(other.lightTheme, lightTheme) ||
                other.lightTheme == lightTheme) &&
            (identical(other.darkTheme, darkTheme) ||
                other.darkTheme == darkTheme) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, lightTheme, darkTheme, themeMode);

  @override
  String toString() {
    return 'ThemeState(lightTheme: $lightTheme, darkTheme: $darkTheme, themeMode: $themeMode)';
  }
}

/// @nodoc
abstract mixin class $ThemeStateCopyWith<$Res> {
  factory $ThemeStateCopyWith(
          ThemeState value, $Res Function(ThemeState) _then) =
      _$ThemeStateCopyWithImpl;
  @useResult
  $Res call({ThemeData lightTheme, ThemeData darkTheme, ThemeMode themeMode});
}

/// @nodoc
class _$ThemeStateCopyWithImpl<$Res> implements $ThemeStateCopyWith<$Res> {
  _$ThemeStateCopyWithImpl(this._self, this._then);

  final ThemeState _self;
  final $Res Function(ThemeState) _then;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lightTheme = null,
    Object? darkTheme = null,
    Object? themeMode = null,
  }) {
    return _then(_self.copyWith(
      lightTheme: null == lightTheme
          ? _self.lightTheme
          : lightTheme // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      darkTheme: null == darkTheme
          ? _self.darkTheme
          : darkTheme // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ));
  }
}

/// @nodoc

class _ThemeState extends ThemeState {
  const _ThemeState(
      {required this.lightTheme,
      required this.darkTheme,
      this.themeMode = ThemeMode.dark})
      : super._();

  @override
  final ThemeData lightTheme;
  @override
  final ThemeData darkTheme;
  @override
  @JsonKey()
  final ThemeMode themeMode;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ThemeStateCopyWith<_ThemeState> get copyWith =>
      __$ThemeStateCopyWithImpl<_ThemeState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ThemeState &&
            (identical(other.lightTheme, lightTheme) ||
                other.lightTheme == lightTheme) &&
            (identical(other.darkTheme, darkTheme) ||
                other.darkTheme == darkTheme) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, lightTheme, darkTheme, themeMode);

  @override
  String toString() {
    return 'ThemeState(lightTheme: $lightTheme, darkTheme: $darkTheme, themeMode: $themeMode)';
  }
}

/// @nodoc
abstract mixin class _$ThemeStateCopyWith<$Res>
    implements $ThemeStateCopyWith<$Res> {
  factory _$ThemeStateCopyWith(
          _ThemeState value, $Res Function(_ThemeState) _then) =
      __$ThemeStateCopyWithImpl;
  @override
  @useResult
  $Res call({ThemeData lightTheme, ThemeData darkTheme, ThemeMode themeMode});
}

/// @nodoc
class __$ThemeStateCopyWithImpl<$Res> implements _$ThemeStateCopyWith<$Res> {
  __$ThemeStateCopyWithImpl(this._self, this._then);

  final _ThemeState _self;
  final $Res Function(_ThemeState) _then;

  /// Create a copy of ThemeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lightTheme = null,
    Object? darkTheme = null,
    Object? themeMode = null,
  }) {
    return _then(_ThemeState(
      lightTheme: null == lightTheme
          ? _self.lightTheme
          : lightTheme // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      darkTheme: null == darkTheme
          ? _self.darkTheme
          : darkTheme // ignore: cast_nullable_to_non_nullable
              as ThemeData,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ));
  }
}

// dart format on
