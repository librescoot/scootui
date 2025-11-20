// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddressState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AddressState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AddressState()';
  }
}

/// @nodoc
class $AddressStateCopyWith<$Res> {
  $AddressStateCopyWith(AddressState _, $Res Function(AddressState) __);
}

/// @nodoc

class AddressStateLoading implements AddressState {
  const AddressStateLoading(this.message);

  final String message;

  /// Create a copy of AddressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddressStateLoadingCopyWith<AddressStateLoading> get copyWith =>
      _$AddressStateLoadingCopyWithImpl<AddressStateLoading>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddressStateLoading &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AddressState.loading(message: $message)';
  }
}

/// @nodoc
abstract mixin class $AddressStateLoadingCopyWith<$Res>
    implements $AddressStateCopyWith<$Res> {
  factory $AddressStateLoadingCopyWith(
          AddressStateLoading value, $Res Function(AddressStateLoading) _then) =
      _$AddressStateLoadingCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AddressStateLoadingCopyWithImpl<$Res>
    implements $AddressStateLoadingCopyWith<$Res> {
  _$AddressStateLoadingCopyWithImpl(this._self, this._then);

  final AddressStateLoading _self;
  final $Res Function(AddressStateLoading) _then;

  /// Create a copy of AddressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(AddressStateLoading(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class AddressStateError implements AddressState {
  const AddressStateError(this.message);

  final String message;

  /// Create a copy of AddressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddressStateErrorCopyWith<AddressStateError> get copyWith =>
      _$AddressStateErrorCopyWithImpl<AddressStateError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddressStateError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AddressState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $AddressStateErrorCopyWith<$Res>
    implements $AddressStateCopyWith<$Res> {
  factory $AddressStateErrorCopyWith(
          AddressStateError value, $Res Function(AddressStateError) _then) =
      _$AddressStateErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AddressStateErrorCopyWithImpl<$Res>
    implements $AddressStateErrorCopyWith<$Res> {
  _$AddressStateErrorCopyWithImpl(this._self, this._then);

  final AddressStateError _self;
  final $Res Function(AddressStateError) _then;

  /// Create a copy of AddressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(AddressStateError(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class AddressStateLoaded implements AddressState {
  const AddressStateLoaded(final List<LatLng> addresses)
      : _addresses = addresses;

  final List<LatLng> _addresses;
  List<LatLng> get addresses {
    if (_addresses is EqualUnmodifiableListView) return _addresses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addresses);
  }

  /// Create a copy of AddressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddressStateLoadedCopyWith<AddressStateLoaded> get copyWith =>
      _$AddressStateLoadedCopyWithImpl<AddressStateLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddressStateLoaded &&
            const DeepCollectionEquality()
                .equals(other._addresses, _addresses));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_addresses));

  @override
  String toString() {
    return 'AddressState.loaded(addresses: $addresses)';
  }
}

/// @nodoc
abstract mixin class $AddressStateLoadedCopyWith<$Res>
    implements $AddressStateCopyWith<$Res> {
  factory $AddressStateLoadedCopyWith(
          AddressStateLoaded value, $Res Function(AddressStateLoaded) _then) =
      _$AddressStateLoadedCopyWithImpl;
  @useResult
  $Res call({List<LatLng> addresses});
}

/// @nodoc
class _$AddressStateLoadedCopyWithImpl<$Res>
    implements $AddressStateLoadedCopyWith<$Res> {
  _$AddressStateLoadedCopyWithImpl(this._self, this._then);

  final AddressStateLoaded _self;
  final $Res Function(AddressStateLoaded) _then;

  /// Create a copy of AddressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? addresses = null,
  }) {
    return _then(AddressStateLoaded(
      null == addresses
          ? _self._addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as List<LatLng>,
    ));
  }
}

// dart format on
