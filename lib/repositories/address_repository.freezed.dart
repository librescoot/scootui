// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Address {
  String get id;
  LatLng get coordinates;
  double get x;
  double get y;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddressCopyWith<Address> get copyWith =>
      _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Address &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.coordinates, coordinates) ||
                other.coordinates == coordinates) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, coordinates, x, y);

  @override
  String toString() {
    return 'Address(id: $id, coordinates: $coordinates, x: $x, y: $y)';
  }
}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) =
      _$AddressCopyWithImpl;
  @useResult
  $Res call({String id, LatLng coordinates, double x, double y});
}

/// @nodoc
class _$AddressCopyWithImpl<$Res> implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coordinates = null,
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _self.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as LatLng,
      x: null == x
          ? _self.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _self.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Address implements Address {
  const _Address(
      {required this.id,
      required this.coordinates,
      required this.x,
      required this.y});
  factory _Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  @override
  final String id;
  @override
  final LatLng coordinates;
  @override
  final double x;
  @override
  final double y;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddressCopyWith<_Address> get copyWith =>
      __$AddressCopyWithImpl<_Address>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AddressToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Address &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.coordinates, coordinates) ||
                other.coordinates == coordinates) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, coordinates, x, y);

  @override
  String toString() {
    return 'Address(id: $id, coordinates: $coordinates, x: $x, y: $y)';
  }
}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) =
      __$AddressCopyWithImpl;
  @override
  @useResult
  $Res call({String id, LatLng coordinates, double x, double y});
}

/// @nodoc
class __$AddressCopyWithImpl<$Res> implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? coordinates = null,
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_Address(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _self.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as LatLng,
      x: null == x
          ? _self.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _self.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$AddressDatabase {
  String get mapHash;
  Map<String, Address> get addresses;

  /// Create a copy of AddressDatabase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddressDatabaseCopyWith<AddressDatabase> get copyWith =>
      _$AddressDatabaseCopyWithImpl<AddressDatabase>(
          this as AddressDatabase, _$identity);

  /// Serializes this AddressDatabase to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddressDatabase &&
            (identical(other.mapHash, mapHash) || other.mapHash == mapHash) &&
            const DeepCollectionEquality().equals(other.addresses, addresses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, mapHash, const DeepCollectionEquality().hash(addresses));

  @override
  String toString() {
    return 'AddressDatabase(mapHash: $mapHash, addresses: $addresses)';
  }
}

/// @nodoc
abstract mixin class $AddressDatabaseCopyWith<$Res> {
  factory $AddressDatabaseCopyWith(
          AddressDatabase value, $Res Function(AddressDatabase) _then) =
      _$AddressDatabaseCopyWithImpl;
  @useResult
  $Res call({String mapHash, Map<String, Address> addresses});
}

/// @nodoc
class _$AddressDatabaseCopyWithImpl<$Res>
    implements $AddressDatabaseCopyWith<$Res> {
  _$AddressDatabaseCopyWithImpl(this._self, this._then);

  final AddressDatabase _self;
  final $Res Function(AddressDatabase) _then;

  /// Create a copy of AddressDatabase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mapHash = null,
    Object? addresses = null,
  }) {
    return _then(_self.copyWith(
      mapHash: null == mapHash
          ? _self.mapHash
          : mapHash // ignore: cast_nullable_to_non_nullable
              as String,
      addresses: null == addresses
          ? _self.addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as Map<String, Address>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AddressDatabase implements AddressDatabase {
  const _AddressDatabase(
      {required this.mapHash, required final Map<String, Address> addresses})
      : _addresses = addresses;
  factory _AddressDatabase.fromJson(Map<String, dynamic> json) =>
      _$AddressDatabaseFromJson(json);

  @override
  final String mapHash;
  final Map<String, Address> _addresses;
  @override
  Map<String, Address> get addresses {
    if (_addresses is EqualUnmodifiableMapView) return _addresses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_addresses);
  }

  /// Create a copy of AddressDatabase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddressDatabaseCopyWith<_AddressDatabase> get copyWith =>
      __$AddressDatabaseCopyWithImpl<_AddressDatabase>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AddressDatabaseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddressDatabase &&
            (identical(other.mapHash, mapHash) || other.mapHash == mapHash) &&
            const DeepCollectionEquality()
                .equals(other._addresses, _addresses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, mapHash, const DeepCollectionEquality().hash(_addresses));

  @override
  String toString() {
    return 'AddressDatabase(mapHash: $mapHash, addresses: $addresses)';
  }
}

/// @nodoc
abstract mixin class _$AddressDatabaseCopyWith<$Res>
    implements $AddressDatabaseCopyWith<$Res> {
  factory _$AddressDatabaseCopyWith(
          _AddressDatabase value, $Res Function(_AddressDatabase) _then) =
      __$AddressDatabaseCopyWithImpl;
  @override
  @useResult
  $Res call({String mapHash, Map<String, Address> addresses});
}

/// @nodoc
class __$AddressDatabaseCopyWithImpl<$Res>
    implements _$AddressDatabaseCopyWith<$Res> {
  __$AddressDatabaseCopyWithImpl(this._self, this._then);

  final _AddressDatabase _self;
  final $Res Function(_AddressDatabase) _then;

  /// Create a copy of AddressDatabase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? mapHash = null,
    Object? addresses = null,
  }) {
    return _then(_AddressDatabase(
      mapHash: null == mapHash
          ? _self.mapHash
          : mapHash // ignore: cast_nullable_to_non_nullable
              as String,
      addresses: null == addresses
          ? _self._addresses
          : addresses // ignore: cast_nullable_to_non_nullable
              as Map<String, Address>,
    ));
  }
}

