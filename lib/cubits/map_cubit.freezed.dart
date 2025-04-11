// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapState {
  LatLng get position;
  double get orientation;
  MapController get controller;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapStateCopyWith<MapState> get copyWith =>
      _$MapStateCopyWithImpl<MapState>(this as MapState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapState &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation) &&
            (identical(other.controller, controller) ||
                other.controller == controller));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, position, orientation, controller);

  @override
  String toString() {
    return 'MapState(position: $position, orientation: $orientation, controller: $controller)';
  }
}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res> {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) =
      _$MapStateCopyWithImpl;
  @useResult
  $Res call({LatLng position, double orientation, MapController controller});
}

/// @nodoc
class _$MapStateCopyWithImpl<$Res> implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._self, this._then);

  final MapState _self;
  final $Res Function(MapState) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? orientation = null,
    Object? controller = null,
  }) {
    return _then(_self.copyWith(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as LatLng,
      orientation: null == orientation
          ? _self.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as double,
      controller: null == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as MapController,
    ));
  }
}

/// @nodoc

class MapLoading implements MapState {
  const MapLoading(
      {required this.position, this.orientation = 0, required this.controller});

  @override
  final LatLng position;
  @override
  @JsonKey()
  final double orientation;
  @override
  final MapController controller;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapLoadingCopyWith<MapLoading> get copyWith =>
      _$MapLoadingCopyWithImpl<MapLoading>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapLoading &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation) &&
            (identical(other.controller, controller) ||
                other.controller == controller));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, position, orientation, controller);

  @override
  String toString() {
    return 'MapState.loading(position: $position, orientation: $orientation, controller: $controller)';
  }
}

/// @nodoc
abstract mixin class $MapLoadingCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory $MapLoadingCopyWith(
          MapLoading value, $Res Function(MapLoading) _then) =
      _$MapLoadingCopyWithImpl;
  @override
  @useResult
  $Res call({LatLng position, double orientation, MapController controller});
}

/// @nodoc
class _$MapLoadingCopyWithImpl<$Res> implements $MapLoadingCopyWith<$Res> {
  _$MapLoadingCopyWithImpl(this._self, this._then);

  final MapLoading _self;
  final $Res Function(MapLoading) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? position = null,
    Object? orientation = null,
    Object? controller = null,
  }) {
    return _then(MapLoading(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as LatLng,
      orientation: null == orientation
          ? _self.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as double,
      controller: null == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as MapController,
    ));
  }
}

/// @nodoc

class MapUnavailable implements MapState {
  const MapUnavailable(this.error,
      {required this.position, this.orientation = 0, required this.controller});

  final String error;
  @override
  final LatLng position;
  @override
  @JsonKey()
  final double orientation;
  @override
  final MapController controller;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapUnavailableCopyWith<MapUnavailable> get copyWith =>
      _$MapUnavailableCopyWithImpl<MapUnavailable>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapUnavailable &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation) &&
            (identical(other.controller, controller) ||
                other.controller == controller));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, error, position, orientation, controller);

  @override
  String toString() {
    return 'MapState.unavailable(error: $error, position: $position, orientation: $orientation, controller: $controller)';
  }
}

/// @nodoc
abstract mixin class $MapUnavailableCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory $MapUnavailableCopyWith(
          MapUnavailable value, $Res Function(MapUnavailable) _then) =
      _$MapUnavailableCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String error,
      LatLng position,
      double orientation,
      MapController controller});
}

/// @nodoc
class _$MapUnavailableCopyWithImpl<$Res>
    implements $MapUnavailableCopyWith<$Res> {
  _$MapUnavailableCopyWithImpl(this._self, this._then);

  final MapUnavailable _self;
  final $Res Function(MapUnavailable) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
    Object? position = null,
    Object? orientation = null,
    Object? controller = null,
  }) {
    return _then(MapUnavailable(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as LatLng,
      orientation: null == orientation
          ? _self.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as double,
      controller: null == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as MapController,
    ));
  }
}

/// @nodoc

class MapOffline implements MapState {
  const MapOffline(
      {required this.controller,
      required this.position,
      required this.orientation,
      required this.mbTiles,
      required this.theme,
      this.onReady,
      this.isReady = false,
      this.route = null});

