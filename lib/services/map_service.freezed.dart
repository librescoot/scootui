// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Request {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Request);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Request()';
  }
}

/// @nodoc
class $RequestCopyWith<$Res> {
  $RequestCopyWith(Request _, $Res Function(Request) __);
}

/// @nodoc

class _InitRequest implements Request {
  const _InitRequest();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _InitRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Request.init()';
  }
}

/// @nodoc

class _GetTileRequest implements Request {
  const _GetTileRequest(this.requestId, this.tile);

  final String requestId;
  final TileIdentity tile;

  /// Create a copy of Request
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GetTileRequestCopyWith<_GetTileRequest> get copyWith =>
      __$GetTileRequestCopyWithImpl<_GetTileRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GetTileRequest &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.tile, tile) || other.tile == tile));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestId, tile);

  @override
  String toString() {
    return 'Request.getTile(requestId: $requestId, tile: $tile)';
  }
}

/// @nodoc
abstract mixin class _$GetTileRequestCopyWith<$Res>
    implements $RequestCopyWith<$Res> {
  factory _$GetTileRequestCopyWith(
          _GetTileRequest value, $Res Function(_GetTileRequest) _then) =
      __$GetTileRequestCopyWithImpl;
  @useResult
  $Res call({String requestId, TileIdentity tile});
}

/// @nodoc
class __$GetTileRequestCopyWithImpl<$Res>
    implements _$GetTileRequestCopyWith<$Res> {
  __$GetTileRequestCopyWithImpl(this._self, this._then);

  final _GetTileRequest _self;
  final $Res Function(_GetTileRequest) _then;

  /// Create a copy of Request
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? tile = null,
  }) {
    return _then(_GetTileRequest(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      null == tile
          ? _self.tile
          : tile // ignore: cast_nullable_to_non_nullable
              as TileIdentity,
    ));
  }
}

/// @nodoc

class _FindAddressRequest implements Request {
  const _FindAddressRequest(this.id);

  final String id;

  /// Create a copy of Request
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FindAddressRequestCopyWith<_FindAddressRequest> get copyWith =>
      __$FindAddressRequestCopyWithImpl<_FindAddressRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FindAddressRequest &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'Request.findAddress(id: $id)';
  }
}

/// @nodoc
abstract mixin class _$FindAddressRequestCopyWith<$Res>
    implements $RequestCopyWith<$Res> {
  factory _$FindAddressRequestCopyWith(
          _FindAddressRequest value, $Res Function(_FindAddressRequest) _then) =
      __$FindAddressRequestCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$FindAddressRequestCopyWithImpl<$Res>
    implements _$FindAddressRequestCopyWith<$Res> {
  __$FindAddressRequestCopyWithImpl(this._self, this._then);

  final _FindAddressRequest _self;
  final $Res Function(_FindAddressRequest) _then;

  /// Create a copy of Request
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(_FindAddressRequest(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _ReloadMapRequest implements Request {
  const _ReloadMapRequest(this.requestId, this.newMapPath);

  final String requestId;
  final String newMapPath;

  /// Create a copy of Request
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReloadMapRequestCopyWith<_ReloadMapRequest> get copyWith =>
      __$ReloadMapRequestCopyWithImpl<_ReloadMapRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReloadMapRequest &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.newMapPath, newMapPath) ||
                other.newMapPath == newMapPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestId, newMapPath);

  @override
  String toString() {
    return 'Request.reloadMap(requestId: $requestId, newMapPath: $newMapPath)';
  }
}

/// @nodoc
abstract mixin class _$ReloadMapRequestCopyWith<$Res>
    implements $RequestCopyWith<$Res> {
  factory _$ReloadMapRequestCopyWith(
          _ReloadMapRequest value, $Res Function(_ReloadMapRequest) _then) =
      __$ReloadMapRequestCopyWithImpl;
  @useResult
  $Res call({String requestId, String newMapPath});
}

/// @nodoc
class __$ReloadMapRequestCopyWithImpl<$Res>
    implements _$ReloadMapRequestCopyWith<$Res> {
  __$ReloadMapRequestCopyWithImpl(this._self, this._then);

  final _ReloadMapRequest _self;
  final $Res Function(_ReloadMapRequest) _then;

  /// Create a copy of Request
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? newMapPath = null,
  }) {
    return _then(_ReloadMapRequest(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      null == newMapPath
          ? _self.newMapPath
          : newMapPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _DisposeRequest implements Request {
  const _DisposeRequest();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _DisposeRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Request.dispose()';
  }
}

/// @nodoc
mixin _$Response {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Response);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Response()';
  }
}

/// @nodoc
class $ResponseCopyWith<$Res> {
  $ResponseCopyWith(Response _, $Res Function(Response) __);
}

/// @nodoc

class _InitResponse implements Response {
  const _InitResponse(this.metadata);

  final MbTilesMetadata metadata;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InitResponseCopyWith<_InitResponse> get copyWith =>
      __$InitResponseCopyWithImpl<_InitResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InitResponse &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata);

  @override
  String toString() {
    return 'Response.init(metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$InitResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$InitResponseCopyWith(
          _InitResponse value, $Res Function(_InitResponse) _then) =
      __$InitResponseCopyWithImpl;
  @useResult
  $Res call({MbTilesMetadata metadata});
}

