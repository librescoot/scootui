import 'package:dio/dio.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';
import 'valhalla_models.dart';

class ValhallaService {
  static const String _routeEndpoint = '/route';
  static const String _motorScooterCosting = 'motor_scooter';
  static const String _units = 'kilometers';
  static const String _language = 'en-US';
  static const int _connectTimeoutSeconds = 5;
  static const int _receiveTimeoutSeconds = 5;

  // Valhalla maneuver types that map to our instruction types
  static final Map<int, RouteInstruction Function(double, Duration, LatLng, int, String?, String?, String?, String?)> _maneuverMap = {
    // Start/Destination types (0-6) - map to Other
    0: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    1: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    2: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    3: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    4: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    5: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    6: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    7: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    8: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    9: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.slightRight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    10: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    11: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.sharpRight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    12: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.rightUTurn,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    13: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.uTurn,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    14: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.sharpLeft,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    15: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    16: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.slightLeft,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    17: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    18: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    19: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.turn(
          distance: distance,
          direction: TurnDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    20: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    21: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.exit(
          distance: distance,
          side: ExitSide.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    22: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    23: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    24: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.keep(
          distance: distance,
          direction: KeepDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    // Merge types (25, 37, 38)
    25: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.merge(
          distance: distance,
          direction: MergeDirection.straight,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    // Roundabout types (26, 27) - Type 26 handled specially in _createInstruction
    26: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.roundabout(
          distance: distance,
          side: RoundaboutSide.right,
          exitNumber: 1, // Placeholder - overridden in _createInstruction
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    27: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    // Ferry types (28, 29)
    28: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    29: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.other(
          distance: distance,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    // Merge directional types (37, 38)
    37: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.merge(
          distance: distance,
          direction: MergeDirection.right,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
    38: (distance, duration, location, index, streetName, instructionText, verbalAlert, verbal) => RouteInstruction.merge(
          distance: distance,
          direction: MergeDirection.left,
          duration: duration,
          location: location,
          originalShapeIndex: index,
          streetName: streetName,
          instructionText: instructionText,
          verbalAlertInstruction: verbalAlert,
          verbalInstruction: verbal,
        ),
  };

  final Dio _dio;
  final String serverURL;

  ValhallaService({required this.serverURL})
      : _dio = Dio(BaseOptions(
          baseUrl: serverURL,
          connectTimeout: Duration(seconds: _connectTimeoutSeconds),
          receiveTimeout: Duration(seconds: _receiveTimeoutSeconds),
        ));

  Future<Route> getRoute(LatLng start, LatLng end) async {
    final requestData = {
      'locations': [
        {'lat': start.latitude, 'lon': start.longitude},
        {'lat': end.latitude, 'lon': end.longitude}
      ],
      'costing': _motorScooterCosting,
      'units': _units,
      'language': _language,
      'directions_options': {
        'units': _units,
        'language': _language,
      }
    };

    // print('ValhallaService: Request to $serverURL$_routeEndpoint');
    // print('ValhallaService: Request data: $requestData');

    try {
      final response = await _dio.post(
        _routeEndpoint,
        data: requestData,
      );

      // print('ValhallaService: Response status: ${response.statusCode}');
      // print('ValhallaService: Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to get route from Valhalla');
      }

      final valhallaResponse = ValhallaResponse.fromJson(response.data);
      final leg = valhallaResponse.trip.legs.first;

    final List<LatLng> waypoints = [];
    final List<RouteInstruction> instructions = [];

    // Extract waypoints from shape
    final points =
        decodePolyline(leg.shape, accuracyExponent: 6).map((e) => LatLng(e[0].toDouble(), e[1].toDouble())).toList();
    waypoints.addAll(points);

    // Extract instructions
    for (final maneuver in leg.maneuvers) {
      final location = LatLng(
        points[maneuver.beginShapeIndex].latitude,
        points[maneuver.beginShapeIndex].longitude,
      );

      final distance = maneuver.length * 1000; // Convert to meters
      final duration = Duration(seconds: maneuver.time.toInt()); // Convert to Duration

      // Special handling for roundabout exit number if needed
      int exitCountForRoundabout = maneuver.roundaboutExitCount ?? 1; // Default to 1 if null

      final instruction = _createInstruction(maneuver, distance, duration, location, exitCountForRoundabout);
      if (instruction != null) {
        instructions.add(instruction);
      }
    }

    return Route(
      distance: leg.summary.length * 1000, // Convert to meters
      duration: Duration(seconds: leg.summary.time),
      waypoints: waypoints,
      instructions: instructions,
    );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('Connection to routing server timed out. Please try again.');
        case DioExceptionType.receiveTimeout:
          throw Exception('Routing server took too long to respond. Please try again.');
        case DioExceptionType.connectionError:
          throw Exception('Cannot connect to routing server. Check your connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 400) {
            throw Exception('Invalid route request. Destination may be unreachable.');
          } else if (statusCode == 429) {
            throw Exception('Too many routing requests. Please wait a moment.');
          } else if (statusCode != null && statusCode >= 500) {
            throw Exception('Routing server error. Please try again later.');
          }
          throw Exception('Routing request failed: ${e.response?.statusMessage ?? "Unknown error"}');
        case DioExceptionType.cancel:
          throw Exception('Routing request was cancelled.');
        default:
          throw Exception('Routing failed: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      throw Exception('Failed to calculate route: $e');
    }
  }

  RouteInstruction? _createInstruction(Maneuver maneuver, double distance, Duration duration, LatLng location, int roundaboutExitCount) {
    final type = maneuver.type;
    final streetName = _extractStreetName(maneuver);
    final instructionText = maneuver.instruction;
    final postInstructionText = maneuver.verbalPostTransitionInstruction;
    final verbalAlertInstruction = maneuver.verbalTransitionAlertInstruction;
    final verbalInstruction = maneuver.verbalPreTransitionInstruction;

    final instructionCreator = _maneuverMap[type];
    if (instructionCreator != null) {
      if (type == 26) {
        // ManeuverType.kRoundaboutEnter
        return RouteInstruction.roundabout(
          distance: distance,
          side: RoundaboutSide.right, // Default, Valhalla might not specify side for enter
          exitNumber: roundaboutExitCount,
          duration: duration,
          location: location,
          originalShapeIndex: maneuver.beginShapeIndex,
          streetName: streetName,
          instructionText: instructionText,
          postInstructionText: postInstructionText,
          bearingBefore: maneuver.bearingBefore,
          bearingAfter: maneuver.bearingAfter,
          verbalAlertInstruction: verbalAlertInstruction,
          verbalInstruction: verbalInstruction,
        );
      }
      // Pass all the extracted instruction fields to the creator
      return instructionCreator(distance, duration, location, maneuver.beginShapeIndex, streetName, instructionText, verbalAlertInstruction, verbalInstruction);
    }
    return RouteInstruction.other(
      distance: distance,
      duration: duration,
      location: location,
      originalShapeIndex: maneuver.beginShapeIndex,
      streetName: streetName,
      instructionText: instructionText,
      postInstructionText: postInstructionText,
      verbalAlertInstruction: verbalAlertInstruction,
      verbalInstruction: verbalInstruction,
    );
  }

  String? _extractStreetName(Maneuver maneuver) {
    // Try to get street name from streetNames first, fallback to beginStreetNames
    if (maneuver.streetNames?.isNotEmpty == true) {
      return maneuver.streetNames!.first;
    }
    if (maneuver.beginStreetNames?.isNotEmpty == true) {
      return maneuver.beginStreetNames!.first;
    }
    return null;
  }

}
