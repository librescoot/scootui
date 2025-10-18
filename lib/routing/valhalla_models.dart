import 'package:freezed_annotation/freezed_annotation.dart';

part 'valhalla_models.freezed.dart';
part 'valhalla_models.g.dart';

@freezed
abstract class ValhallaResponse with _$ValhallaResponse {
  const factory ValhallaResponse({
    required Trip trip,
    String? id,
    String? units,
    String? language,
    // List<ValhallaWarning>? warnings, // Define if structure is known
  }) = _ValhallaResponse;

  factory ValhallaResponse.fromJson(Map<String, dynamic> json) => _$ValhallaResponseFromJson(json);
}

@freezed
abstract class Trip with _$Trip {
  const factory Trip({
    required List<Leg> legs,
    required Summary summary,
    required List<ValhallaTripLocation> locations,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

@freezed
abstract class Leg with _$Leg {
  const factory Leg({
    required List<Maneuver> maneuvers,
    required Summary summary,
    required String shape,
  }) = _Leg;

  factory Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);
}

@freezed
abstract class Maneuver with _$Maneuver {
  const factory Maneuver({
    required int type,
    required String instruction,
    required double length,
    required double time,
    @JsonKey(name: 'begin_shape_index') required int beginShapeIndex,
    @JsonKey(name: 'end_shape_index') required int endShapeIndex,
    @JsonKey(name: 'travel_mode') required String travelMode,
    @JsonKey(name: 'street_names') List<String>? streetNames,
    @JsonKey(name: 'begin_street_names') List<String>? beginStreetNames,
    @JsonKey(name: 'verbal_transition_alert_instruction') String? verbalTransitionAlertInstruction,
    @JsonKey(name: 'verbal_pre_transition_instruction') String? verbalPreTransitionInstruction,
    @JsonKey(name: 'verbal_post_transition_instruction') String? verbalPostTransitionInstruction,
    @JsonKey(name: 'verbal_succinct_transition_instruction') String? verbalSuccinctTransitionInstruction,
    @JsonKey(name: 'verbal_multi_cue') @Default(false) bool verbalMultiCue,
    @JsonKey(name: 'roundabout_exit_count') int? roundaboutExitCount,
    @JsonKey(name: 'depart_instruction') String? departInstruction,
    @JsonKey(name: 'verbal_depart_instruction') String? verbalDepartInstruction,
    @JsonKey(name: 'arrive_instruction') String? arriveInstruction,
    @JsonKey(name: 'verbal_arrive_instruction') String? verbalArriveInstruction,
    @Default(false) bool toll,
    @Default(false) bool gate,
    @Default(false) bool ferry,
    List<ValhallaLane>? lanes,
    @JsonKey(name: 'bearing_before') double? bearingBefore,
    @JsonKey(name: 'bearing_after') double? bearingAfter,
    @JsonKey(name: 'bss_maneuver_type') String? bssManeuverType,
  }) = _Maneuver;

  factory Maneuver.fromJson(Map<String, dynamic> json) => _$ManeuverFromJson(json);
}

@freezed
abstract class ValhallaLane with _$ValhallaLane {
  const factory ValhallaLane({
    required int directions, // Bitmask
    int? valid, // Bitmask, optional
    int? active, // Bitmask, optional
  }) = _ValhallaLane;
  factory ValhallaLane.fromJson(Map<String, dynamic> json) => _$ValhallaLaneFromJson(json);
}

@freezed
abstract class Summary with _$Summary {
  const factory Summary({
    required double length,
    required int time,
    @JsonKey(name: 'has_toll') @Default(false) bool hasToll,
    @JsonKey(name: 'has_highway') @Default(false) bool hasHighway, // Kept for info, even if routing profile avoids them
    @JsonKey(name: 'has_ferry') @Default(false) bool hasFerry,
    @JsonKey(name: 'min_lat') double? minLat,
    @JsonKey(name: 'min_lon') double? minLon,
    @JsonKey(name: 'max_lat') double? maxLat,
    @JsonKey(name: 'max_lon') double? maxLon,
  }) = _Summary;

  factory Summary.fromJson(Map<String, dynamic> json) => _$SummaryFromJson(json);
}

@freezed
abstract class ValhallaTripLocation with _$ValhallaTripLocation {
  const factory ValhallaTripLocation({
    required double lat,
    required double lon,
    String? type, // "break", "through", etc.
    String? name,
    String? street,
    String? city,
    String? state,
    @JsonKey(name: 'postal_code') String? postalCode,
    String? country,
    @JsonKey(name: 'side_of_street') String? sideOfStreet,
    @JsonKey(name: 'date_time') String? dateTime, // ISO 8601 format
    @JsonKey(name: 'original_index') int? originalIndex, // Index from the input locations
  }) = _ValhallaTripLocation;

  factory ValhallaTripLocation.fromJson(Map<String, dynamic> json) => _$ValhallaTripLocationFromJson(json);
}