  @override
  final MapController controller;
  @override
  final LatLng position;
  @override
  final double orientation;
  final MbTiles mbTiles;
  final Theme theme;
  final void Function()? onReady;
  @JsonKey()
  final bool isReady;
  @JsonKey()
  final Route? route;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapOfflineCopyWith<MapOffline> get copyWith =>
      _$MapOfflineCopyWithImpl<MapOffline>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapOffline &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation) &&
            (identical(other.mbTiles, mbTiles) || other.mbTiles == mbTiles) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.onReady, onReady) || other.onReady == onReady) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.route, route) || other.route == route));
  }

  @override
  int get hashCode => Object.hash(runtimeType, controller, position,
      orientation, mbTiles, theme, onReady, isReady, route);

  @override
  String toString() {
    return 'MapState.offline(controller: $controller, position: $position, orientation: $orientation, mbTiles: $mbTiles, theme: $theme, onReady: $onReady, isReady: $isReady, route: $route)';
  }
}

/// @nodoc
abstract mixin class $MapOfflineCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory $MapOfflineCopyWith(
          MapOffline value, $Res Function(MapOffline) _then) =
      _$MapOfflineCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MapController controller,
      LatLng position,
      double orientation,
      MbTiles mbTiles,
      Theme theme,
      void Function()? onReady,
      bool isReady,
      Route? route});
}

/// @nodoc
class _$MapOfflineCopyWithImpl<$Res> implements $MapOfflineCopyWith<$Res> {
  _$MapOfflineCopyWithImpl(this._self, this._then);

  final MapOffline _self;
  final $Res Function(MapOffline) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? controller = null,
    Object? position = null,
    Object? orientation = null,
    Object? mbTiles = null,
    Object? theme = null,
    Object? onReady = freezed,
    Object? isReady = null,
    Object? route = freezed,
  }) {
    return _then(MapOffline(
      controller: null == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as MapController,
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as LatLng,
      orientation: null == orientation
          ? _self.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as double,
      mbTiles: null == mbTiles
          ? _self.mbTiles
          : mbTiles // ignore: cast_nullable_to_non_nullable
              as MbTiles,
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as Theme,
      onReady: freezed == onReady
          ? _self.onReady
          : onReady // ignore: cast_nullable_to_non_nullable
              as void Function()?,
      isReady: null == isReady
          ? _self.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      route: freezed == route
          ? _self.route
          : route // ignore: cast_nullable_to_non_nullable
              as Route?,
    ));
  }
}

/// @nodoc

class MapOnline implements MapState {
  const MapOnline(
      {required this.position,
      required this.orientation,
      required this.controller,
      this.onReady,
      this.isReady = false,
      this.route = null});

  @override
  final LatLng position;
  @override
  final double orientation;
  @override
  final MapController controller;
  final void Function()? onReady;
  @JsonKey()
  final bool isReady;
  @JsonKey()
  final Route? route;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapOnlineCopyWith<MapOnline> get copyWith =>
      _$MapOnlineCopyWithImpl<MapOnline>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapOnline &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation) &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.onReady, onReady) || other.onReady == onReady) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.route, route) || other.route == route));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, position, orientation, controller, onReady, isReady, route);

  @override
  String toString() {
    return 'MapState.online(position: $position, orientation: $orientation, controller: $controller, onReady: $onReady, isReady: $isReady, route: $route)';
  }
}

/// @nodoc
abstract mixin class $MapOnlineCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory $MapOnlineCopyWith(MapOnline value, $Res Function(MapOnline) _then) =
      _$MapOnlineCopyWithImpl;
  @override
  @useResult
  $Res call(
      {LatLng position,
      double orientation,
      MapController controller,
      void Function()? onReady,
      bool isReady,
      Route? route});
}

/// @nodoc
class _$MapOnlineCopyWithImpl<$Res> implements $MapOnlineCopyWith<$Res> {
  _$MapOnlineCopyWithImpl(this._self, this._then);

  final MapOnline _self;
  final $Res Function(MapOnline) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? position = null,
    Object? orientation = null,
    Object? controller = null,
    Object? onReady = freezed,
    Object? isReady = null,
    Object? route = freezed,
  }) {
    return _then(MapOnline(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as LatLng,
      orientation: null == orientation
          ? _self.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as double,
      controller: null == controller
          ? _self.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as MapController,
      onReady: freezed == onReady
          ? _self.onReady
          : onReady // ignore: cast_nullable_to_non_nullable
              as void Function()?,
      isReady: null == isReady
          ? _self.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      route: freezed == route
          ? _self.route
          : route // ignore: cast_nullable_to_non_nullable
              as Route?,
    ));
  }
}

// dart format on
