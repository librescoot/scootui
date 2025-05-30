// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valhalla_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ValhallaResponse _$ValhallaResponseFromJson(Map<String, dynamic> json) =>
    _ValhallaResponse(
      trip: Trip.fromJson(json['trip'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ValhallaResponseToJson(_ValhallaResponse instance) =>
    <String, dynamic>{
      'trip': instance.trip,
    };

_Trip _$TripFromJson(Map<String, dynamic> json) => _Trip(
      legs: (json['legs'] as List<dynamic>)
          .map((e) => Leg.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TripToJson(_Trip instance) => <String, dynamic>{
      'legs': instance.legs,
    };

_Leg _$LegFromJson(Map<String, dynamic> json) => _Leg(
      maneuvers: (json['maneuvers'] as List<dynamic>)
          .map((e) => Maneuver.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      shape: json['shape'] as String,
    );

Map<String, dynamic> _$LegToJson(_Leg instance) => <String, dynamic>{
      'maneuvers': instance.maneuvers,
      'summary': instance.summary,
      'shape': instance.shape,
    };

_Maneuver _$ManeuverFromJson(Map<String, dynamic> json) => _Maneuver(
      type: (json['type'] as num).toInt(),
      length: (json['length'] as num).toDouble(),
      beginShapeIndex: (json['begin_shape_index'] as num?)?.toInt(),
      roundaboutExitCount: (json['roundabout_exit_count'] as num?)?.toInt(),
      instruction: json['instruction'] as String?,
      verbalPreTransitionInstruction:
          json['verbal_pre_transition_instruction'] as String?,
      verbalSuccinctTransitionInstruction:
          json['verbal_succinct_transition_instruction'] as String?,
      streetNames: (json['street_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      beginStreetNames: (json['begin_street_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ManeuverToJson(_Maneuver instance) => <String, dynamic>{
      'type': instance.type,
      'length': instance.length,
      'begin_shape_index': instance.beginShapeIndex,
      'roundabout_exit_count': instance.roundaboutExitCount,
      'instruction': instance.instruction,
      'verbal_pre_transition_instruction':
          instance.verbalPreTransitionInstruction,
      'verbal_succinct_transition_instruction':
          instance.verbalSuccinctTransitionInstruction,
      'street_names': instance.streetNames,
      'begin_street_names': instance.beginStreetNames,
    };

_Summary _$SummaryFromJson(Map<String, dynamic> json) => _Summary(
      length: (json['length'] as num).toDouble(),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$SummaryToJson(_Summary instance) => <String, dynamic>{
      'length': instance.length,
      'time': instance.time,
    };
