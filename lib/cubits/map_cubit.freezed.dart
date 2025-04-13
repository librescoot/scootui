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
mixin _$RouteInstruction {
  double get distance;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<RouteInstruction> get copyWith =>
      _$RouteInstructionCopyWithImpl<RouteInstruction>(
          this as RouteInstruction, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RouteInstruction &&
            (identical(other.distance, distance) ||
                other.distance == distance));
  }

  @override
  int get hashCode => Object.hash(runtimeType, distance);

  @override
  String toString() {
    return 'RouteInstruction(distance: $distance)';
  }
}

/// @nodoc
abstract mixin class $RouteInstructionCopyWith<$Res> {
  factory $RouteInstructionCopyWith(
          RouteInstruction value, $Res Function(RouteInstruction) _then) =
      _$RouteInstructionCopyWithImpl;
  @useResult
  $Res call({double distance});
}

/// @nodoc
class _$RouteInstructionCopyWithImpl<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  _$RouteInstructionCopyWithImpl(this._self, this._then);

  final RouteInstruction _self;
  final $Res Function(RouteInstruction) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distance = null,
  }) {
    return _then(_self.copyWith(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class Straight extends RouteInstruction {
  const Straight({required this.distance}) : super._();

  @override
  final double distance;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StraightCopyWith<Straight> get copyWith =>
      _$StraightCopyWithImpl<Straight>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Straight &&
            (identical(other.distance, distance) ||
                other.distance == distance));
  }

  @override
  int get hashCode => Object.hash(runtimeType, distance);

  @override
  String toString() {
    return 'RouteInstruction.straight(distance: $distance)';
  }
}

/// @nodoc
abstract mixin class $StraightCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $StraightCopyWith(Straight value, $Res Function(Straight) _then) =
      _$StraightCopyWithImpl;
  @override
  @useResult
  $Res call({double distance});
}

/// @nodoc
class _$StraightCopyWithImpl<$Res> implements $StraightCopyWith<$Res> {
  _$StraightCopyWithImpl(this._self, this._then);

  final Straight _self;
  final $Res Function(Straight) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
  }) {
    return _then(Straight(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class Turn extends RouteInstruction {
  const Turn({required this.distance, required this.direction}) : super._();

  @override
  final double distance;
  final TurnDirection direction;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TurnCopyWith<Turn> get copyWith =>
      _$TurnCopyWithImpl<Turn>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Turn &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.direction, direction) ||
                other.direction == direction));
  }

  @override
  int get hashCode => Object.hash(runtimeType, distance, direction);

  @override
  String toString() {
    return 'RouteInstruction.turn(distance: $distance, direction: $direction)';
  }
}

/// @nodoc
abstract mixin class $TurnCopyWith<$Res>
    implements $RouteInstructionCopyWith<$Res> {
  factory $TurnCopyWith(Turn value, $Res Function(Turn) _then) =
      _$TurnCopyWithImpl;
  @override
  @useResult
  $Res call({double distance, TurnDirection direction});
}

/// @nodoc
class _$TurnCopyWithImpl<$Res> implements $TurnCopyWith<$Res> {
  _$TurnCopyWithImpl(this._self, this._then);

  final Turn _self;
  final $Res Function(Turn) _then;

  /// Create a copy of RouteInstruction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? direction = null,
  }) {
    return _then(Turn(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      direction: null == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as TurnDirection,
    ));
  }
}

/// @nodoc
mixin _$MapState {
  LatLng get position;
  double get orientation;
  MapController get controller;
  Route? get route;
  RouteInstruction? get nextInstruction;

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
                other.controller == controller) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.nextInstruction, nextInstruction) ||
                other.nextInstruction == nextInstruction));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, position, orientation, controller, route, nextInstruction);

  @override
  String toString() {
    return 'MapState(position: $position, orientation: $orientation, controller: $controller, route: $route, nextInstruction: $nextInstruction)';
  }
}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res> {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) =
      _$MapStateCopyWithImpl;
  @useResult
  $Res call(
      {LatLng position,
      double orientation,
      MapController controller,
      Route? route,
      RouteInstruction? nextInstruction});

  $RouteInstructionCopyWith<$Res>? get nextInstruction;
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
    Object? route = freezed,
    Object? nextInstruction = freezed,
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
      route: freezed == route
          ? _self.route
          : route // ignore: cast_nullable_to_non_nullable
              as Route?,
      nextInstruction: freezed == nextInstruction
          ? _self.nextInstruction
          : nextInstruction // ignore: cast_nullable_to_non_nullable
              as RouteInstruction?,
    ));
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<$Res>? get nextInstruction {
    if (_self.nextInstruction == null) {
      return null;
    }

    return $RouteInstructionCopyWith<$Res>(_self.nextInstruction!, (value) {
      return _then(_self.copyWith(nextInstruction: value));
    });
  }
}

/// @nodoc

class MapLoading implements MapState {
  const MapLoading(
      {required this.position,
      this.orientation = 0,
      required this.controller,
      this.route = null,
      this.nextInstruction = null});

