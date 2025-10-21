// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'valhalla_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ValhallaResponse {
  Trip get trip;
  String? get id;
  String? get units;
  String? get language;

  /// Create a copy of ValhallaResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValhallaResponseCopyWith<ValhallaResponse> get copyWith =>
      _$ValhallaResponseCopyWithImpl<ValhallaResponse>(
          this as ValhallaResponse, _$identity);

  /// Serializes this ValhallaResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValhallaResponse &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, trip, id, units, language);

  @override
  String toString() {
    return 'ValhallaResponse(trip: $trip, id: $id, units: $units, language: $language)';
  }
}

/// @nodoc
abstract mixin class $ValhallaResponseCopyWith<$Res> {
  factory $ValhallaResponseCopyWith(
          ValhallaResponse value, $Res Function(ValhallaResponse) _then) =
      _$ValhallaResponseCopyWithImpl;
  @useResult
  $Res call({Trip trip, String? id, String? units, String? language});

  $TripCopyWith<$Res> get trip;
}

/// @nodoc
class _$ValhallaResponseCopyWithImpl<$Res>
    implements $ValhallaResponseCopyWith<$Res> {
  _$ValhallaResponseCopyWithImpl(this._self, this._then);

  final ValhallaResponse _self;
  final $Res Function(ValhallaResponse) _then;

  /// Create a copy of ValhallaResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trip = null,
    Object? id = freezed,
    Object? units = freezed,
    Object? language = freezed,
  }) {
    return _then(_self.copyWith(
      trip: null == trip
          ? _self.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as Trip,
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      units: freezed == units
          ? _self.units
          : units // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ValhallaResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripCopyWith<$Res> get trip {
    return $TripCopyWith<$Res>(_self.trip, (value) {
      return _then(_self.copyWith(trip: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _ValhallaResponse implements ValhallaResponse {
  const _ValhallaResponse(
      {required this.trip, this.id, this.units, this.language});
  factory _ValhallaResponse.fromJson(Map<String, dynamic> json) =>
      _$ValhallaResponseFromJson(json);

  @override
  final Trip trip;
  @override
  final String? id;
  @override
  final String? units;
  @override
  final String? language;

  /// Create a copy of ValhallaResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ValhallaResponseCopyWith<_ValhallaResponse> get copyWith =>
      __$ValhallaResponseCopyWithImpl<_ValhallaResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ValhallaResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ValhallaResponse &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, trip, id, units, language);

  @override
  String toString() {
    return 'ValhallaResponse(trip: $trip, id: $id, units: $units, language: $language)';
  }
}

/// @nodoc
abstract mixin class _$ValhallaResponseCopyWith<$Res>
    implements $ValhallaResponseCopyWith<$Res> {
  factory _$ValhallaResponseCopyWith(
          _ValhallaResponse value, $Res Function(_ValhallaResponse) _then) =
      __$ValhallaResponseCopyWithImpl;
  @override
  @useResult
  $Res call({Trip trip, String? id, String? units, String? language});

  @override
  $TripCopyWith<$Res> get trip;
}

/// @nodoc
class __$ValhallaResponseCopyWithImpl<$Res>
    implements _$ValhallaResponseCopyWith<$Res> {
  __$ValhallaResponseCopyWithImpl(this._self, this._then);

  final _ValhallaResponse _self;
  final $Res Function(_ValhallaResponse) _then;

  /// Create a copy of ValhallaResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? trip = null,
    Object? id = freezed,
    Object? units = freezed,
    Object? language = freezed,
  }) {
    return _then(_ValhallaResponse(
      trip: null == trip
          ? _self.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as Trip,
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      units: freezed == units
          ? _self.units
          : units // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ValhallaResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripCopyWith<$Res> get trip {
    return $TripCopyWith<$Res>(_self.trip, (value) {
      return _then(_self.copyWith(trip: value));
    });
  }
}

/// @nodoc
mixin _$Trip {
  List<Leg> get legs;
  Summary get summary;
  List<ValhallaTripLocation> get locations;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TripCopyWith<Trip> get copyWith =>
      _$TripCopyWithImpl<Trip>(this as Trip, _$identity);

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Trip &&
            const DeepCollectionEquality().equals(other.legs, legs) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other.locations, locations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(legs),
      summary,
      const DeepCollectionEquality().hash(locations));

  @override
  String toString() {
    return 'Trip(legs: $legs, summary: $summary, locations: $locations)';
  }
}

/// @nodoc
abstract mixin class $TripCopyWith<$Res> {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) =
      _$TripCopyWithImpl;
  @useResult
  $Res call(
      {List<Leg> legs, Summary summary, List<ValhallaTripLocation> locations});

  $SummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$TripCopyWithImpl<$Res> implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? legs = null,
    Object? summary = null,
    Object? locations = null,
  }) {
    return _then(_self.copyWith(
      legs: null == legs
          ? _self.legs
          : legs // ignore: cast_nullable_to_non_nullable
              as List<Leg>,
      summary: null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as Summary,
      locations: null == locations
          ? _self.locations
          : locations // ignore: cast_nullable_to_non_nullable
              as List<ValhallaTripLocation>,
    ));
  }

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryCopyWith<$Res> get summary {
    return $SummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _Trip implements Trip {
  const _Trip(
      {required final List<Leg> legs,
      required this.summary,
      required final List<ValhallaTripLocation> locations})
      : _legs = legs,
        _locations = locations;
  factory _Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

  final List<Leg> _legs;
  @override
  List<Leg> get legs {
    if (_legs is EqualUnmodifiableListView) return _legs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_legs);
  }

  @override
  final Summary summary;
  final List<ValhallaTripLocation> _locations;
  @override
  List<ValhallaTripLocation> get locations {
    if (_locations is EqualUnmodifiableListView) return _locations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_locations);
  }

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TripCopyWith<_Trip> get copyWith =>
      __$TripCopyWithImpl<_Trip>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TripToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Trip &&
            const DeepCollectionEquality().equals(other._legs, _legs) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._locations, _locations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_legs),
      summary,
      const DeepCollectionEquality().hash(_locations));

  @override
  String toString() {
    return 'Trip(legs: $legs, summary: $summary, locations: $locations)';
  }
}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) =
      __$TripCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<Leg> legs, Summary summary, List<ValhallaTripLocation> locations});

  @override
  $SummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$TripCopyWithImpl<$Res> implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? legs = null,
    Object? summary = null,
    Object? locations = null,
  }) {
    return _then(_Trip(
      legs: null == legs
          ? _self._legs
          : legs // ignore: cast_nullable_to_non_nullable
              as List<Leg>,
      summary: null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as Summary,
      locations: null == locations
          ? _self._locations
          : locations // ignore: cast_nullable_to_non_nullable
              as List<ValhallaTripLocation>,
    ));
  }

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryCopyWith<$Res> get summary {
    return $SummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc
mixin _$Leg {
  List<Maneuver> get maneuvers;
  Summary get summary;
  String get shape;

  /// Create a copy of Leg
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LegCopyWith<Leg> get copyWith =>
      _$LegCopyWithImpl<Leg>(this as Leg, _$identity);

  /// Serializes this Leg to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Leg &&
            const DeepCollectionEquality().equals(other.maneuvers, maneuvers) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.shape, shape) || other.shape == shape));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(maneuvers), summary, shape);

  @override
  String toString() {
    return 'Leg(maneuvers: $maneuvers, summary: $summary, shape: $shape)';
  }
}

