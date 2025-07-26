//
//  Generated code. Do not modify.
//  source: vector_tile.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use tileDescriptor instead')
const Tile$json = {
  '1': 'Tile',
  '2': [
    {'1': 'layers', '3': 3, '4': 3, '5': 11, '6': '.main.Tile.Layer', '10': 'layers'},
  ],
  '3': [Tile_Value$json, Tile_Feature$json, Tile_Layer$json],
  '4': [Tile_GeomType$json],
  '5': [
    {'1': 16, '2': 8192},
  ],
};

@$core.Deprecated('Use tileDescriptor instead')
const Tile_Value$json = {
  '1': 'Value',
  '2': [
    {'1': 'string_value', '3': 1, '4': 1, '5': 9, '10': 'stringValue'},
    {'1': 'float_value', '3': 2, '4': 1, '5': 2, '10': 'floatValue'},
    {'1': 'double_value', '3': 3, '4': 1, '5': 1, '10': 'doubleValue'},
    {'1': 'int_value', '3': 4, '4': 1, '5': 3, '10': 'intValue'},
    {'1': 'uint_value', '3': 5, '4': 1, '5': 4, '10': 'uintValue'},
    {'1': 'sint_value', '3': 6, '4': 1, '5': 18, '10': 'sintValue'},
    {'1': 'bool_value', '3': 7, '4': 1, '5': 8, '10': 'boolValue'},
  ],
  '5': [
    {'1': 8, '2': 536870912},
  ],
};

@$core.Deprecated('Use tileDescriptor instead')
const Tile_Feature$json = {
  '1': 'Feature',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 4, '7': '0', '10': 'id'},
    {
      '1': 'tags',
      '3': 2,
      '4': 3,
      '5': 13,
      '8': {'2': true},
      '10': 'tags',
    },
    {'1': 'type', '3': 3, '4': 1, '5': 14, '6': '.main.Tile.GeomType', '7': 'UNKNOWN', '10': 'type'},
    {
      '1': 'geometry',
      '3': 4,
      '4': 3,
      '5': 13,
      '8': {'2': true},
      '10': 'geometry',
    },
  ],
};

@$core.Deprecated('Use tileDescriptor instead')
const Tile_Layer$json = {
  '1': 'Layer',
  '2': [
    {'1': 'version', '3': 15, '4': 2, '5': 13, '7': '1', '10': 'version'},
    {'1': 'name', '3': 1, '4': 2, '5': 9, '10': 'name'},
    {'1': 'features', '3': 2, '4': 3, '5': 11, '6': '.main.Tile.Feature', '10': 'features'},
    {'1': 'keys', '3': 3, '4': 3, '5': 9, '10': 'keys'},
    {'1': 'values', '3': 4, '4': 3, '5': 11, '6': '.main.Tile.Value', '10': 'values'},
    {'1': 'extent', '3': 5, '4': 1, '5': 13, '7': '4096', '10': 'extent'},
  ],
  '5': [
    {'1': 16, '2': 536870912},
  ],
};

@$core.Deprecated('Use tileDescriptor instead')
const Tile_GeomType$json = {
  '1': 'GeomType',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'POINT', '2': 1},
    {'1': 'LINESTRING', '2': 2},
    {'1': 'POLYGON', '2': 3},
  ],
};

/// Descriptor for `Tile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tileDescriptor = $convert.base64Decode(
    'CgRUaWxlEigKBmxheWVycxgDIAMoCzIQLm1haW4uVGlsZS5MYXllclIGbGF5ZXJzGvIBCgVWYW'
    'x1ZRIhCgxzdHJpbmdfdmFsdWUYASABKAlSC3N0cmluZ1ZhbHVlEh8KC2Zsb2F0X3ZhbHVlGAIg'
    'ASgCUgpmbG9hdFZhbHVlEiEKDGRvdWJsZV92YWx1ZRgDIAEoAVILZG91YmxlVmFsdWUSGwoJaW'
    '50X3ZhbHVlGAQgASgDUghpbnRWYWx1ZRIdCgp1aW50X3ZhbHVlGAUgASgEUgl1aW50VmFsdWUS'
    'HQoKc2ludF92YWx1ZRgGIAEoElIJc2ludFZhbHVlEh0KCmJvb2xfdmFsdWUYByABKAhSCWJvb2'
    'xWYWx1ZSoICAgQgICAgAIahgEKB0ZlYXR1cmUSEQoCaWQYASABKAQ6ATBSAmlkEhYKBHRhZ3MY'
    'AiADKA1CAhABUgR0YWdzEjAKBHR5cGUYAyABKA4yEy5tYWluLlRpbGUuR2VvbVR5cGU6B1VOS0'
    '5PV05SBHR5cGUSHgoIZ2VvbWV0cnkYBCADKA1CAhABUghnZW9tZXRyeRrOAQoFTGF5ZXISGwoH'
    'dmVyc2lvbhgPIAIoDToBMVIHdmVyc2lvbhISCgRuYW1lGAEgAigJUgRuYW1lEi4KCGZlYXR1cm'
    'VzGAIgAygLMhIubWFpbi5UaWxlLkZlYXR1cmVSCGZlYXR1cmVzEhIKBGtleXMYAyADKAlSBGtl'
    'eXMSKAoGdmFsdWVzGAQgAygLMhAubWFpbi5UaWxlLlZhbHVlUgZ2YWx1ZXMSHAoGZXh0ZW50GA'
    'UgASgNOgQ0MDk2UgZleHRlbnQqCAgQEICAgIACIj8KCEdlb21UeXBlEgsKB1VOS05PV04QABIJ'
    'CgVQT0lOVBABEg4KCkxJTkVTVFJJTkcQAhILCgdQT0xZR09OEAMqBQgQEIBA');

