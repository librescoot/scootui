import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'models.dart';

class RouteHelpers {
  /// Finds the closest point on a line segment to a given point
  static LatLng findClosestPointOnSegment(
    LatLng point,
    LatLng segmentStart,
    LatLng segmentEnd,
  ) {
    // Convert to radians for calculations
    final lat1 = segmentStart.latitude * (math.pi / 180);
    final lon1 = segmentStart.longitude * (math.pi / 180);
    final lat2 = segmentEnd.latitude * (math.pi / 180);
    final lon2 = segmentEnd.longitude * (math.pi / 180);
    final lat3 = point.latitude * (math.pi / 180);
    final lon3 = point.longitude * (math.pi / 180);

    // Calculate vectors
    final dx = lon2 - lon1;
    final dy = lat2 - lat1;
    final len2 = dx * dx + dy * dy;

    if (len2 == 0) return segmentStart;

    // Calculate projection
    var t = ((lon3 - lon1) * dx + (lat3 - lat1) * dy) / len2;
    t = math.max(0, math.min(1, t));

    // Calculate the closest point
    final projLon = lon1 + t * dx;
    final projLat = lat1 + t * dy;

    // Convert back to degrees
    return LatLng(
      projLat * (180 / math.pi),
      projLon * (180 / math.pi),
    );
  }

  /// Finds the closest point on a route polyline to a given point
  static (LatLng, int, double) findClosestPointOnRoute(
    LatLng point,
    List<LatLng> polyline,
  ) {
    if (polyline.isEmpty) {
      throw ArgumentError('Polyline cannot be empty');
    }

    var closestPoint = LatLng(polyline.first.latitude, polyline.first.longitude);
    var closestDistance = double.infinity;
    var closestSegmentIndex = 0;

    for (var i = 0; i < polyline.length - 1; i++) {
      final segmentStart = LatLng(polyline[i].latitude, polyline[i].longitude);
      final segmentEnd = LatLng(polyline[i + 1].latitude, polyline[i + 1].longitude);

      final pointOnSegment = findClosestPointOnSegment(
        point,
        segmentStart,
        segmentEnd,
      );

      final distance = const Distance().as(
        LengthUnit.Meter,
        point,
        pointOnSegment,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestPoint = pointOnSegment;
        closestSegmentIndex = i;
      }
    }

    return (closestPoint, closestSegmentIndex, closestDistance);
  }

  /// Finds upcoming instructions based on the current position and route
  static List<RouteInstruction> findUpcomingInstructions(
    LatLng currentPosition,
    Route route, {
    int maxInstructions = 3,
  }) {
    if (route.waypoints.isEmpty) {
      return [];
    }

    // Find the closest point on the route
    final (closestPoint, segmentIndex, distanceFromRoute) = findClosestPointOnRoute(
      currentPosition,
      route.waypoints,
    );

    // Find upcoming instructions after the current segment
    return _findUpcomingInstructionsAfterSegment(
      route.instructions,
      route.waypoints,
      segmentIndex,
      closestPoint,
      maxInstructions,
    );
  }

  /// Helper to find upcoming instructions after a given segment
  static List<RouteInstruction> _findUpcomingInstructionsAfterSegment(
    List<RouteInstruction> instructions,
    List<LatLng> polyline,
    int segmentIndexToCompareAgainst,
    LatLng fromPoint,
    int maxInstructions,
  ) {
    final List<RouteInstruction> upcomingInstructions = [];

    for (final instruction in instructions) {
      if (upcomingInstructions.length >= maxInstructions) {
        break;
      }

      // Use the stored originalShapeIndex directly
      final int instructionShapeIndex = instruction.originalShapeIndex;

      // Ensure originalShapeIndex is valid before using
      if (instructionShapeIndex < 0) {
        continue; // Skip instructions that couldn't be properly mapped to the shape
      }

      // If the instruction's starting point is on or after the segment the user is currently on,
      // it's considered an upcoming or current instruction.
      if (instructionShapeIndex >= segmentIndexToCompareAgainst) {
        // Calculate distance to the instruction's starting point
        final instructionPoint = instruction.location;
        final distanceToManeuverStart = const Distance().as(
          LengthUnit.Meter,
          fromPoint,
          instructionPoint,
        );

        upcomingInstructions.add(instruction.copyWith(distance: distanceToManeuverStart));
      }
    }

    return upcomingInstructions;
  }
}