/// @nodoc
abstract mixin class $LegCopyWith<$Res> {
  factory $LegCopyWith(Leg value, $Res Function(Leg) _then) = _$LegCopyWithImpl;
  @useResult
  $Res call({List<Maneuver> maneuvers, Summary summary, String shape});

  $SummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$LegCopyWithImpl<$Res> implements $LegCopyWith<$Res> {
  _$LegCopyWithImpl(this._self, this._then);

  final Leg _self;
  final $Res Function(Leg) _then;

  /// Create a copy of Leg
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maneuvers = null,
    Object? summary = null,
    Object? shape = null,
  }) {
    return _then(_self.copyWith(
      maneuvers: null == maneuvers
          ? _self.maneuvers
          : maneuvers // ignore: cast_nullable_to_non_nullable
              as List<Maneuver>,
      summary: null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as Summary,
      shape: null == shape
          ? _self.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of Leg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryCopyWith<$Res> get summary {
    return $SummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _Leg implements Leg {
  const _Leg(
      {required final List<Maneuver> maneuvers,
      required this.summary,
      required this.shape})
      : _maneuvers = maneuvers;
  factory _Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);

  final List<Maneuver> _maneuvers;
  @override
  List<Maneuver> get maneuvers {
    if (_maneuvers is EqualUnmodifiableListView) return _maneuvers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_maneuvers);
  }

  @override
  final Summary summary;
  @override
  final String shape;

  /// Create a copy of Leg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LegCopyWith<_Leg> get copyWith =>
      __$LegCopyWithImpl<_Leg>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LegToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Leg &&
            const DeepCollectionEquality()
                .equals(other._maneuvers, _maneuvers) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.shape, shape) || other.shape == shape));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_maneuvers), summary, shape);

  @override
  String toString() {
    return 'Leg(maneuvers: $maneuvers, summary: $summary, shape: $shape)';
  }
}

