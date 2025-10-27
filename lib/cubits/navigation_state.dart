import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../routing/models.dart';

part 'navigation_state.freezed.dart';

enum NavigationStatus {
  idle,
  calculating,
  navigating,
  rerouting,
  arrived,
  error,
}

@freezed
abstract class NavigationState with _$NavigationState {
  const NavigationState._();

  const factory NavigationState({
    @Default(null) Route? route,
    @Default(null) RouteInstruction? currentInstruction,
    @Default([]) List<RouteInstruction> upcomingInstructions,
    @Default(null) LatLng? destination,
    @Default(null) String? destinationAddress,
    @Default(NavigationStatus.idle) NavigationStatus status,
    @Default(null) String? error,
    @Default(0.0) double distanceToDestination,
    @Default(0.0) double distanceFromRoute,
    @Default(false) bool isOffRoute,
    @Default(null) LatLng? snappedPosition,
    @Default([]) List<String> pendingConditions,
    @Default(null) String? currentStreetName,
    @Default(null) String? currentRoadType,
    @Default(null) String? currentSpeedLimit,
  }) = _NavigationState;

  bool get isNavigating => status == NavigationStatus.navigating;
  bool get hasRoute => route != null;
  bool get hasDestination => destination != null;
  bool get hasInstructions => currentInstruction != null || upcomingInstructions.isNotEmpty;
  bool get hasPendingConditions => pendingConditions.isNotEmpty;
}
