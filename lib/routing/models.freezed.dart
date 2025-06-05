// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
RouteInstruction _$RouteInstructionFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'keep':
      return Keep.fromJson(json);
    case 'turn':
      return Turn.fromJson(json);
    case 'exit':
      return Exit.fromJson(json);
    case 'roundabout':
      return Roundabout.fromJson(json);
    case 'other':
      return Other.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'RouteInstruction',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$RouteInstruction {
  double get distance; // required Duration duration,
  LatLng get location;
  int get originalShapeIndex;
  String? get streetName;
  String? get instructionText;
  String? get postInstructionText;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<RouteInstruction> get copyWith =>
      _$RouteInstructionCopyWithImpl<RouteInstruction>(
          this as RouteInstruction, _$identity);

  /// Serializes this RouteInstruction to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RouteInstruction &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.originalShapeIndex, originalShapeIndex) ||
                other.originalShapeIndex == originalShapeIndex) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.postInstructionText, postInstructionText) ||
                other.postInstructionText == postInstructionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, distance, location,
      originalShapeIndex, streetName, instructionText, postInstructionText);

  @override
  String toString() {
    return 'RouteInstruction(distance: $distance, location: $location, originalShapeIndex: $originalShapeIndex, streetName: $streetName, instructionText: $instructionText, postInstructionText: $postInstructionText)';
  }
}

/// @nodoc
abstract mixin class $RouteInstructionCopyWith<$Res> {
  factory $RouteInstructionCopyWith(
          RouteInstruction value, $Res Function(RouteInstruction) _then) =
      _$RouteInstructionCopyWithImpl;
  @useResult
  $Res call(
      {double distance,
      LatLng location,
      int originalShapeIndex,
      String? streetName,
      String? instructionText,
      String? postInstructionText});
}

/// @nodoc
class _$RouteInstructionCopyWithImpl<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  _$RouteInstructionCopyWithImpl(this._self, this._then);

  final RouteInstruction _self;
  final $Res Function(RouteInstruction) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distance = null,
    Object? location = null,
    Object? originalShapeIndex = null,
    Object? streetName = freezed,
    Object? instructionText = freezed,
    Object? postInstructionText = freezed,
  }) {
    return _then(_self.copyWith(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      originalShapeIndex: null == originalShapeIndex
          ? _self.originalShapeIndex
          : originalShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      streetName: freezed == streetName
          ? _self.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      instructionText: freezed == instructionText
          ? _self.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      postInstructionText: freezed == postInstructionText
          ? _self.postInstructionText
          : postInstructionText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class Keep extends RouteInstruction {
  const Keep(
      {required this.distance,
      required this.direction,
      required this.location,
      required this.originalShapeIndex,
      this.streetName,
      this.instructionText,
      this.postInstructionText,
      final String? $type})
      : $type = $type ?? 'keep',
        super._();
  factory Keep.fromJson(Map<String, dynamic> json) => _$KeepFromJson(json);

  @override
  final double distance;
  final KeepDirection direction;
// required Duration duration,
  @override
  final LatLng location;
  @override
  final int originalShapeIndex;
  @override
  final String? streetName;
  @override
  final String? instructionText;
  @override
  final String? postInstructionText;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KeepCopyWith<Keep> get copyWith =>
      _$KeepCopyWithImpl<Keep>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$KeepToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Keep &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.originalShapeIndex, originalShapeIndex) ||
                other.originalShapeIndex == originalShapeIndex) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.postInstructionText, postInstructionText) ||
                other.postInstructionText == postInstructionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, distance, direction, location,
      originalShapeIndex, streetName, instructionText, postInstructionText);

  @override
  String toString() {
    return 'RouteInstruction.keep(distance: $distance, direction: $direction, location: $location, originalShapeIndex: $originalShapeIndex, streetName: $streetName, instructionText: $instructionText, postInstructionText: $postInstructionText)';
  }
}

/// @nodoc
abstract mixin class $KeepCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $KeepCopyWith(Keep value, $Res Function(Keep) _then) =
      _$KeepCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double distance,
      KeepDirection direction,
      LatLng location,
      int originalShapeIndex,
      String? streetName,
      String? instructionText,
      String? postInstructionText});
}

/// @nodoc
class _$KeepCopyWithImpl<$Res> implements $KeepCopyWith<$Res> {
  _$KeepCopyWithImpl(this._self, this._then);

