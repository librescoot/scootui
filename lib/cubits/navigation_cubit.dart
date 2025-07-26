import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../config.dart';
import '../routing/models.dart';
import '../routing/route_helpers.dart';
import '../routing/valhalla.dart';
import '../services/toast_service.dart';
import '../state/gps.dart';
import '../state/navigation.dart';
import 'mdb_cubits.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  late final StreamSubscription<GpsData> _gpsSub;
  late final StreamSubscription<NavigationData> _navigationSub;
  final NavigationSync _navigationSync;

  static const double _arrivalProximityMeters = 100.0;
  static const double _offRouteTolerance = 40.0; // meters
  DateTime? _lastReroute;
  LatLng? _currentPosition;

  final distanceCalculator = Distance();

  NavigationCubit({
    required Stream<GpsData> gpsStream,
    required NavigationSync navigationSync,
  })  : _navigationSync = navigationSync,
        super(const NavigationState()) {
    _gpsSub = gpsStream.listen(_onGpsData);
    _navigationSub = _navigationSync.stream.listen(_onNavigationData);

    // Process initial navigation data if available
    _processInitialNavigationData();
  }

  @override
  Future<void> close() {
    _gpsSub.cancel();
    _navigationSub.cancel();
    return super.close();
  }

  void _processInitialNavigationData() {
    final initialData = _navigationSync.state;
    if (initialData.destination.isNotEmpty) {
      _onNavigationData(initialData);
    }
  }

  Future<void> _calculateRoute(LatLng destination) async {
    emit(state.copyWith(
      destination: destination,
      status: NavigationStatus.calculating,
      error: null,
    ));

    try {
      final position = _currentPosition;
      if (position == null) {
        const errorMsg = 'Current position not available';
        ToastService.showError(errorMsg);
        emit(state.copyWith(
          status: NavigationStatus.error,
          error: errorMsg,
        ));
        return;
      }

      final valhallaService =
          ValhallaService(serverURL: AppConfig.valhallaEndpoint);
      final route = await valhallaService.getRoute(position, destination);

      if (route.waypoints.isEmpty) {
        const errorMsg = 'Could not calculate route';
        ToastService.showError(errorMsg);
        emit(state.copyWith(
          status: NavigationStatus.error,
          error: errorMsg,
        ));
        return;
      }

      final upcomingInstructions =
          RouteHelpers.findUpcomingInstructions(position, route);
      final distanceToDestination = distanceCalculator.as(
        LengthUnit.Meter,
        position,
        destination,
      );

      emit(state.copyWith(
        route: route,
        upcomingInstructions: upcomingInstructions,
        status: NavigationStatus.navigating,
        distanceToDestination: distanceToDestination,
        error: null,
      ));
    } catch (e) {
      final errorMsg = 'Failed to calculate route: $e';
      ToastService.showError(errorMsg);
      emit(state.copyWith(
        status: NavigationStatus.error,
        error: errorMsg,
      ));
    }
  }

  Future<void> clearNavigation() async {
    emit(const NavigationState());
    await _navigationSync.clearDestination();
  }

  void _onNavigationData(NavigationData data) {
    // print("NavigationCubit: Received NavigationData: ${data.destination}");
    try {
      if (data.destination.isEmpty) {
        // print("NavigationCubit: Destination is empty, clearing navigation state.");
        // Clear navigation if destination is empty
        emit(const NavigationState());
        return;
      }

      final coordinates =
          data.destination.split(",").map(double.parse).toList();
      final destination = LatLng(coordinates[0], coordinates[1]);
      // print("NavigationCubit: Parsed destination: $destination");

      if (_currentPosition == null) {
        // print("NavigationCubit: Current position is null, cannot calculate route yet.");
        // Store pending destination and show conditions that need to be met
        emit(state.copyWith(
            destination: destination,
            status: NavigationStatus.idle,
            error: "Waiting for recent GPS fix to calculate route.",
            pendingConditions: [
              "GPS fix required (last update >10 seconds ago)"
            ]));
        return;
      }

      // If we are already actively navigating, rerouting, or calculating for the *same* destination, do nothing.
      if (state.destination == destination &&
          (state.status == NavigationStatus.navigating ||
              state.status == NavigationStatus.rerouting ||
              state.status == NavigationStatus.calculating)) {
        // print("NavigationCubit: Destination is the same and already actively navigating/processing.");
        return;
      }

      // If we have a current position, and the conditions above are not met (i.e., it's a new destination,
      // or it's the same destination but we are not actively navigating/processing it, e.g., status is idle, arrived, or error),
      // then calculate the route.
      if (_currentPosition != null) {
        // print(
        //     "NavigationCubit: Conditions met to calculate route. CurrentPos: $_currentPosition, NewDest: $destination, OldDest: ${state.destination}, Status: ${state.status}");
        ToastService.showInfo(
            'New navigation destination received. Calculating route...');
        // Clear pending conditions since we can now calculate route
        emit(state.copyWith(pendingConditions: []));
        _calculateRoute(destination);
      } else {
        // This case should be covered by the earlier _currentPosition == null check,
        // but kept for clarity if logic changes.
        // print(
        //     "NavigationCubit: Current position is null, cannot calculate route yet (should have been handled earlier). Dest: $destination");
        // State was already set if _currentPosition was null earlier.
      }
    } catch (e) {
      // print("NavigationCubit: Error processing navigation data: $e");
      final errorMsg = 'Error processing navigation data: $e';
      ToastService.showError(errorMsg);
      emit(state.copyWith(
        status: NavigationStatus.error,
        error: errorMsg,
      ));
    }
  }

  void _onGpsData(GpsData data) {
    // Only update position if GPS fix is recent (within 10 seconds)
    if (data.hasRecentFix) {
      final position = LatLng(data.latitude, data.longitude);
      _currentPosition = position;
    } else {
      _currentPosition = null;
    }

    final currentState = state;

    // If we have a destination but no route (which happens on startup with a pending destination),
    // and we just received a GPS position, it's time to calculate the route.
    if (currentState.destination != null && currentState.route == null) {
      // We check for idle or error status to ensure we only trigger this
      // if we're not already in the middle of a calculation or navigation.
      if (currentState.status == NavigationStatus.idle ||
          currentState.status == NavigationStatus.error) {
        // print("NavigationCubit (_onGpsData): Destination is pending and GPS is now available. Calculating route.");
        _calculateRoute(currentState.destination!);
        return; // Exit because _calculateRoute will emit the next state.
      }
    }

    // If we're not actively navigating or have no route, do nothing further.
    if (!currentState.isNavigating || currentState.route == null) {
      return;
    }

    // Update navigation state based on current position if available
    if (_currentPosition != null) {
      _updateNavigationState(_currentPosition!);
    }
  }

  void _updateNavigationState(LatLng position) {
    final route = state.route;
    final destination = state.destination;

    if (route == null || destination == null) {
      return;
    }

    // Calculate distance to destination
    final distanceToDestination = distanceCalculator.as(
      LengthUnit.Meter,
      position,
      destination,
    );

    // print("NavigationCubit: Distance to destination: ${distanceToDestination.toStringAsFixed(1)}m (threshold: ${_arrivalProximityMeters}m)");

    // Check if we've arrived
    if (distanceToDestination < _arrivalProximityMeters) {
      // print("NavigationCubit: Arrival detected! Distance: ${distanceToDestination.toStringAsFixed(1)}m");
      ToastService.showSuccess('You have arrived at your destination!');
      emit(state.copyWith(
        status: NavigationStatus.arrived,
        distanceToDestination: distanceToDestination,
      ));
      return;
    }

    // Find closest point on route and check for deviation
    final (closestPoint, segmentIndex, distanceFromRoute) =
        RouteHelpers.findClosestPointOnRoute(
      position,
      route.waypoints,
    );

    // Debug logging for off-route detection
    // print(
    //     "NavigationCubit: Position: $position, Distance from route: ${distanceFromRoute.toStringAsFixed(1)}m, Tolerance: ${_offRouteTolerance}m");

    // Check if we're off route
    final isOffRoute = distanceFromRoute > _offRouteTolerance;
    // print("NavigationCubit: isOffRoute: $isOffRoute, current state isOffRoute: ${state.isOffRoute}");

    // Calculate snapped position - use closest point on route when on-route, original position when off-route
    final snappedPosition = isOffRoute ? position : closestPoint;
    if (!isOffRoute) {
      // print("NavigationCubit: Snapping to route - Original: $position, Snapped: $snappedPosition");
    }

    // Find upcoming instructions
    var upcomingInstructions =
        RouteHelpers.findUpcomingInstructions(position, route);

    // If off-route, insert a "return to route" instruction at the beginning
    if (isOffRoute) {
      final returnInstruction = RouteInstruction.other(
        distance: distanceFromRoute,
        location: closestPoint,
        originalShapeIndex: 0,
        instructionText: "Return to the route",
      );
      upcomingInstructions = [returnInstruction, ...upcomingInstructions];
      // print(
      //     "NavigationCubit: Added return instruction. First instruction: ${upcomingInstructions.first.instructionText}, distance: ${upcomingInstructions.first.distance}");
    }

    emit(state.copyWith(
      upcomingInstructions: upcomingInstructions,
      distanceToDestination: distanceToDestination,
      distanceFromRoute: distanceFromRoute,
      isOffRoute: isOffRoute,
      snappedPosition: snappedPosition,
    ));

    // Check if we need to reroute
    if (isOffRoute &&
        (_lastReroute == null ||
            DateTime.now().difference(_lastReroute!) >
                const Duration(seconds: 5))) {
      ToastService.showWarning('Off route. Attempting to reroute...');
      _reroute(position, destination);
    }
  }

  Future<void> _reroute(LatLng position, LatLng destination) async {
    _lastReroute = DateTime.now();

    emit(state.copyWith(status: NavigationStatus.rerouting));

    try {
      final valhallaService =
          ValhallaService(serverURL: AppConfig.valhallaEndpoint);
      final route = await valhallaService.getRoute(position, destination);

      if (route.waypoints.isEmpty) {
        const errorMsg = 'Could not calculate new route';
        ToastService.showError(errorMsg);
        emit(state.copyWith(
          status: NavigationStatus.error,
          error: errorMsg,
        ));
        return;
      }

      emit(state.copyWith(
        route: route,
        status: NavigationStatus.navigating,
        error: null,
      ));

      // Recalculate navigation state with the new route
      _updateNavigationState(position);
    } catch (e) {
      final errorMsg = 'Failed to reroute: $e';
      ToastService.showError(errorMsg);
      emit(state.copyWith(
        status: NavigationStatus.error,
        error: errorMsg,
      ));
    }
  }
}