  @override
  final LatLng position;
  @override
  @JsonKey()
  final double orientation;
  @override
  final MapController controller;
  @override
  @JsonKey()
  final Route? route;
  @override
  @JsonKey()
  final RouteInstruction? nextInstruction;

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
                other.controller == controller) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.nextInstruction, nextInstruction) ||
                other.nextInstruction == nextInstruction));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, position, orientation, controller, route, nextInstruction);

  @override
  String toString() {
    return 'MapState.loading(position: $position, orientation: $orientation, controller: $controller, route: $route, nextInstruction: $nextInstruction)';
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
  $Res call(
      {LatLng position,
      double orientation,
      MapController controller,
      Route? route,
      RouteInstruction? nextInstruction});

  @override
  $RouteInstructionCopyWith<$Res>? get nextInstruction;
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
    Object? route = freezed,
    Object? nextInstruction = freezed,
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
      route: freezed == route
          ? _self.route
          : route // ignore: cast_nullable_to_non_nullable
              as Route?,
      nextInstruction: freezed == nextInstruction
          ? _self.nextInstruction
          : nextInstruction // ignore: cast_nullable_to_non_nullable
              as RouteInstruction?,
    ));
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<$Res>? get nextInstruction {
    if (_self.nextInstruction == null) {
      return null;
    }

    return $RouteInstructionCopyWith<$Res>(_self.nextInstruction!, (value) {
      return _then(_self.copyWith(nextInstruction: value));
    });
  }
}

/// @nodoc

class MapUnavailable implements MapState {
  const MapUnavailable(this.error,
      {required this.position,
      this.orientation = 0,
      required this.controller,
      this.route = null,
      this.nextInstruction = null});

  final String error;
  @override
  final LatLng position;
  @override
  @JsonKey()
  final double orientation;
  @override
  final MapController controller;
  @override
  @JsonKey()
  final Route? route;
  @override
  @JsonKey()
  final RouteInstruction? nextInstruction;

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
                other.controller == controller) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.nextInstruction, nextInstruction) ||
                other.nextInstruction == nextInstruction));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error, position, orientation,
      controller, route, nextInstruction);

  @override
  String toString() {
    return 'MapState.unavailable(error: $error, position: $position, orientation: $orientation, controller: $controller, route: $route, nextInstruction: $nextInstruction)';
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
      MapController controller,
      Route? route,
      RouteInstruction? nextInstruction});

  @override
  $RouteInstructionCopyWith<$Res>? get nextInstruction;
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
    Object? route = freezed,
    Object? nextInstruction = freezed,
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
      route: freezed == route
          ? _self.route
          : route // ignore: cast_nullable_to_non_nullable
              as Route?,
      nextInstruction: freezed == nextInstruction
          ? _self.nextInstruction
          : nextInstruction // ignore: cast_nullable_to_non_nullable
              as RouteInstruction?,
    ));
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<$Res>? get nextInstruction {
    if (_self.nextInstruction == null) {
      return null;
    }

    return $RouteInstructionCopyWith<$Res>(_self.nextInstruction!, (value) {
      return _then(_self.copyWith(nextInstruction: value));
    });
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
      this.route = null,
      this.nextInstruction = null});

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
  @override
  @JsonKey()
  final Route? route;
  @override
  @JsonKey()
  final RouteInstruction? nextInstruction;

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
            (identical(other.route, route) || other.route == route) &&
            (identical(other.nextInstruction, nextInstruction) ||
                other.nextInstruction == nextInstruction));
  }

  @override
  int get hashCode => Object.hash(runtimeType, controller, position,
      orientation, mbTiles, theme, onReady, isReady, route, nextInstruction);

  @override
  String toString() {
    return 'MapState.offline(controller: $controller, position: $position, orientation: $orientation, mbTiles: $mbTiles, theme: $theme, onReady: $onReady, isReady: $isReady, route: $route, nextInstruction: $nextInstruction)';
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
      Route? route,
      RouteInstruction? nextInstruction});

  @override
  $RouteInstructionCopyWith<$Res>? get nextInstruction;
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
    Object? nextInstruction = freezed,
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
      nextInstruction: freezed == nextInstruction
          ? _self.nextInstruction
          : nextInstruction // ignore: cast_nullable_to_non_nullable
              as RouteInstruction?,
    ));
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<$Res>? get nextInstruction {
    if (_self.nextInstruction == null) {
      return null;
    }

    return $RouteInstructionCopyWith<$Res>(_self.nextInstruction!, (value) {
      return _then(_self.copyWith(nextInstruction: value));
    });
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
      this.route = null,
      this.nextInstruction = null});

  @override
  final LatLng position;
  @override
  final double orientation;
  @override
  final MapController controller;
  final void Function()? onReady;
  @JsonKey()
  final bool isReady;
  @override
  @JsonKey()
  final Route? route;
  @override
  @JsonKey()
  final RouteInstruction? nextInstruction;

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
            (identical(other.route, route) || other.route == route) &&
            (identical(other.nextInstruction, nextInstruction) ||
                other.nextInstruction == nextInstruction));
  }

  @override
  int get hashCode => Object.hash(runtimeType, position, orientation,
      controller, onReady, isReady, route, nextInstruction);

  @override
  String toString() {
    return 'MapState.online(position: $position, orientation: $orientation, controller: $controller, onReady: $onReady, isReady: $isReady, route: $route, nextInstruction: $nextInstruction)';
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
      Route? route,
      RouteInstruction? nextInstruction});

  @override
  $RouteInstructionCopyWith<$Res>? get nextInstruction;
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
    Object? nextInstruction = freezed,
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
      nextInstruction: freezed == nextInstruction
          ? _self.nextInstruction
          : nextInstruction // ignore: cast_nullable_to_non_nullable
              as RouteInstruction?,
    ));
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteInstructionCopyWith<$Res>? get nextInstruction {
    if (_self.nextInstruction == null) {
      return null;
    }

    return $RouteInstructionCopyWith<$Res>(_self.nextInstruction!, (value) {
      return _then(_self.copyWith(nextInstruction: value));
    });
  }
}

// dart format on