  final Keep _self;
  final $Res Function(Keep) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? direction = null,
    Object? location = null,
    Object? originalShapeIndex = null,
    Object? streetName = freezed,
    Object? instructionText = freezed,
    Object? postInstructionText = freezed,
  }) {
    return _then(Keep(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      direction: null == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as KeepDirection,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      originalShapeIndex: null == originalShapeIndex
          ? _self.originalShapeIndex
          : originalShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      streetName: freezed == streetName
          ? _self.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      instructionText: freezed == instructionText
          ? _self.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      postInstructionText: freezed == postInstructionText
          ? _self.postInstructionText
          : postInstructionText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class Turn extends RouteInstruction {
  const Turn(
      {required this.distance,
      required this.direction,
      required this.location,
      required this.originalShapeIndex,
      this.streetName,
      this.instructionText,
      this.postInstructionText,
      final String? $type})
      : $type = $type ?? 'turn',
        super._();
  factory Turn.fromJson(Map<String, dynamic> json) => _$TurnFromJson(json);

  @override
  final double distance;
  final TurnDirection direction;
// required Duration duration,
  @override
  final LatLng location;
  @override
  final int originalShapeIndex;
  @override
  final String? streetName;
  @override
  final String? instructionText;
  @override
  final String? postInstructionText;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TurnCopyWith<Turn> get copyWith =>
      _$TurnCopyWithImpl<Turn>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TurnToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Turn &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.originalShapeIndex, originalShapeIndex) ||
                other.originalShapeIndex == originalShapeIndex) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.postInstructionText, postInstructionText) ||
                other.postInstructionText == postInstructionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, distance, direction, location,
      originalShapeIndex, streetName, instructionText, postInstructionText);

  @override
  String toString() {
    return 'RouteInstruction.turn(distance: $distance, direction: $direction, location: $location, originalShapeIndex: $originalShapeIndex, streetName: $streetName, instructionText: $instructionText, postInstructionText: $postInstructionText)';
  }
}

/// @nodoc
abstract mixin class $TurnCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $TurnCopyWith(Turn value, $Res Function(Turn) _then) =
      _$TurnCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double distance,
      TurnDirection direction,
      LatLng location,
      int originalShapeIndex,
      String? streetName,
      String? instructionText,
      String? postInstructionText});
}

/// @nodoc
class _$TurnCopyWithImpl<$Res> implements $TurnCopyWith<$Res> {
  _$TurnCopyWithImpl(this._self, this._then);

  final Turn _self;
  final $Res Function(Turn) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? direction = null,
    Object? location = null,
    Object? originalShapeIndex = null,
    Object? streetName = freezed,
    Object? instructionText = freezed,
    Object? postInstructionText = freezed,
  }) {
    return _then(Turn(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      direction: null == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as TurnDirection,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      originalShapeIndex: null == originalShapeIndex
          ? _self.originalShapeIndex
          : originalShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      streetName: freezed == streetName
          ? _self.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      instructionText: freezed == instructionText
          ? _self.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      postInstructionText: freezed == postInstructionText
          ? _self.postInstructionText
          : postInstructionText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class Exit extends RouteInstruction {
  const Exit(
      {required this.distance,
      required this.side,
      required this.location,
      required this.originalShapeIndex,
      this.streetName,
      this.instructionText,
      this.postInstructionText,
      final String? $type})
      : $type = $type ?? 'exit',
        super._();
  factory Exit.fromJson(Map<String, dynamic> json) => _$ExitFromJson(json);

  @override
  final double distance;
  final ExitSide side;
  @override
  final LatLng location;
  @override
  final int originalShapeIndex;
  @override
  final String? streetName;
  @override
  final String? instructionText;
  @override
  final String? postInstructionText;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExitCopyWith<Exit> get copyWith =>
      _$ExitCopyWithImpl<Exit>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExitToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Exit &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.originalShapeIndex, originalShapeIndex) ||
                other.originalShapeIndex == originalShapeIndex) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.postInstructionText, postInstructionText) ||
                other.postInstructionText == postInstructionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, distance, side, location,
      originalShapeIndex, streetName, instructionText, postInstructionText);

  @override
  String toString() {
    return 'RouteInstruction.exit(distance: $distance, side: $side, location: $location, originalShapeIndex: $originalShapeIndex, streetName: $streetName, instructionText: $instructionText, postInstructionText: $postInstructionText)';
  }
}

/// @nodoc
abstract mixin class $ExitCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $ExitCopyWith(Exit value, $Res Function(Exit) _then) =
      _$ExitCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double distance,
      ExitSide side,
      LatLng location,
      int originalShapeIndex,
      String? streetName,
      String? instructionText,
      String? postInstructionText});
}

/// @nodoc
class _$ExitCopyWithImpl<$Res> implements $ExitCopyWith<$Res> {
  _$ExitCopyWithImpl(this._self, this._then);