/// @nodoc
class __$InitResponseCopyWithImpl<$Res>
    implements _$InitResponseCopyWith<$Res> {
  __$InitResponseCopyWithImpl(this._self, this._then);

  final _InitResponse _self;
  final $Res Function(_InitResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? metadata = null,
  }) {
    return _then(_InitResponse(
      null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MbTilesMetadata,
    ));
  }
}

/// @nodoc

class _ErrorResponse implements Response {
  const _ErrorResponse(this.message);

  final String message;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ErrorResponseCopyWith<_ErrorResponse> get copyWith =>
      __$ErrorResponseCopyWithImpl<_ErrorResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ErrorResponse &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'Response.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$ErrorResponseCopyWith(
          _ErrorResponse value, $Res Function(_ErrorResponse) _then) =
      __$ErrorResponseCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$ErrorResponseCopyWithImpl<$Res>
    implements _$ErrorResponseCopyWith<$Res> {
  __$ErrorResponseCopyWithImpl(this._self, this._then);

  final _ErrorResponse _self;
  final $Res Function(_ErrorResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_ErrorResponse(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _TileResponse implements Response {
  const _TileResponse(this.requestId, this.tile);

  final String requestId;
  final Uint8List tile;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TileResponseCopyWith<_TileResponse> get copyWith =>
      __$TileResponseCopyWithImpl<_TileResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TileResponse &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            const DeepCollectionEquality().equals(other.tile, tile));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, requestId, const DeepCollectionEquality().hash(tile));

  @override
  String toString() {
    return 'Response.tile(requestId: $requestId, tile: $tile)';
  }
}

/// @nodoc
abstract mixin class _$TileResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$TileResponseCopyWith(
          _TileResponse value, $Res Function(_TileResponse) _then) =
      __$TileResponseCopyWithImpl;
  @useResult
  $Res call({String requestId, Uint8List tile});
}

/// @nodoc
class __$TileResponseCopyWithImpl<$Res>
    implements _$TileResponseCopyWith<$Res> {
  __$TileResponseCopyWithImpl(this._self, this._then);

  final _TileResponse _self;
  final $Res Function(_TileResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? tile = null,
  }) {
    return _then(_TileResponse(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      null == tile
          ? _self.tile
          : tile // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _TileErrorResponse implements Response {
  const _TileErrorResponse(this.requestId, this.message);

  final String requestId;
  final String message;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TileErrorResponseCopyWith<_TileErrorResponse> get copyWith =>
      __$TileErrorResponseCopyWithImpl<_TileErrorResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TileErrorResponse &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestId, message);

  @override
  String toString() {
    return 'Response.tileError(requestId: $requestId, message: $message)';
  }
}

/// @nodoc
abstract mixin class _$TileErrorResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$TileErrorResponseCopyWith(
          _TileErrorResponse value, $Res Function(_TileErrorResponse) _then) =
      __$TileErrorResponseCopyWithImpl;
  @useResult
  $Res call({String requestId, String message});
}