/// @nodoc
abstract mixin class _$LegCopyWith<$Res> implements $LegCopyWith<$Res> {
  factory _$LegCopyWith(_Leg value, $Res Function(_Leg) _then) =
      __$LegCopyWithImpl;
  @override
  @useResult
  $Res call({List<Maneuver> maneuvers, Summary summary, String shape});

  @override
  $SummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$LegCopyWithImpl<$Res> implements _$LegCopyWith<$Res> {
  __$LegCopyWithImpl(this._self, this._then);

  final _Leg _self;
  final $Res Function(_Leg) _then;

  /// Create a copy of Leg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? maneuvers = null,
    Object? summary = null,
    Object? shape = null,
  }) {
    return _then(_Leg(
      maneuvers: null == maneuvers
          ? _self._maneuvers
          : maneuvers // ignore: cast_nullable_to_non_nullable
              as List<Maneuver>,
      summary: null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as Summary,
      shape: null == shape
          ? _self.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of Leg
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryCopyWith<$Res> get summary {
    return $SummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc
mixin _$Maneuver {
  int get type;
  String get instruction;
  double get length;
  double get time;
  @JsonKey(name: 'begin_shape_index')
  int get beginShapeIndex;
  @JsonKey(name: 'end_shape_index')
  int get endShapeIndex;
  @JsonKey(name: 'travel_mode')
  String get travelMode;
  @JsonKey(name: 'street_names')
  List<String>? get streetNames;
  @JsonKey(name: 'begin_street_names')
  List<String>? get beginStreetNames;
  @JsonKey(name: 'verbal_transition_alert_instruction')
  String? get verbalTransitionAlertInstruction;
  @JsonKey(name: 'verbal_pre_transition_instruction')
  String? get verbalPreTransitionInstruction;
  @JsonKey(name: 'verbal_post_transition_instruction')
  String? get verbalPostTransitionInstruction;
  @JsonKey(name: 'verbal_succinct_transition_instruction')
  String? get verbalSuccinctTransitionInstruction;
  @JsonKey(name: 'verbal_multi_cue')
  bool get verbalMultiCue;
  @JsonKey(name: 'roundabout_exit_count')
  int? get roundaboutExitCount;
  @JsonKey(name: 'depart_instruction')
  String? get departInstruction;
  @JsonKey(name: 'verbal_depart_instruction')
  String? get verbalDepartInstruction;
  @JsonKey(name: 'arrive_instruction')
  String? get arriveInstruction;
  @JsonKey(name: 'verbal_arrive_instruction')
  String? get verbalArriveInstruction;
  bool get toll;
  bool get gate;
  bool get ferry;
  List<ValhallaLane>? get lanes;
  @JsonKey(name: 'bearing_before')
  double? get bearingBefore;
  @JsonKey(name: 'bearing_after')
  double? get bearingAfter;
  @JsonKey(name: 'bss_maneuver_type')
  String? get bssManeuverType;

  /// Create a copy of Maneuver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ManeuverCopyWith<Maneuver> get copyWith =>
      _$ManeuverCopyWithImpl<Maneuver>(this as Maneuver, _$identity);

  /// Serializes this Maneuver to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Maneuver &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.beginShapeIndex, beginShapeIndex) ||
                other.beginShapeIndex == beginShapeIndex) &&
            (identical(other.endShapeIndex, endShapeIndex) ||
                other.endShapeIndex == endShapeIndex) &&
            (identical(other.travelMode, travelMode) ||
                other.travelMode == travelMode) &&
            const DeepCollectionEquality()
                .equals(other.streetNames, streetNames) &&
            const DeepCollectionEquality()
                .equals(other.beginStreetNames, beginStreetNames) &&
            (identical(other.verbalTransitionAlertInstruction, verbalTransitionAlertInstruction) ||
                other.verbalTransitionAlertInstruction ==
                    verbalTransitionAlertInstruction) &&
            (identical(other.verbalPreTransitionInstruction, verbalPreTransitionInstruction) ||
                other.verbalPreTransitionInstruction ==
                    verbalPreTransitionInstruction) &&
            (identical(other.verbalPostTransitionInstruction, verbalPostTransitionInstruction) ||
                other.verbalPostTransitionInstruction ==
                    verbalPostTransitionInstruction) &&
            (identical(other.verbalSuccinctTransitionInstruction,
                    verbalSuccinctTransitionInstruction) ||
                other.verbalSuccinctTransitionInstruction ==
                    verbalSuccinctTransitionInstruction) &&
            (identical(other.verbalMultiCue, verbalMultiCue) ||
                other.verbalMultiCue == verbalMultiCue) &&
            (identical(other.roundaboutExitCount, roundaboutExitCount) ||
                other.roundaboutExitCount == roundaboutExitCount) &&
            (identical(other.departInstruction, departInstruction) ||
                other.departInstruction == departInstruction) &&
            (identical(other.verbalDepartInstruction, verbalDepartInstruction) ||
                other.verbalDepartInstruction == verbalDepartInstruction) &&
            (identical(other.arriveInstruction, arriveInstruction) ||
                other.arriveInstruction == arriveInstruction) &&
            (identical(other.verbalArriveInstruction, verbalArriveInstruction) ||
                other.verbalArriveInstruction == verbalArriveInstruction) &&
            (identical(other.toll, toll) || other.toll == toll) &&
            (identical(other.gate, gate) || other.gate == gate) &&
            (identical(other.ferry, ferry) || other.ferry == ferry) &&
            const DeepCollectionEquality().equals(other.lanes, lanes) &&
            (identical(other.bearingBefore, bearingBefore) ||
                other.bearingBefore == bearingBefore) &&
            (identical(other.bearingAfter, bearingAfter) ||
                other.bearingAfter == bearingAfter) &&
            (identical(other.bssManeuverType, bssManeuverType) ||
                other.bssManeuverType == bssManeuverType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        type,
        instruction,
        length,
        time,
        beginShapeIndex,
        endShapeIndex,
        travelMode,
        const DeepCollectionEquality().hash(streetNames),
        const DeepCollectionEquality().hash(beginStreetNames),
        verbalTransitionAlertInstruction,
        verbalPreTransitionInstruction,
        verbalPostTransitionInstruction,
        verbalSuccinctTransitionInstruction,
        verbalMultiCue,
        roundaboutExitCount,
        departInstruction,
        verbalDepartInstruction,
        arriveInstruction,
        verbalArriveInstruction,
        toll,
        gate,
        ferry,
        const DeepCollectionEquality().hash(lanes),
        bearingBefore,
        bearingAfter,
        bssManeuverType
      ]);

  @override
  String toString() {
    return 'Maneuver(type: $type, instruction: $instruction, length: $length, time: $time, beginShapeIndex: $beginShapeIndex, endShapeIndex: $endShapeIndex, travelMode: $travelMode, streetNames: $streetNames, beginStreetNames: $beginStreetNames, verbalTransitionAlertInstruction: $verbalTransitionAlertInstruction, verbalPreTransitionInstruction: $verbalPreTransitionInstruction, verbalPostTransitionInstruction: $verbalPostTransitionInstruction, verbalSuccinctTransitionInstruction: $verbalSuccinctTransitionInstruction, verbalMultiCue: $verbalMultiCue, roundaboutExitCount: $roundaboutExitCount, departInstruction: $departInstruction, verbalDepartInstruction: $verbalDepartInstruction, arriveInstruction: $arriveInstruction, verbalArriveInstruction: $verbalArriveInstruction, toll: $toll, gate: $gate, ferry: $ferry, lanes: $lanes, bearingBefore: $bearingBefore, bearingAfter: $bearingAfter, bssManeuverType: $bssManeuverType)';
  }
}

/// @nodoc
abstract mixin class $ManeuverCopyWith<$Res> {
  factory $ManeuverCopyWith(Maneuver value, $Res Function(Maneuver) _then) =
      _$ManeuverCopyWithImpl;
  @useResult
  $Res call(
      {int type,
      String instruction,
      double length,
      double time,
      @JsonKey(name: 'begin_shape_index') int beginShapeIndex,
      @JsonKey(name: 'end_shape_index') int endShapeIndex,
      @JsonKey(name: 'travel_mode') String travelMode,
      @JsonKey(name: 'street_names') List<String>? streetNames,
      @JsonKey(name: 'begin_street_names') List<String>? beginStreetNames,
      @JsonKey(name: 'verbal_transition_alert_instruction')
      String? verbalTransitionAlertInstruction,
      @JsonKey(name: 'verbal_pre_transition_instruction')
      String? verbalPreTransitionInstruction,
      @JsonKey(name: 'verbal_post_transition_instruction')
      String? verbalPostTransitionInstruction,
      @JsonKey(name: 'verbal_succinct_transition_instruction')
      String? verbalSuccinctTransitionInstruction,
      @JsonKey(name: 'verbal_multi_cue') bool verbalMultiCue,
      @JsonKey(name: 'roundabout_exit_count') int? roundaboutExitCount,
      @JsonKey(name: 'depart_instruction') String? departInstruction,
      @JsonKey(name: 'verbal_depart_instruction')
      String? verbalDepartInstruction,
      @JsonKey(name: 'arrive_instruction') String? arriveInstruction,
      @JsonKey(name: 'verbal_arrive_instruction')
      String? verbalArriveInstruction,
      bool toll,
      bool gate,
      bool ferry,
      List<ValhallaLane>? lanes,
      @JsonKey(name: 'bearing_before') double? bearingBefore,
      @JsonKey(name: 'bearing_after') double? bearingAfter,
      @JsonKey(name: 'bss_maneuver_type') String? bssManeuverType});
}

/// @nodoc
class _$ManeuverCopyWithImpl<$Res> implements $ManeuverCopyWith<$Res> {
  _$ManeuverCopyWithImpl(this._self, this._then);

  final Maneuver _self;
  final $Res Function(Maneuver) _then;

  /// Create a copy of Maneuver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? instruction = null,
    Object? length = null,
    Object? time = null,
    Object? beginShapeIndex = null,
    Object? endShapeIndex = null,
    Object? travelMode = null,
    Object? streetNames = freezed,
    Object? beginStreetNames = freezed,
    Object? verbalTransitionAlertInstruction = freezed,
    Object? verbalPreTransitionInstruction = freezed,
    Object? verbalPostTransitionInstruction = freezed,
    Object? verbalSuccinctTransitionInstruction = freezed,
    Object? verbalMultiCue = null,
    Object? roundaboutExitCount = freezed,
    Object? departInstruction = freezed,
    Object? verbalDepartInstruction = freezed,
    Object? arriveInstruction = freezed,
    Object? verbalArriveInstruction = freezed,
    Object? toll = null,
    Object? gate = null,
    Object? ferry = null,
    Object? lanes = freezed,
    Object? bearingBefore = freezed,
    Object? bearingAfter = freezed,
    Object? bssManeuverType = freezed,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      instruction: null == instruction
          ? _self.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      length: null == length
          ? _self.length
          : length // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      beginShapeIndex: null == beginShapeIndex
          ? _self.beginShapeIndex
          : beginShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endShapeIndex: null == endShapeIndex
          ? _self.endShapeIndex
          : endShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      travelMode: null == travelMode
          ? _self.travelMode
          : travelMode // ignore: cast_nullable_to_non_nullable
              as String,
      streetNames: freezed == streetNames
          ? _self.streetNames
          : streetNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      beginStreetNames: freezed == beginStreetNames
          ? _self.beginStreetNames
          : beginStreetNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      verbalTransitionAlertInstruction: freezed ==
              verbalTransitionAlertInstruction
          ? _self.verbalTransitionAlertInstruction
          : verbalTransitionAlertInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalPreTransitionInstruction: freezed == verbalPreTransitionInstruction
          ? _self.verbalPreTransitionInstruction
          : verbalPreTransitionInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalPostTransitionInstruction: freezed ==
              verbalPostTransitionInstruction
          ? _self.verbalPostTransitionInstruction
          : verbalPostTransitionInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalSuccinctTransitionInstruction: freezed ==
              verbalSuccinctTransitionInstruction
          ? _self.verbalSuccinctTransitionInstruction
          : verbalSuccinctTransitionInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalMultiCue: null == verbalMultiCue
          ? _self.verbalMultiCue
          : verbalMultiCue // ignore: cast_nullable_to_non_nullable
              as bool,
      roundaboutExitCount: freezed == roundaboutExitCount
          ? _self.roundaboutExitCount
          : roundaboutExitCount // ignore: cast_nullable_to_non_nullable
              as int?,
      departInstruction: freezed == departInstruction
          ? _self.departInstruction
          : departInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalDepartInstruction: freezed == verbalDepartInstruction
          ? _self.verbalDepartInstruction
          : verbalDepartInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      arriveInstruction: freezed == arriveInstruction
          ? _self.arriveInstruction
          : arriveInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalArriveInstruction: freezed == verbalArriveInstruction
          ? _self.verbalArriveInstruction
          : verbalArriveInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      toll: null == toll
          ? _self.toll
          : toll // ignore: cast_nullable_to_non_nullable
              as bool,
      gate: null == gate
          ? _self.gate
          : gate // ignore: cast_nullable_to_non_nullable
              as bool,
      ferry: null == ferry
          ? _self.ferry
          : ferry // ignore: cast_nullable_to_non_nullable
              as bool,
      lanes: freezed == lanes
          ? _self.lanes
          : lanes // ignore: cast_nullable_to_non_nullable
              as List<ValhallaLane>?,
      bearingBefore: freezed == bearingBefore
          ? _self.bearingBefore
          : bearingBefore // ignore: cast_nullable_to_non_nullable
              as double?,
      bearingAfter: freezed == bearingAfter
          ? _self.bearingAfter
          : bearingAfter // ignore: cast_nullable_to_non_nullable
              as double?,
      bssManeuverType: freezed == bssManeuverType
          ? _self.bssManeuverType
          : bssManeuverType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Maneuver implements Maneuver {
  const _Maneuver(
      {required this.type,
      required this.instruction,
      required this.length,
      required this.time,
      @JsonKey(name: 'begin_shape_index') required this.beginShapeIndex,
      @JsonKey(name: 'end_shape_index') required this.endShapeIndex,
      @JsonKey(name: 'travel_mode') required this.travelMode,
      @JsonKey(name: 'street_names') final List<String>? streetNames,
      @JsonKey(name: 'begin_street_names') final List<String>? beginStreetNames,
      @JsonKey(name: 'verbal_transition_alert_instruction')
      this.verbalTransitionAlertInstruction,
      @JsonKey(name: 'verbal_pre_transition_instruction')
      this.verbalPreTransitionInstruction,
      @JsonKey(name: 'verbal_post_transition_instruction')
      this.verbalPostTransitionInstruction,
      @JsonKey(name: 'verbal_succinct_transition_instruction')
      this.verbalSuccinctTransitionInstruction,
      @JsonKey(name: 'verbal_multi_cue') this.verbalMultiCue = false,
      @JsonKey(name: 'roundabout_exit_count') this.roundaboutExitCount,
      @JsonKey(name: 'depart_instruction') this.departInstruction,
      @JsonKey(name: 'verbal_depart_instruction') this.verbalDepartInstruction,
      @JsonKey(name: 'arrive_instruction') this.arriveInstruction,
      @JsonKey(name: 'verbal_arrive_instruction') this.verbalArriveInstruction,
      this.toll = false,
      this.gate = false,
      this.ferry = false,
      final List<ValhallaLane>? lanes,
      @JsonKey(name: 'bearing_before') this.bearingBefore,
      @JsonKey(name: 'bearing_after') this.bearingAfter,
      @JsonKey(name: 'bss_maneuver_type') this.bssManeuverType})
      : _streetNames = streetNames,
        _beginStreetNames = beginStreetNames,
        _lanes = lanes;
  factory _Maneuver.fromJson(Map<String, dynamic> json) =>
      _$ManeuverFromJson(json);

  @override
  final int type;
  @override
  final String instruction;
  @override
  final double length;
  @override
  final double time;
  @override
  @JsonKey(name: 'begin_shape_index')
  final int beginShapeIndex;
  @override
  @JsonKey(name: 'end_shape_index')
  final int endShapeIndex;
  @override
  @JsonKey(name: 'travel_mode')
  final String travelMode;
  final List<String>? _streetNames;
  @override
  @JsonKey(name: 'street_names')
  List<String>? get streetNames {
    final value = _streetNames;
    if (value == null) return null;
    if (_streetNames is EqualUnmodifiableListView) return _streetNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _beginStreetNames;
  @override
  @JsonKey(name: 'begin_street_names')
  List<String>? get beginStreetNames {
    final value = _beginStreetNames;
    if (value == null) return null;
    if (_beginStreetNames is EqualUnmodifiableListView)
      return _beginStreetNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'verbal_transition_alert_instruction')
  final String? verbalTransitionAlertInstruction;
  @override
  @JsonKey(name: 'verbal_pre_transition_instruction')
  final String? verbalPreTransitionInstruction;
  @override
  @JsonKey(name: 'verbal_post_transition_instruction')
  final String? verbalPostTransitionInstruction;
  @override
  @JsonKey(name: 'verbal_succinct_transition_instruction')
  final String? verbalSuccinctTransitionInstruction;
  @override
  @JsonKey(name: 'verbal_multi_cue')
  final bool verbalMultiCue;
  @override
  @JsonKey(name: 'roundabout_exit_count')
  final int? roundaboutExitCount;
  @override
  @JsonKey(name: 'depart_instruction')
  final String? departInstruction;
  @override
  @JsonKey(name: 'verbal_depart_instruction')
  final String? verbalDepartInstruction;
  @override
  @JsonKey(name: 'arrive_instruction')
  final String? arriveInstruction;
  @override
  @JsonKey(name: 'verbal_arrive_instruction')
  final String? verbalArriveInstruction;
  @override
  @JsonKey()
  final bool toll;
  @override
  @JsonKey()
  final bool gate;
  @override
  @JsonKey()
  final bool ferry;
  final List<ValhallaLane>? _lanes;
  @override
  List<ValhallaLane>? get lanes {
    final value = _lanes;
    if (value == null) return null;
    if (_lanes is EqualUnmodifiableListView) return _lanes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'bearing_before')
  final double? bearingBefore;
  @override
  @JsonKey(name: 'bearing_after')
  final double? bearingAfter;
  @override
  @JsonKey(name: 'bss_maneuver_type')
  final String? bssManeuverType;

  /// Create a copy of Maneuver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ManeuverCopyWith<_Maneuver> get copyWith =>
      __$ManeuverCopyWithImpl<_Maneuver>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ManeuverToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Maneuver &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.beginShapeIndex, beginShapeIndex) ||
                other.beginShapeIndex == beginShapeIndex) &&
            (identical(other.endShapeIndex, endShapeIndex) ||
                other.endShapeIndex == endShapeIndex) &&
            (identical(other.travelMode, travelMode) ||
                other.travelMode == travelMode) &&
            const DeepCollectionEquality()
                .equals(other._streetNames, _streetNames) &&
            const DeepCollectionEquality()
                .equals(other._beginStreetNames, _beginStreetNames) &&
            (identical(other.verbalTransitionAlertInstruction, verbalTransitionAlertInstruction) ||
                other.verbalTransitionAlertInstruction ==
                    verbalTransitionAlertInstruction) &&
            (identical(other.verbalPreTransitionInstruction, verbalPreTransitionInstruction) ||
                other.verbalPreTransitionInstruction ==
                    verbalPreTransitionInstruction) &&
            (identical(other.verbalPostTransitionInstruction, verbalPostTransitionInstruction) ||
                other.verbalPostTransitionInstruction ==
                    verbalPostTransitionInstruction) &&
            (identical(other.verbalSuccinctTransitionInstruction,
                    verbalSuccinctTransitionInstruction) ||
                other.verbalSuccinctTransitionInstruction ==
                    verbalSuccinctTransitionInstruction) &&
            (identical(other.verbalMultiCue, verbalMultiCue) ||
                other.verbalMultiCue == verbalMultiCue) &&
            (identical(other.roundaboutExitCount, roundaboutExitCount) ||
                other.roundaboutExitCount == roundaboutExitCount) &&
            (identical(other.departInstruction, departInstruction) ||
                other.departInstruction == departInstruction) &&
            (identical(other.verbalDepartInstruction, verbalDepartInstruction) ||
                other.verbalDepartInstruction == verbalDepartInstruction) &&
            (identical(other.arriveInstruction, arriveInstruction) ||
                other.arriveInstruction == arriveInstruction) &&
            (identical(other.verbalArriveInstruction, verbalArriveInstruction) ||
                other.verbalArriveInstruction == verbalArriveInstruction) &&
            (identical(other.toll, toll) || other.toll == toll) &&
            (identical(other.gate, gate) || other.gate == gate) &&
            (identical(other.ferry, ferry) || other.ferry == ferry) &&
            const DeepCollectionEquality().equals(other._lanes, _lanes) &&
            (identical(other.bearingBefore, bearingBefore) ||
                other.bearingBefore == bearingBefore) &&
            (identical(other.bearingAfter, bearingAfter) ||
                other.bearingAfter == bearingAfter) &&
            (identical(other.bssManeuverType, bssManeuverType) ||
                other.bssManeuverType == bssManeuverType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        type,
        instruction,
        length,
        time,
        beginShapeIndex,
        endShapeIndex,
        travelMode,
        const DeepCollectionEquality().hash(_streetNames),
        const DeepCollectionEquality().hash(_beginStreetNames),
        verbalTransitionAlertInstruction,
        verbalPreTransitionInstruction,
        verbalPostTransitionInstruction,
        verbalSuccinctTransitionInstruction,
        verbalMultiCue,
        roundaboutExitCount,
        departInstruction,
        verbalDepartInstruction,
        arriveInstruction,
        verbalArriveInstruction,
        toll,
        gate,
        ferry,
        const DeepCollectionEquality().hash(_lanes),
        bearingBefore,
        bearingAfter,
        bssManeuverType
      ]);

  @override
  String toString() {
    return 'Maneuver(type: $type, instruction: $instruction, length: $length, time: $time, beginShapeIndex: $beginShapeIndex, endShapeIndex: $endShapeIndex, travelMode: $travelMode, streetNames: $streetNames, beginStreetNames: $beginStreetNames, verbalTransitionAlertInstruction: $verbalTransitionAlertInstruction, verbalPreTransitionInstruction: $verbalPreTransitionInstruction, verbalPostTransitionInstruction: $verbalPostTransitionInstruction, verbalSuccinctTransitionInstruction: $verbalSuccinctTransitionInstruction, verbalMultiCue: $verbalMultiCue, roundaboutExitCount: $roundaboutExitCount, departInstruction: $departInstruction, verbalDepartInstruction: $verbalDepartInstruction, arriveInstruction: $arriveInstruction, verbalArriveInstruction: $verbalArriveInstruction, toll: $toll, gate: $gate, ferry: $ferry, lanes: $lanes, bearingBefore: $bearingBefore, bearingAfter: $bearingAfter, bssManeuverType: $bssManeuverType)';
  }
}

/// @nodoc
abstract mixin class _$ManeuverCopyWith<$Res>
    implements $ManeuverCopyWith<$Res> {
  factory _$ManeuverCopyWith(_Maneuver value, $Res Function(_Maneuver) _then) =
      __$ManeuverCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int type,
      String instruction,
      double length,
      double time,
      @JsonKey(name: 'begin_shape_index') int beginShapeIndex,
      @JsonKey(name: 'end_shape_index') int endShapeIndex,
      @JsonKey(name: 'travel_mode') String travelMode,
      @JsonKey(name: 'street_names') List<String>? streetNames,
      @JsonKey(name: 'begin_street_names') List<String>? beginStreetNames,
      @JsonKey(name: 'verbal_transition_alert_instruction')
      String? verbalTransitionAlertInstruction,
      @JsonKey(name: 'verbal_pre_transition_instruction')
      String? verbalPreTransitionInstruction,
      @JsonKey(name: 'verbal_post_transition_instruction')
      String? verbalPostTransitionInstruction,
      @JsonKey(name: 'verbal_succinct_transition_instruction')
      String? verbalSuccinctTransitionInstruction,
      @JsonKey(name: 'verbal_multi_cue') bool verbalMultiCue,
      @JsonKey(name: 'roundabout_exit_count') int? roundaboutExitCount,
      @JsonKey(name: 'depart_instruction') String? departInstruction,
      @JsonKey(name: 'verbal_depart_instruction')
      String? verbalDepartInstruction,
      @JsonKey(name: 'arrive_instruction') String? arriveInstruction,
      @JsonKey(name: 'verbal_arrive_instruction')
      String? verbalArriveInstruction,
      bool toll,
      bool gate,
      bool ferry,
      List<ValhallaLane>? lanes,
      @JsonKey(name: 'bearing_before') double? bearingBefore,
      @JsonKey(name: 'bearing_after') double? bearingAfter,
      @JsonKey(name: 'bss_maneuver_type') String? bssManeuverType});
}