/// @nodoc
mixin _$Addresses {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Addresses);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Addresses()';
  }
}

/// @nodoc
class $AddressesCopyWith<$Res> {
  $AddressesCopyWith(Addresses _, $Res Function(Addresses) __);
}

/// @nodoc

class Success implements Addresses {
  const Success(this.database);

  final AddressDatabase database;

  /// Create a copy of Addresses
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SuccessCopyWith<Success> get copyWith =>
      _$SuccessCopyWithImpl<Success>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Success &&
            (identical(other.database, database) ||
                other.database == database));
  }

  @override
  int get hashCode => Object.hash(runtimeType, database);

  @override
  String toString() {
    return 'Addresses.success(database: $database)';
  }
}

/// @nodoc
abstract mixin class $SuccessCopyWith<$Res>
    implements $AddressesCopyWith<$Res> {
  factory $SuccessCopyWith(Success value, $Res Function(Success) _then) =
      _$SuccessCopyWithImpl;
  @useResult
  $Res call({AddressDatabase database});

  $AddressDatabaseCopyWith<$Res> get database;
}

/// @nodoc
class _$SuccessCopyWithImpl<$Res> implements $SuccessCopyWith<$Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success _self;
  final $Res Function(Success) _then;

  /// Create a copy of Addresses
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? database = null,
  }) {
    return _then(Success(
      null == database
          ? _self.database
          : database // ignore: cast_nullable_to_non_nullable
              as AddressDatabase,
    ));
  }

  /// Create a copy of Addresses
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressDatabaseCopyWith<$Res> get database {
    return $AddressDatabaseCopyWith<$Res>(_self.database, (value) {
      return _then(_self.copyWith(database: value));
    });
  }
}

/// @nodoc

class NotFound implements Addresses {
  const NotFound();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NotFound);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Addresses.notFound()';
  }
}

/// @nodoc

class Error implements Addresses {
  const Error(this.message);

  final String message;

  /// Create a copy of Addresses
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ErrorCopyWith<Error> get copyWith =>
      _$ErrorCopyWithImpl<Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Error &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'Addresses.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $ErrorCopyWith<$Res> implements $AddressesCopyWith<$Res> {
  factory $ErrorCopyWith(Error value, $Res Function(Error) _then) =
      _$ErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$ErrorCopyWithImpl<$Res> implements $ErrorCopyWith<$Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error _self;
  final $Res Function(Error) _then;

  /// Create a copy of Addresses
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(Error(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