/// @nodoc
class __$TileErrorResponseCopyWithImpl<$Res>
    implements _$TileErrorResponseCopyWith<$Res> {
  __$TileErrorResponseCopyWithImpl(this._self, this._then);

  final _TileErrorResponse _self;
  final $Res Function(_TileErrorResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? message = null,
  }) {
    return _then(_TileErrorResponse(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _AddressResponse implements Response {
  const _AddressResponse(this.requestId, this.address);

  final String requestId;
  final Address? address;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddressResponseCopyWith<_AddressResponse> get copyWith =>
      __$AddressResponseCopyWithImpl<_AddressResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddressResponse &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.address, address) || other.address == address));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestId, address);

  @override
  String toString() {
    return 'Response.address(requestId: $requestId, address: $address)';
  }
}

/// @nodoc
abstract mixin class _$AddressResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$AddressResponseCopyWith(
          _AddressResponse value, $Res Function(_AddressResponse) _then) =
      __$AddressResponseCopyWithImpl;
  @useResult
  $Res call({String requestId, Address? address});

  $AddressCopyWith<$Res>? get address;
}

/// @nodoc
class __$AddressResponseCopyWithImpl<$Res>
    implements _$AddressResponseCopyWith<$Res> {
  __$AddressResponseCopyWithImpl(this._self, this._then);

  final _AddressResponse _self;
  final $Res Function(_AddressResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? address = freezed,
  }) {
    return _then(_AddressResponse(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address?,
    ));
  }

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res>? get address {
    if (_self.address == null) {
      return null;
    }

    return $AddressCopyWith<$Res>(_self.address!, (value) {
      return _then(_self.copyWith(address: value));
    });
  }
}

/// @nodoc

class _UpdateSuccessResponse implements Response {
  const _UpdateSuccessResponse(this.requestId);

  final String requestId;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateSuccessResponseCopyWith<_UpdateSuccessResponse> get copyWith =>
      __$UpdateSuccessResponseCopyWithImpl<_UpdateSuccessResponse>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateSuccessResponse &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestId);

  @override
  String toString() {
    return 'Response.updateSuccess(requestId: $requestId)';
  }
}

/// @nodoc
abstract mixin class _$UpdateSuccessResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$UpdateSuccessResponseCopyWith(_UpdateSuccessResponse value,
          $Res Function(_UpdateSuccessResponse) _then) =
      __$UpdateSuccessResponseCopyWithImpl;
  @useResult
  $Res call({String requestId});
}

/// @nodoc
class __$UpdateSuccessResponseCopyWithImpl<$Res>
    implements _$UpdateSuccessResponseCopyWith<$Res> {
  __$UpdateSuccessResponseCopyWithImpl(this._self, this._then);

  final _UpdateSuccessResponse _self;
  final $Res Function(_UpdateSuccessResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
  }) {
    return _then(_UpdateSuccessResponse(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _UpdateErrorResponse implements Response {
  const _UpdateErrorResponse(this.requestId, this.message);

  final String requestId;
  final String message;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateErrorResponseCopyWith<_UpdateErrorResponse> get copyWith =>
      __$UpdateErrorResponseCopyWithImpl<_UpdateErrorResponse>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateErrorResponse &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestId, message);

  @override
  String toString() {
    return 'Response.updateError(requestId: $requestId, message: $message)';
  }
}

/// @nodoc
abstract mixin class _$UpdateErrorResponseCopyWith<$Res>
    implements $ResponseCopyWith<$Res> {
  factory _$UpdateErrorResponseCopyWith(_UpdateErrorResponse value,
          $Res Function(_UpdateErrorResponse) _then) =
      __$UpdateErrorResponseCopyWithImpl;
  @useResult
  $Res call({String requestId, String message});
}

/// @nodoc
class __$UpdateErrorResponseCopyWithImpl<$Res>
    implements _$UpdateErrorResponseCopyWith<$Res> {
  __$UpdateErrorResponseCopyWithImpl(this._self, this._then);

  final _UpdateErrorResponse _self;
  final $Res Function(_UpdateErrorResponse) _then;

  /// Create a copy of Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? message = null,
  }) {
    return _then(_UpdateErrorResponse(
      null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