/// @nodoc
class __$ManeuverCopyWithImpl<$Res> implements _$ManeuverCopyWith<$Res> {
  __$ManeuverCopyWithImpl(this._self, this._then);

  final _Maneuver _self;
  final $Res Function(_Maneuver) _then;

  /// Create a copy of Maneuver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? instruction = null,
    Object? length = null,
    Object? time = null,
    Object? beginShapeIndex = null,
    Object? endShapeIndex = null,
    Object? travelMode = null,
    Object? streetNames = freezed,
    Object? beginStreetNames = freezed,
    Object? verbalTransitionAlertInstruction = freezed,
    Object? verbalPreTransitionInstruction = freezed,
    Object? verbalPostTransitionInstruction = freezed,
    Object? verbalSuccinctTransitionInstruction = freezed,
    Object? verbalMultiCue = null,
    Object? roundaboutExitCount = freezed,
    Object? departInstruction = freezed,
    Object? verbalDepartInstruction = freezed,
    Object? arriveInstruction = freezed,
    Object? verbalArriveInstruction = freezed,
    Object? toll = null,
    Object? gate = null,
    Object? ferry = null,
    Object? lanes = freezed,
    Object? bearingBefore = freezed,
    Object? bearingAfter = freezed,
    Object? bssManeuverType = freezed,
  }) {
    return _then(_Maneuver(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      instruction: null == instruction
          ? _self.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      length: null == length
          ? _self.length
          : length // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      beginShapeIndex: null == beginShapeIndex
          ? _self.beginShapeIndex
          : beginShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      endShapeIndex: null == endShapeIndex
          ? _self.endShapeIndex
          : endShapeIndex // ignore: cast_nullable_to_non_nullable
              as int,
      travelMode: null == travelMode
          ? _self.travelMode
          : travelMode // ignore: cast_nullable_to_non_nullable
              as String,
      streetNames: freezed == streetNames
          ? _self._streetNames
          : streetNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      beginStreetNames: freezed == beginStreetNames
          ? _self._beginStreetNames
          : beginStreetNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      verbalTransitionAlertInstruction: freezed ==
              verbalTransitionAlertInstruction
          ? _self.verbalTransitionAlertInstruction
          : verbalTransitionAlertInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalPreTransitionInstruction: freezed == verbalPreTransitionInstruction
          ? _self.verbalPreTransitionInstruction
          : verbalPreTransitionInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalPostTransitionInstruction: freezed ==
              verbalPostTransitionInstruction
          ? _self.verbalPostTransitionInstruction
          : verbalPostTransitionInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalSuccinctTransitionInstruction: freezed ==
              verbalSuccinctTransitionInstruction
          ? _self.verbalSuccinctTransitionInstruction
          : verbalSuccinctTransitionInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalMultiCue: null == verbalMultiCue
          ? _self.verbalMultiCue
          : verbalMultiCue // ignore: cast_nullable_to_non_nullable
              as bool,
      roundaboutExitCount: freezed == roundaboutExitCount
          ? _self.roundaboutExitCount
          : roundaboutExitCount // ignore: cast_nullable_to_non_nullable
              as int?,
      departInstruction: freezed == departInstruction
          ? _self.departInstruction
          : departInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalDepartInstruction: freezed == verbalDepartInstruction
          ? _self.verbalDepartInstruction
          : verbalDepartInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      arriveInstruction: freezed == arriveInstruction
          ? _self.arriveInstruction
          : arriveInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      verbalArriveInstruction: freezed == verbalArriveInstruction
          ? _self.verbalArriveInstruction
          : verbalArriveInstruction // ignore: cast_nullable_to_non_nullable
              as String?,
      toll: null == toll
          ? _self.toll
          : toll // ignore: cast_nullable_to_non_nullable
              as bool,
      gate: null == gate
          ? _self.gate
          : gate // ignore: cast_nullable_to_non_nullable
              as bool,
      ferry: null == ferry
          ? _self.ferry
          : ferry // ignore: cast_nullable_to_non_nullable
              as bool,
      lanes: freezed == lanes
          ? _self._lanes
          : lanes // ignore: cast_nullable_to_non_nullable
              as List<ValhallaLane>?,
      bearingBefore: freezed == bearingBefore
          ? _self.bearingBefore
          : bearingBefore // ignore: cast_nullable_to_non_nullable
              as double?,
      bearingAfter: freezed == bearingAfter
          ? _self.bearingAfter
          : bearingAfter // ignore: cast_nullable_to_non_nullable
              as double?,
      bssManeuverType: freezed == bssManeuverType
          ? _self.bssManeuverType
          : bssManeuverType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$ValhallaLane {
  int get directions; // Bitmask
  int? get valid; // Bitmask, optional
  int? get active;

  /// Create a copy of ValhallaLane
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValhallaLaneCopyWith<ValhallaLane> get copyWith =>
      _$ValhallaLaneCopyWithImpl<ValhallaLane>(
          this as ValhallaLane, _$identity);

  /// Serializes this ValhallaLane to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValhallaLane &&
            (identical(other.directions, directions) ||
                other.directions == directions) &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, directions, valid, active);

  @override
  String toString() {
    return 'ValhallaLane(directions: $directions, valid: $valid, active: $active)';
  }
}

/// @nodoc
abstract mixin class $ValhallaLaneCopyWith<$Res> {
  factory $ValhallaLaneCopyWith(
          ValhallaLane value, $Res Function(ValhallaLane) _then) =
      _$ValhallaLaneCopyWithImpl;
  @useResult
  $Res call({int directions, int? valid, int? active});
}

/// @nodoc
class _$ValhallaLaneCopyWithImpl<$Res> implements $ValhallaLaneCopyWith<$Res> {
  _$ValhallaLaneCopyWithImpl(this._self, this._then);

  final ValhallaLane _self;
  final $Res Function(ValhallaLane) _then;

  /// Create a copy of ValhallaLane
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? directions = null,
    Object? valid = freezed,
    Object? active = freezed,
  }) {
    return _then(_self.copyWith(
      directions: null == directions
          ? _self.directions
          : directions // ignore: cast_nullable_to_non_nullable
              as int,
      valid: freezed == valid
          ? _self.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as int?,
      active: freezed == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ValhallaLane implements ValhallaLane {
  const _ValhallaLane({required this.directions, this.valid, this.active});
  factory _ValhallaLane.fromJson(Map<String, dynamic> json) =>
      _$ValhallaLaneFromJson(json);

  @override
  final int directions;
// Bitmask
  @override
  final int? valid;
// Bitmask, optional
  @override
  final int? active;

  /// Create a copy of ValhallaLane
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ValhallaLaneCopyWith<_ValhallaLane> get copyWith =>
      __$ValhallaLaneCopyWithImpl<_ValhallaLane>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ValhallaLaneToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ValhallaLane &&
            (identical(other.directions, directions) ||
                other.directions == directions) &&
            (identical(other.valid, valid) || other.valid == valid) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, directions, valid, active);

  @override
  String toString() {
    return 'ValhallaLane(directions: $directions, valid: $valid, active: $active)';
  }
}

/// @nodoc
abstract mixin class _$ValhallaLaneCopyWith<$Res>
    implements $ValhallaLaneCopyWith<$Res> {
  factory _$ValhallaLaneCopyWith(
          _ValhallaLane value, $Res Function(_ValhallaLane) _then) =
      __$ValhallaLaneCopyWithImpl;
  @override
  @useResult
  $Res call({int directions, int? valid, int? active});
}

/// @nodoc
class __$ValhallaLaneCopyWithImpl<$Res>
    implements _$ValhallaLaneCopyWith<$Res> {
  __$ValhallaLaneCopyWithImpl(this._self, this._then);

  final _ValhallaLane _self;
  final $Res Function(_ValhallaLane) _then;

  /// Create a copy of ValhallaLane
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? directions = null,
    Object? valid = freezed,
    Object? active = freezed,
  }) {
    return _then(_ValhallaLane(
      directions: null == directions
          ? _self.directions
          : directions // ignore: cast_nullable_to_non_nullable
              as int,
      valid: freezed == valid
          ? _self.valid
          : valid // ignore: cast_nullable_to_non_nullable
              as int?,
      active: freezed == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$Summary {
  double get length;
  int get time;
  @JsonKey(name: 'has_toll')
  bool get hasToll;
  @JsonKey(name: 'has_highway')
  bool get hasHighway; // Kept for info, even if routing profile avoids them
  @JsonKey(name: 'has_ferry')
  bool get hasFerry;
  @JsonKey(name: 'min_lat')
  double? get minLat;
  @JsonKey(name: 'min_lon')
  double? get minLon;
  @JsonKey(name: 'max_lat')
  double? get maxLat;
  @JsonKey(name: 'max_lon')
  double? get maxLon;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SummaryCopyWith<Summary> get copyWith =>
      _$SummaryCopyWithImpl<Summary>(this as Summary, _$identity);

  /// Serializes this Summary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Summary &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.hasToll, hasToll) || other.hasToll == hasToll) &&
            (identical(other.hasHighway, hasHighway) ||
                other.hasHighway == hasHighway) &&
            (identical(other.hasFerry, hasFerry) ||
                other.hasFerry == hasFerry) &&
            (identical(other.minLat, minLat) || other.minLat == minLat) &&
            (identical(other.minLon, minLon) || other.minLon == minLon) &&
            (identical(other.maxLat, maxLat) || other.maxLat == maxLat) &&
            (identical(other.maxLon, maxLon) || other.maxLon == maxLon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, length, time, hasToll,
      hasHighway, hasFerry, minLat, minLon, maxLat, maxLon);

  @override
  String toString() {
    return 'Summary(length: $length, time: $time, hasToll: $hasToll, hasHighway: $hasHighway, hasFerry: $hasFerry, minLat: $minLat, minLon: $minLon, maxLat: $maxLat, maxLon: $maxLon)';
  }
}

/// @nodoc
abstract mixin class $SummaryCopyWith<$Res> {
  factory $SummaryCopyWith(Summary value, $Res Function(Summary) _then) =
      _$SummaryCopyWithImpl;
  @useResult
  $Res call(
      {double length,
      int time,
      @JsonKey(name: 'has_toll') bool hasToll,
      @JsonKey(name: 'has_highway') bool hasHighway,
      @JsonKey(name: 'has_ferry') bool hasFerry,
      @JsonKey(name: 'min_lat') double? minLat,
      @JsonKey(name: 'min_lon') double? minLon,
      @JsonKey(name: 'max_lat') double? maxLat,
      @JsonKey(name: 'max_lon') double? maxLon});
}

/// @nodoc
class _$SummaryCopyWithImpl<$Res> implements $SummaryCopyWith<$Res> {
  _$SummaryCopyWithImpl(this._self, this._then);

  final Summary _self;
  final $Res Function(Summary) _then;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? length = null,
    Object? time = null,
    Object? hasToll = null,
    Object? hasHighway = null,
    Object? hasFerry = null,
    Object? minLat = freezed,
    Object? minLon = freezed,
    Object? maxLat = freezed,
    Object? maxLon = freezed,
  }) {
    return _then(_self.copyWith(
      length: null == length
          ? _self.length
          : length // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      hasToll: null == hasToll
          ? _self.hasToll
          : hasToll // ignore: cast_nullable_to_non_nullable
              as bool,
      hasHighway: null == hasHighway
          ? _self.hasHighway
          : hasHighway // ignore: cast_nullable_to_non_nullable
              as bool,
      hasFerry: null == hasFerry
          ? _self.hasFerry
          : hasFerry // ignore: cast_nullable_to_non_nullable
              as bool,
      minLat: freezed == minLat
          ? _self.minLat
          : minLat // ignore: cast_nullable_to_non_nullable
              as double?,
      minLon: freezed == minLon
          ? _self.minLon
          : minLon // ignore: cast_nullable_to_non_nullable
              as double?,
      maxLat: freezed == maxLat
          ? _self.maxLat
          : maxLat // ignore: cast_nullable_to_non_nullable
              as double?,
      maxLon: freezed == maxLon
          ? _self.maxLon
          : maxLon // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Summary implements Summary {
  const _Summary(
      {required this.length,
      required this.time,
      @JsonKey(name: 'has_toll') this.hasToll = false,
      @JsonKey(name: 'has_highway') this.hasHighway = false,
      @JsonKey(name: 'has_ferry') this.hasFerry = false,
      @JsonKey(name: 'min_lat') this.minLat,
      @JsonKey(name: 'min_lon') this.minLon,
      @JsonKey(name: 'max_lat') this.maxLat,
      @JsonKey(name: 'max_lon') this.maxLon});
  factory _Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);

  @override
  final double length;
  @override
  final int time;
  @override
  @JsonKey(name: 'has_toll')
  final bool hasToll;
  @override
  @JsonKey(name: 'has_highway')
  final bool hasHighway;
// Kept for info, even if routing profile avoids them
  @override
  @JsonKey(name: 'has_ferry')
  final bool hasFerry;
  @override
  @JsonKey(name: 'min_lat')
  final double? minLat;
  @override
  @JsonKey(name: 'min_lon')
  final double? minLon;
  @override
  @JsonKey(name: 'max_lat')
  final double? maxLat;
  @override
  @JsonKey(name: 'max_lon')
  final double? maxLon;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SummaryCopyWith<_Summary> get copyWith =>
      __$SummaryCopyWithImpl<_Summary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SummaryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Summary &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.hasToll, hasToll) || other.hasToll == hasToll) &&
            (identical(other.hasHighway, hasHighway) ||
                other.hasHighway == hasHighway) &&
            (identical(other.hasFerry, hasFerry) ||
                other.hasFerry == hasFerry) &&
            (identical(other.minLat, minLat) || other.minLat == minLat) &&
            (identical(other.minLon, minLon) || other.minLon == minLon) &&
            (identical(other.maxLat, maxLat) || other.maxLat == maxLat) &&
            (identical(other.maxLon, maxLon) || other.maxLon == maxLon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, length, time, hasToll,
      hasHighway, hasFerry, minLat, minLon, maxLat, maxLon);

  @override
  String toString() {
    return 'Summary(length: $length, time: $time, hasToll: $hasToll, hasHighway: $hasHighway, hasFerry: $hasFerry, minLat: $minLat, minLon: $minLon, maxLat: $maxLat, maxLon: $maxLon)';
  }
}

/// @nodoc
abstract mixin class _$SummaryCopyWith<$Res> implements $SummaryCopyWith<$Res> {
  factory _$SummaryCopyWith(_Summary value, $Res Function(_Summary) _then) =
      __$SummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double length,
      int time,
      @JsonKey(name: 'has_toll') bool hasToll,
      @JsonKey(name: 'has_highway') bool hasHighway,
      @JsonKey(name: 'has_ferry') bool hasFerry,
      @JsonKey(name: 'min_lat') double? minLat,
      @JsonKey(name: 'min_lon') double? minLon,
      @JsonKey(name: 'max_lat') double? maxLat,
      @JsonKey(name: 'max_lon') double? maxLon});
}

/// @nodoc
class __$SummaryCopyWithImpl<$Res> implements _$SummaryCopyWith<$Res> {
  __$SummaryCopyWithImpl(this._self, this._then);

  final _Summary _self;
  final $Res Function(_Summary) _then;

  /// Create a copy of Summary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? length = null,
    Object? time = null,
    Object? hasToll = null,
    Object? hasHighway = null,
    Object? hasFerry = null,
    Object? minLat = freezed,
    Object? minLon = freezed,
    Object? maxLat = freezed,
    Object? maxLon = freezed,
  }) {
    return _then(_Summary(
      length: null == length
          ? _self.length
          : length // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      hasToll: null == hasToll
          ? _self.hasToll
          : hasToll // ignore: cast_nullable_to_non_nullable
              as bool,
      hasHighway: null == hasHighway
          ? _self.hasHighway
          : hasHighway // ignore: cast_nullable_to_non_nullable
              as bool,
      hasFerry: null == hasFerry
          ? _self.hasFerry
          : hasFerry // ignore: cast_nullable_to_non_nullable
              as bool,
      minLat: freezed == minLat
          ? _self.minLat
          : minLat // ignore: cast_nullable_to_non_nullable
              as double?,
      minLon: freezed == minLon
          ? _self.minLon
          : minLon // ignore: cast_nullable_to_non_nullable
              as double?,
      maxLat: freezed == maxLat
          ? _self.maxLat
          : maxLat // ignore: cast_nullable_to_non_nullable
              as double?,
      maxLon: freezed == maxLon
          ? _self.maxLon
          : maxLon // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
mixin _$ValhallaTripLocation {
  double get lat;
  double get lon;
  String? get type; // "break", "through", etc.
  String? get name;
  String? get street;
  String? get city;
  String? get state;
  @JsonKey(name: 'postal_code')
  String? get postalCode;
  String? get country;
  @JsonKey(name: 'side_of_street')
  String? get sideOfStreet;
  @JsonKey(name: 'date_time')
  String? get dateTime; // ISO 8601 format
  @JsonKey(name: 'original_index')
  int? get originalIndex;

  /// Create a copy of ValhallaTripLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValhallaTripLocationCopyWith<ValhallaTripLocation> get copyWith =>
      _$ValhallaTripLocationCopyWithImpl<ValhallaTripLocation>(
          this as ValhallaTripLocation, _$identity);

  /// Serializes this ValhallaTripLocation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValhallaTripLocation &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.sideOfStreet, sideOfStreet) ||
                other.sideOfStreet == sideOfStreet) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.originalIndex, originalIndex) ||
                other.originalIndex == originalIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lon, type, name, street,
      city, state, postalCode, country, sideOfStreet, dateTime, originalIndex);

  @override
  String toString() {
    return 'ValhallaTripLocation(lat: $lat, lon: $lon, type: $type, name: $name, street: $street, city: $city, state: $state, postalCode: $postalCode, country: $country, sideOfStreet: $sideOfStreet, dateTime: $dateTime, originalIndex: $originalIndex)';
  }
}