  final Exit _self;
  final $Res Function(Exit) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? side = null,
    Object? location = null,
    Object? originalShapeIndex = null,
    Object? streetName = freezed,
    Object? instructionText = freezed,
    Object? postInstructionText = freezed,
  }) {
    return _then(Exit(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      side: null == side
          ? _self.side
          : side // ignore: cast_nullable_to_non_nullable
              as ExitSide,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      originalShapeIndex: null == originalShapeIndex
          ? _self.originalShapeIndex
          : originalShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      streetName: freezed == streetName
          ? _self.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      instructionText: freezed == instructionText
          ? _self.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      postInstructionText: freezed == postInstructionText
          ? _self.postInstructionText
          : postInstructionText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class Roundabout extends RouteInstruction {
  const Roundabout(
      {required this.distance,
      required this.side,
      required this.exitNumber,
      required this.location,
      required this.originalShapeIndex,
      this.streetName,
      this.instructionText,
      this.postInstructionText,
      final String? $type})
      : $type = $type ?? 'roundabout',
        super._();
  factory Roundabout.fromJson(Map<String, dynamic> json) =>
      _$RoundaboutFromJson(json);

  @override
  final double distance;
  final RoundaboutSide side;
  final int exitNumber;
  @override
  final LatLng location;
  @override
  final int originalShapeIndex;
  @override
  final String? streetName;
  @override
  final String? instructionText;
  @override
  final String? postInstructionText;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoundaboutCopyWith<Roundabout> get copyWith =>
      _$RoundaboutCopyWithImpl<Roundabout>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RoundaboutToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Roundabout &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.exitNumber, exitNumber) ||
                other.exitNumber == exitNumber) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.originalShapeIndex, originalShapeIndex) ||
                other.originalShapeIndex == originalShapeIndex) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.postInstructionText, postInstructionText) ||
                other.postInstructionText == postInstructionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      distance,
      side,
      exitNumber,
      location,
      originalShapeIndex,
      streetName,
      instructionText,
      postInstructionText);

  @override
  String toString() {
    return 'RouteInstruction.roundabout(distance: $distance, side: $side, exitNumber: $exitNumber, location: $location, originalShapeIndex: $originalShapeIndex, streetName: $streetName, instructionText: $instructionText, postInstructionText: $postInstructionText)';
  }
}

/// @nodoc
abstract mixin class $RoundaboutCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $RoundaboutCopyWith(
          Roundabout value, $Res Function(Roundabout) _then) =
      _$RoundaboutCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double distance,
      RoundaboutSide side,
      int exitNumber,
      LatLng location,
      int originalShapeIndex,
      String? streetName,
      String? instructionText,
      String? postInstructionText});
}

/// @nodoc
class _$RoundaboutCopyWithImpl<$Res> implements $RoundaboutCopyWith<$Res> {
  _$RoundaboutCopyWithImpl(this._self, this._then);

  final Roundabout _self;
  final $Res Function(Roundabout) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? side = null,
    Object? exitNumber = null,
    Object? location = null,
    Object? originalShapeIndex = null,
    Object? streetName = freezed,
    Object? instructionText = freezed,
    Object? postInstructionText = freezed,
  }) {
    return _then(Roundabout(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      side: null == side
          ? _self.side
          : side // ignore: cast_nullable_to_non_nullable
              as RoundaboutSide,
      exitNumber: null == exitNumber
          ? _self.exitNumber
          : exitNumber // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      originalShapeIndex: null == originalShapeIndex
          ? _self.originalShapeIndex
          : originalShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      streetName: freezed == streetName
          ? _self.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      instructionText: freezed == instructionText
          ? _self.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      postInstructionText: freezed == postInstructionText
          ? _self.postInstructionText
          : postInstructionText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class Other extends RouteInstruction {
  const Other(
      {required this.distance,
      required this.location,
      required this.originalShapeIndex,
      this.streetName,
      this.instructionText,
      this.postInstructionText,
      final String? $type})
      : $type = $type ?? 'other',
        super._();
  factory Other.fromJson(Map<String, dynamic> json) => _$OtherFromJson(json);

  @override
  final double distance;
  @override
  final LatLng location;
  @override
  final int originalShapeIndex;
  @override
  final String? streetName;
  @override
  final String? instructionText;
  @override
  final String? postInstructionText;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OtherCopyWith<Other> get copyWith =>
      _$OtherCopyWithImpl<Other>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OtherToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Other &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.originalShapeIndex, originalShapeIndex) ||
                other.originalShapeIndex == originalShapeIndex) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.postInstructionText, postInstructionText) ||
                other.postInstructionText == postInstructionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, distance, location,
      originalShapeIndex, streetName, instructionText, postInstructionText);

  @override
  String toString() {
    return 'RouteInstruction.other(distance: $distance, location: $location, originalShapeIndex: $originalShapeIndex, streetName: $streetName, instructionText: $instructionText, postInstructionText: $postInstructionText)';
  }
}

