// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valhalla_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ValhallaResponse _$ValhallaResponseFromJson(Map<String, dynamic> json) =>
    _ValhallaResponse(
      trip: Trip.fromJson(json['trip'] as Map<String, dynamic>),
      id: json['id'] as String?,
      units: json['units'] as String?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$ValhallaResponseToJson(_ValhallaResponse instance) =>
    <String, dynamic>{
      'trip': instance.trip,
      'id': instance.id,
      'units': instance.units,
      'language': instance.language,
    };

_Trip _$TripFromJson(Map<String, dynamic> json) => _Trip(
      legs: (json['legs'] as List<dynamic>)
          .map((e) => Leg.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
      locations: (json['locations'] as List<dynamic>)
          .map((e) => ValhallaTripLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TripToJson(_Trip instance) => <String, dynamic>{
      'legs': instance.legs,
      'summary': instance.summary,
      'locations': instance.locations,
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
      instruction: json['instruction'] as String,
      length: (json['length'] as num).toDouble(),
      time: (json['time'] as num).toDouble(),
      beginShapeIndex: (json['begin_shape_index'] as num).toInt(),
      endShapeIndex: (json['end_shape_index'] as num).toInt(),
      travelMode: json['travel_mode'] as String,
      streetNames: (json['street_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      beginStreetNames: (json['begin_street_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      verbalTransitionAlertInstruction:
          json['verbal_transition_alert_instruction'] as String?,
      verbalPreTransitionInstruction:
          json['verbal_pre_transition_instruction'] as String?,
      verbalPostTransitionInstruction:
          json['verbal_post_transition_instruction'] as String?,
      verbalSuccinctTransitionInstruction:
          json['verbal_succinct_transition_instruction'] as String?,
      verbalMultiCue: json['verbal_multi_cue'] as bool? ?? false,
      roundaboutExitCount: (json['roundabout_exit_count'] as num?)?.toInt(),
      departInstruction: json['depart_instruction'] as String?,
      verbalDepartInstruction: json['verbal_depart_instruction'] as String?,
      arriveInstruction: json['arrive_instruction'] as String?,
      verbalArriveInstruction: json['verbal_arrive_instruction'] as String?,
      toll: json['toll'] as bool? ?? false,
      gate: json['gate'] as bool? ?? false,
      ferry: json['ferry'] as bool? ?? false,
      lanes: (json['lanes'] as List<dynamic>?)
          ?.map((e) => ValhallaLane.fromJson(e as Map<String, dynamic>))
          .toList(),
      bearingBefore: (json['bearing_before'] as num?)?.toDouble(),
      bearingAfter: (json['bearing_after'] as num?)?.toDouble(),
      bssManeuverType: json['bss_maneuver_type'] as String?,
    );

Map<String, dynamic> _$ManeuverToJson(_Maneuver instance) => <String, dynamic>{
      'type': instance.type,
      'instruction': instance.instruction,
      'length': instance.length,
      'time': instance.time,
      'begin_shape_index': instance.beginShapeIndex,
      'end_shape_index': instance.endShapeIndex,
      'travel_mode': instance.travelMode,
      'street_names': instance.streetNames,
      'begin_street_names': instance.beginStreetNames,
      'verbal_transition_alert_instruction':
          instance.verbalTransitionAlertInstruction,
      'verbal_pre_transition_instruction':
          instance.verbalPreTransitionInstruction,
      'verbal_post_transition_instruction':
          instance.verbalPostTransitionInstruction,
      'verbal_succinct_transition_instruction':
          instance.verbalSuccinctTransitionInstruction,
      'verbal_multi_cue': instance.verbalMultiCue,
      'roundabout_exit_count': instance.roundaboutExitCount,
      'depart_instruction': instance.departInstruction,
      'verbal_depart_instruction': instance.verbalDepartInstruction,
      'arrive_instruction': instance.arriveInstruction,
      'verbal_arrive_instruction': instance.verbalArriveInstruction,
      'toll': instance.toll,
      'gate': instance.gate,
      'ferry': instance.ferry,
      'lanes': instance.lanes,
      'bearing_before': instance.bearingBefore,
      'bearing_after': instance.bearingAfter,
      'bss_maneuver_type': instance.bssManeuverType,
    };

_ValhallaLane _$ValhallaLaneFromJson(Map<String, dynamic> json) =>
    _ValhallaLane(
      directions: (json['directions'] as num).toInt(),
      valid: (json['valid'] as num?)?.toInt(),
      active: (json['active'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ValhallaLaneToJson(_ValhallaLane instance) =>
    <String, dynamic>{
      'directions': instance.directions,
      'valid': instance.valid,
      'active': instance.active,
    };

_Summary _$SummaryFromJson(Map<String, dynamic> json) => _Summary(
      length: (json['length'] as num).toDouble(),
      time: (json['time'] as num).toInt(),
      hasToll: json['has_toll'] as bool? ?? false,
      hasHighway: json['has_highway'] as bool? ?? false,
      hasFerry: json['has_ferry'] as bool? ?? false,
      minLat: (json['min_lat'] as num?)?.toDouble(),
      minLon: (json['min_lon'] as num?)?.toDouble(),
      maxLat: (json['max_lat'] as num?)?.toDouble(),
      maxLon: (json['max_lon'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SummaryToJson(_Summary instance) => <String, dynamic>{
      'length': instance.length,
      'time': instance.time,
      'has_toll': instance.hasToll,
      'has_highway': instance.hasHighway,
      'has_ferry': instance.hasFerry,
      'min_lat': instance.minLat,
      'min_lon': instance.minLon,
      'max_lat': instance.maxLat,
      'max_lon': instance.maxLon,
    };

_ValhallaTripLocation _$ValhallaTripLocationFromJson(
        Map<String, dynamic> json) =>
    _ValhallaTripLocation(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      type: json['type'] as String?,
      name: json['name'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      sideOfStreet: json['side_of_street'] as String?,
      dateTime: json['date_time'] as String?,
      originalIndex: (json['original_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ValhallaTripLocationToJson(
        _ValhallaTripLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'type': instance.type,
      'name': instance.name,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'side_of_street': instance.sideOfStreet,
      'date_time': instance.dateTime,
      'original_index': instance.originalIndex,
    };