/// @nodoc
abstract mixin class $ValhallaTripLocationCopyWith<$Res> {
  factory $ValhallaTripLocationCopyWith(ValhallaTripLocation value,
          $Res Function(ValhallaTripLocation) _then) =
      _$ValhallaTripLocationCopyWithImpl;
  @useResult
  $Res call(
      {double lat,
      double lon,
      String? type,
      String? name,
      String? street,
      String? city,
      String? state,
      @JsonKey(name: 'postal_code') String? postalCode,
      String? country,
      @JsonKey(name: 'side_of_street') String? sideOfStreet,
      @JsonKey(name: 'date_time') String? dateTime,
      @JsonKey(name: 'original_index') int? originalIndex});
}

/// @nodoc
class _$ValhallaTripLocationCopyWithImpl<$Res>
    implements $ValhallaTripLocationCopyWith<$Res> {
  _$ValhallaTripLocationCopyWithImpl(this._self, this._then);

  final ValhallaTripLocation _self;
  final $Res Function(ValhallaTripLocation) _then;

  /// Create a copy of ValhallaTripLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lon = null,
    Object? type = freezed,
    Object? name = freezed,
    Object? street = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? country = freezed,
    Object? sideOfStreet = freezed,
    Object? dateTime = freezed,
    Object? originalIndex = freezed,
  }) {
    return _then(_self.copyWith(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lon: null == lon
          ? _self.lon
          : lon // ignore: cast_nullable_to_non_nullable
              as double,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      street: freezed == street
          ? _self.street
          : street // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _self.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      sideOfStreet: freezed == sideOfStreet
          ? _self.sideOfStreet
          : sideOfStreet // ignore: cast_nullable_to_non_nullable
              as String?,
      dateTime: freezed == dateTime
          ? _self.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      originalIndex: freezed == originalIndex
          ? _self.originalIndex
          : originalIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ValhallaTripLocation implements ValhallaTripLocation {
  const _ValhallaTripLocation(
      {required this.lat,
      required this.lon,
      this.type,
      this.name,
      this.street,
      this.city,
      this.state,
      @JsonKey(name: 'postal_code') this.postalCode,
      this.country,
      @JsonKey(name: 'side_of_street') this.sideOfStreet,
      @JsonKey(name: 'date_time') this.dateTime,
      @JsonKey(name: 'original_index') this.originalIndex});
  factory _ValhallaTripLocation.fromJson(Map<String, dynamic> json) =>
      _$ValhallaTripLocationFromJson(json);

  @override
  final double lat;
  @override
  final double lon;
  @override
  final String? type;
// "break", "through", etc.
  @override
  final String? name;
  @override
  final String? street;
  @override
  final String? city;
  @override
  final String? state;
  @override
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  @override
  final String? country;
  @override
  @JsonKey(name: 'side_of_street')
  final String? sideOfStreet;
  @override
  @JsonKey(name: 'date_time')
  final String? dateTime;
// ISO 8601 format
  @override
  @JsonKey(name: 'original_index')
  final int? originalIndex;

  /// Create a copy of ValhallaTripLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ValhallaTripLocationCopyWith<_ValhallaTripLocation> get copyWith =>
      __$ValhallaTripLocationCopyWithImpl<_ValhallaTripLocation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ValhallaTripLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ValhallaTripLocation &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.sideOfStreet, sideOfStreet) ||
                other.sideOfStreet == sideOfStreet) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.originalIndex, originalIndex) ||
                other.originalIndex == originalIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lon, type, name, street,
      city, state, postalCode, country, sideOfStreet, dateTime, originalIndex);

  @override
  String toString() {
    return 'ValhallaTripLocation(lat: $lat, lon: $lon, type: $type, name: $name, street: $street, city: $city, state: $state, postalCode: $postalCode, country: $country, sideOfStreet: $sideOfStreet, dateTime: $dateTime, originalIndex: $originalIndex)';
  }
}

