// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
      id: json['id'] as String,
      coordinates: LatLng.fromJson(json['coordinates'] as Map<String, dynamic>),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
      'id': instance.id,
      'coordinates': instance.coordinates,
      'x': instance.x,
      'y': instance.y,
    };
