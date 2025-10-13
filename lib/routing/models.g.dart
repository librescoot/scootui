// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Keep _$KeepFromJson(Map<String, dynamic> json) => Keep(
      distance: (json['distance'] as num).toDouble(),
      direction: $enumDecode(_$KeepDirectionEnumMap, json['direction']),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      originalShapeIndex: (json['originalShapeIndex'] as num).toInt(),
      streetName: json['streetName'] as String?,
      instructionText: json['instructionText'] as String?,
      postInstructionText: json['postInstructionText'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$KeepToJson(Keep instance) => <String, dynamic>{
      'distance': instance.distance,
      'direction': _$KeepDirectionEnumMap[instance.direction]!,
      'duration': instance.duration.inMicroseconds,
      'location': instance.location,
      'originalShapeIndex': instance.originalShapeIndex,
      'streetName': instance.streetName,
      'instructionText': instance.instructionText,
      'postInstructionText': instance.postInstructionText,
      'runtimeType': instance.$type,
    };

const _$KeepDirectionEnumMap = {
  KeepDirection.left: 'left',
  KeepDirection.right: 'right',
  KeepDirection.straight: 'straight',
};

Turn _$TurnFromJson(Map<String, dynamic> json) => Turn(
      distance: (json['distance'] as num).toDouble(),
      direction: $enumDecode(_$TurnDirectionEnumMap, json['direction']),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      originalShapeIndex: (json['originalShapeIndex'] as num).toInt(),
      streetName: json['streetName'] as String?,
      instructionText: json['instructionText'] as String?,
      postInstructionText: json['postInstructionText'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$TurnToJson(Turn instance) => <String, dynamic>{
      'distance': instance.distance,
      'direction': _$TurnDirectionEnumMap[instance.direction]!,
      'duration': instance.duration.inMicroseconds,
      'location': instance.location,
      'originalShapeIndex': instance.originalShapeIndex,
      'streetName': instance.streetName,
      'instructionText': instance.instructionText,
      'postInstructionText': instance.postInstructionText,
      'runtimeType': instance.$type,
    };

const _$TurnDirectionEnumMap = {
  TurnDirection.left: 'left',
  TurnDirection.right: 'right',
  TurnDirection.slightLeft: 'slightLeft',
  TurnDirection.slightRight: 'slightRight',
  TurnDirection.sharpLeft: 'sharpLeft',
  TurnDirection.sharpRight: 'sharpRight',
  TurnDirection.uTurn180: 'uTurn180',
  TurnDirection.rightUTurn: 'rightUTurn',
  TurnDirection.uTurn: 'uTurn',
};

Exit _$ExitFromJson(Map<String, dynamic> json) => Exit(
      distance: (json['distance'] as num).toDouble(),
      side: $enumDecode(_$ExitSideEnumMap, json['side']),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      originalShapeIndex: (json['originalShapeIndex'] as num).toInt(),
      streetName: json['streetName'] as String?,
      instructionText: json['instructionText'] as String?,
      postInstructionText: json['postInstructionText'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$ExitToJson(Exit instance) => <String, dynamic>{
      'distance': instance.distance,
      'side': _$ExitSideEnumMap[instance.side]!,
      'duration': instance.duration.inMicroseconds,
      'location': instance.location,
      'originalShapeIndex': instance.originalShapeIndex,
      'streetName': instance.streetName,
      'instructionText': instance.instructionText,
      'postInstructionText': instance.postInstructionText,
      'runtimeType': instance.$type,
    };

const _$ExitSideEnumMap = {
  ExitSide.left: 'left',
  ExitSide.right: 'right',
};

Merge _$MergeFromJson(Map<String, dynamic> json) => Merge(
      distance: (json['distance'] as num).toDouble(),
      direction: $enumDecode(_$MergeDirectionEnumMap, json['direction']),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      originalShapeIndex: (json['originalShapeIndex'] as num).toInt(),
      streetName: json['streetName'] as String?,
      instructionText: json['instructionText'] as String?,
      postInstructionText: json['postInstructionText'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$MergeToJson(Merge instance) => <String, dynamic>{
      'distance': instance.distance,
      'direction': _$MergeDirectionEnumMap[instance.direction]!,
      'duration': instance.duration.inMicroseconds,
      'location': instance.location,
      'originalShapeIndex': instance.originalShapeIndex,
      'streetName': instance.streetName,
      'instructionText': instance.instructionText,
      'postInstructionText': instance.postInstructionText,
      'runtimeType': instance.$type,
    };

const _$MergeDirectionEnumMap = {
  MergeDirection.straight: 'straight',
  MergeDirection.left: 'left',
  MergeDirection.right: 'right',
};

Roundabout _$RoundaboutFromJson(Map<String, dynamic> json) => Roundabout(
      distance: (json['distance'] as num).toDouble(),
      side: $enumDecode(_$RoundaboutSideEnumMap, json['side']),
      exitNumber: (json['exitNumber'] as num).toInt(),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      originalShapeIndex: (json['originalShapeIndex'] as num).toInt(),
      streetName: json['streetName'] as String?,
      instructionText: json['instructionText'] as String?,
      postInstructionText: json['postInstructionText'] as String?,
      bearingBefore: (json['bearingBefore'] as num?)?.toDouble(),
      bearingAfter: (json['bearingAfter'] as num?)?.toDouble(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$RoundaboutToJson(Roundabout instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'side': _$RoundaboutSideEnumMap[instance.side]!,
      'exitNumber': instance.exitNumber,
      'duration': instance.duration.inMicroseconds,
      'location': instance.location,
      'originalShapeIndex': instance.originalShapeIndex,
      'streetName': instance.streetName,
      'instructionText': instance.instructionText,
      'postInstructionText': instance.postInstructionText,
      'bearingBefore': instance.bearingBefore,
      'bearingAfter': instance.bearingAfter,
      'runtimeType': instance.$type,
    };

const _$RoundaboutSideEnumMap = {
  RoundaboutSide.left: 'left',
  RoundaboutSide.right: 'right',
};

Other _$OtherFromJson(Map<String, dynamic> json) => Other(
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
      location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
      originalShapeIndex: (json['originalShapeIndex'] as num).toInt(),
      streetName: json['streetName'] as String?,
      instructionText: json['instructionText'] as String?,
      postInstructionText: json['postInstructionText'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$OtherToJson(Other instance) => <String, dynamic>{
      'distance': instance.distance,
      'duration': instance.duration.inMicroseconds,
      'location': instance.location,
      'originalShapeIndex': instance.originalShapeIndex,
      'streetName': instance.streetName,
      'instructionText': instance.instructionText,
      'postInstructionText': instance.postInstructionText,
      'runtimeType': instance.$type,
    };

_Route _$RouteFromJson(Map<String, dynamic> json) => _Route(
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => RouteInstruction.fromJson(e as Map<String, dynamic>))
          .toList(),
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((e) => LatLng.fromJson(e as Map<String, dynamic>))
          .toList(),
      distance: (json['distance'] as num).toDouble(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$RouteToJson(_Route instance) => <String, dynamic>{
      'instructions': instance.instructions,
      'waypoints': instance.waypoints,
      'distance': instance.distance,
      'duration': instance.duration.inMicroseconds,
    };