/// @nodoc
abstract mixin class _$ValhallaTripLocationCopyWith<$Res>
    implements $ValhallaTripLocationCopyWith<$Res> {
  factory _$ValhallaTripLocationCopyWith(_ValhallaTripLocation value,
          $Res Function(_ValhallaTripLocation) _then) =
      __$ValhallaTripLocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double lat,
      double lon,
      String? type,
      String? name,
      String? street,
      String? city,
      String? state,
      @JsonKey(name: 'postal_code') String? postalCode,
      String? country,
      @JsonKey(name: 'side_of_street') String? sideOfStreet,
      @JsonKey(name: 'date_time') String? dateTime,
      @JsonKey(name: 'original_index') int? originalIndex});
}

/// @nodoc
class __$ValhallaTripLocationCopyWithImpl<$Res>
    implements _$ValhallaTripLocationCopyWith<$Res> {
  __$ValhallaTripLocationCopyWithImpl(this._self, this._then);

  final _ValhallaTripLocation _self;
  final $Res Function(_ValhallaTripLocation) _then;

  /// Create a copy of ValhallaTripLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lat = null,
    Object? lon = null,
    Object? type = freezed,
    Object? name = freezed,
    Object? street = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? country = freezed,
    Object? sideOfStreet = freezed,
    Object? dateTime = freezed,
    Object? originalIndex = freezed,
  }) {
    return _then(_ValhallaTripLocation(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lon: null == lon
          ? _self.lon
          : lon // ignore: cast_nullable_to_non_nullable
              as double,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      street: freezed == street
          ? _self.street
          : street // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _self.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      sideOfStreet: freezed == sideOfStreet
          ? _self.sideOfStreet
          : sideOfStreet // ignore: cast_nullable_to_non_nullable
              as String?,
      dateTime: freezed == dateTime
          ? _self.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      originalIndex: freezed == originalIndex
          ? _self.originalIndex
          : originalIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
