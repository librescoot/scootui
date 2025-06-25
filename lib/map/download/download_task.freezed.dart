// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapDownloadTask {
  String get url;
  String get destination;

  /// Create a copy of MapDownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapDownloadTaskCopyWith<MapDownloadTask> get copyWith =>
      _$MapDownloadTaskCopyWithImpl<MapDownloadTask>(
          this as MapDownloadTask, _$identity);

  @override
  String toString() {
    return 'MapDownloadTask(url: $url, destination: $destination)';
  }
}

/// @nodoc
abstract mixin class $MapDownloadTaskCopyWith<$Res> {
  factory $MapDownloadTaskCopyWith(
          MapDownloadTask value, $Res Function(MapDownloadTask) _then) =
      _$MapDownloadTaskCopyWithImpl;
  @useResult
  $Res call({String url, String destination});
}

/// @nodoc
class _$MapDownloadTaskCopyWithImpl<$Res>
    implements $MapDownloadTaskCopyWith<$Res> {
  _$MapDownloadTaskCopyWithImpl(this._self, this._then);

  final MapDownloadTask _self;
  final $Res Function(MapDownloadTask) _then;

  /// Create a copy of MapDownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? destination = null,
  }) {
    return _then(_self.copyWith(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _MapDownloadTask extends MapDownloadTask {
  _MapDownloadTask({required this.url, required this.destination}) : super._();

  @override
  final String url;
  @override
  final String destination;

  /// Create a copy of MapDownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MapDownloadTaskCopyWith<_MapDownloadTask> get copyWith =>
      __$MapDownloadTaskCopyWithImpl<_MapDownloadTask>(this, _$identity);

  @override
  String toString() {
    return 'MapDownloadTask(url: $url, destination: $destination)';
  }
}

/// @nodoc
abstract mixin class _$MapDownloadTaskCopyWith<$Res>
    implements $MapDownloadTaskCopyWith<$Res> {
  factory _$MapDownloadTaskCopyWith(
          _MapDownloadTask value, $Res Function(_MapDownloadTask) _then) =
      __$MapDownloadTaskCopyWithImpl;
  @override
  @useResult
  $Res call({String url, String destination});
}

/// @nodoc
class __$MapDownloadTaskCopyWithImpl<$Res>
    implements _$MapDownloadTaskCopyWith<$Res> {
  __$MapDownloadTaskCopyWithImpl(this._self, this._then);

  final _MapDownloadTask _self;
  final $Res Function(_MapDownloadTask) _then;

  /// Create a copy of MapDownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
    Object? destination = null,
  }) {
    return _then(_MapDownloadTask(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