/// @nodoc
abstract mixin class $OtherCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $OtherCopyWith(Other value, $Res Function(Other) _then) =
      _$OtherCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double distance,
      LatLng location,
      int originalShapeIndex,
      String? streetName,
      String? instructionText,
      String? postInstructionText});
}

/// @nodoc
class _$OtherCopyWithImpl<$Res> implements $OtherCopyWith<$Res> {
  _$OtherCopyWithImpl(this._self, this._then);

  final Other _self;
  final $Res Function(Other) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? location = null,
    Object? originalShapeIndex = null,
    Object? streetName = freezed,
    Object? instructionText = freezed,
    Object? postInstructionText = freezed,
  }) {
    return _then(Other(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      originalShapeIndex: null == originalShapeIndex
          ? _self.originalShapeIndex
          : originalShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      streetName: freezed == streetName
          ? _self.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      instructionText: freezed == instructionText
          ? _self.instructionText
          : instructionText // ignore: cast_nullable_to_non_nullable
              as String?,
      postInstructionText: freezed == postInstructionText
          ? _self.postInstructionText
          : postInstructionText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Route {
  List<RouteInstruction> get instructions;
  List<LatLng> get waypoints;
  double get distance;
  Duration get duration;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RouteCopyWith<Route> get copyWith =>
      _$RouteCopyWithImpl<Route>(this as Route, _$identity);

  /// Serializes this Route to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Route &&
            const DeepCollectionEquality()
                .equals(other.instructions, instructions) &&
            const DeepCollectionEquality().equals(other.waypoints, waypoints) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(instructions),
      const DeepCollectionEquality().hash(waypoints),
      distance,
      duration);

  @override
  String toString() {
    return 'Route(instructions: $instructions, waypoints: $waypoints, distance: $distance, duration: $duration)';
  }
}

/// @nodoc
abstract mixin class $RouteCopyWith<$Res> {
  factory $RouteCopyWith(Route value, $Res Function(Route) _then) =
      _$RouteCopyWithImpl;
  @useResult
  $Res call(
      {List<RouteInstruction> instructions,
      List<LatLng> waypoints,
      double distance,
      Duration duration});
}

/// @nodoc
class _$RouteCopyWithImpl<$Res> implements $RouteCopyWith<$Res> {
  _$RouteCopyWithImpl(this._self, this._then);

  final Route _self;
  final $Res Function(Route) _then;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instructions = null,
    Object? waypoints = null,
    Object? distance = null,
    Object? duration = null,
  }) {
    return _then(_self.copyWith(
      instructions: null == instructions
          ? _self.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<RouteInstruction>,
      waypoints: null == waypoints
          ? _self.waypoints
          : waypoints // ignore: cast_nullable_to_non_nullable
              as List<LatLng>,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Route implements Route {
  const _Route(
      {required final List<RouteInstruction> instructions,
      required final List<LatLng> waypoints,
      required this.distance,
      required this.duration})
      : _instructions = instructions,
        _waypoints = waypoints;
  factory _Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);

  final List<RouteInstruction> _instructions;
  @override
  List<RouteInstruction> get instructions {
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instructions);
  }

  final List<LatLng> _waypoints;
  @override
  List<LatLng> get waypoints {
    if (_waypoints is EqualUnmodifiableListView) return _waypoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_waypoints);
  }

  @override
  final double distance;
  @override
  final Duration duration;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RouteCopyWith<_Route> get copyWith =>
      __$RouteCopyWithImpl<_Route>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RouteToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Route &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            const DeepCollectionEquality()
                .equals(other._waypoints, _waypoints) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_instructions),
      const DeepCollectionEquality().hash(_waypoints),
      distance,
      duration);

  @override
  String toString() {
    return 'Route(instructions: $instructions, waypoints: $waypoints, distance: $distance, duration: $duration)';
  }
}

/// @nodoc
abstract mixin class _$RouteCopyWith<$Res> implements $RouteCopyWith<$Res> {
  factory _$RouteCopyWith(_Route value, $Res Function(_Route) _then) =
      __$RouteCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<RouteInstruction> instructions,
      List<LatLng> waypoints,
      double distance,
      Duration duration});
}

/// @nodoc
class __$RouteCopyWithImpl<$Res> implements _$RouteCopyWith<$Res> {
  __$RouteCopyWithImpl(this._self, this._then);

  final _Route _self;
  final $Res Function(_Route) _then;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? instructions = null,
    Object? waypoints = null,
    Object? distance = null,
    Object? duration = null,
  }) {
    return _then(_Route(
      instructions: null == instructions
          ? _self._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<RouteInstruction>,
      waypoints: null == waypoints
          ? _self._waypoints
          : waypoints // ignore: cast_nullable_to_non_nullable
              as List<LatLng>,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

// dart format on
