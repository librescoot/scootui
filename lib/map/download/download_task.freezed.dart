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
mixin _$DownloadTask {
  String get url;
  String get destination;
  String? get description;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadTaskCopyWith<DownloadTask> get copyWith =>
      _$DownloadTaskCopyWithImpl<DownloadTask>(
          this as DownloadTask, _$identity);

  @override
  String toString() {
    return 'DownloadTask(url: $url, destination: $destination, description: $description)';
  }
}

/// @nodoc
abstract mixin class $DownloadTaskCopyWith<$Res> {
  factory $DownloadTaskCopyWith(
          DownloadTask value, $Res Function(DownloadTask) _then) =
      _$DownloadTaskCopyWithImpl;
  @useResult
  $Res call({String url, String destination, String? description});
}

/// @nodoc
class _$DownloadTaskCopyWithImpl<$Res> implements $DownloadTaskCopyWith<$Res> {
  _$DownloadTaskCopyWithImpl(this._self, this._then);

  final DownloadTask _self;
  final $Res Function(DownloadTask) _then;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? destination = null,
    Object? description = freezed,
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
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _DownloadTask extends DownloadTask {
  _DownloadTask(
      {required this.url, required this.destination, this.description})
      : super._();

  @override
  final String url;
  @override
  final String destination;
  @override
  final String? description;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadTaskCopyWith<_DownloadTask> get copyWith =>
      __$DownloadTaskCopyWithImpl<_DownloadTask>(this, _$identity);

  @override
  String toString() {
    return 'DownloadTask(url: $url, destination: $destination, description: $description)';
  }
}

/// @nodoc
abstract mixin class _$DownloadTaskCopyWith<$Res>
    implements $DownloadTaskCopyWith<$Res> {
  factory _$DownloadTaskCopyWith(
          _DownloadTask value, $Res Function(_DownloadTask) _then) =
      __$DownloadTaskCopyWithImpl;
  @override
  @useResult
  $Res call({String url, String destination, String? description});
}

/// @nodoc
class __$DownloadTaskCopyWithImpl<$Res>
    implements _$DownloadTaskCopyWith<$Res> {
  __$DownloadTaskCopyWithImpl(this._self, this._then);

  final _DownloadTask _self;
  final $Res Function(_DownloadTask) _then;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
    Object? destination = null,
    Object? description = freezed,
  }) {
    return _then(_DownloadTask(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
