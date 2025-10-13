import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum VoiceHint implements Comparable<VoiceHint> {
  straight(1, "straight"), // continue (go straight)
  turnLeft(2, "turn_left"), // turn left
  slightTurnLeft(3, "slight_turn_left"), // turn slightly left
  sharpTurnLeft(4, "sharp_turn_left"), // turn sharply left
  turnRight(5, "turn_right"), // turn right
  slightTurnRight(6, "slight_turn_right"), // turn slightly right
  sharpTurnRight(7, "sharp_turn_right"), // turn sharply right
  keepLeft(8, "keep_left"), // keep left
  keepRight(9, "keep_right"), // keep right
  uTurn(10, "u_turn"), // U-turn
  rightUTurn(11, "right_u_turn"), // Right U-turn
  offRoute(12, "off_route"), // Off route
  roundabout(13, "roundabout"), // Roundabout
  roundaboutLeft(14, "roundabout_left"), // Roundabout left
  uTurn180(15, "u_turn_180"), // 180 degree u-turn
  beelineRouting(16, "beeline_routing"), // Beeline routing
  exitLeft(17, "exit_left"), // exit left
  exitRight(18, "exit_right"); // exit right

  const VoiceHint(this.code, this.action);

  final int code;
  final String action;

  @override
  int compareTo(VoiceHint other) => code.compareTo(other.code);

  factory VoiceHint.fromCode(int code) {
    return VoiceHint.values.firstWhere(
      (element) => element.code == code,
      orElse: () => throw ArgumentError(
        "Invalid code: $code. Valid codes are: ${VoiceHint.values.map((e) => e.code).toList()}",
      ),
    );
  }

  factory VoiceHint.fromAction(String action) {
    return VoiceHint.values.firstWhere(
      (element) => element.action == action,
      orElse: () => throw ArgumentError(
        "Invalid action: $action. Valid actions are: ${VoiceHint.values.map((e) => e.action).toList()}",
      ),
    );
  }
}

enum TurnDirection {
  left,
  right,
  slightLeft,
  slightRight,
  sharpLeft,
  sharpRight,
  uTurn180,
  rightUTurn,
  uTurn,
}

enum KeepDirection {
  left,
  right,
  straight,
}

enum ExitSide {
  left,
  right,
}

enum MergeDirection {
  straight,
  left,
  right,
}

enum RoundaboutSide {
  left,
  right,
}

@freezed
sealed class RouteInstruction with _$RouteInstruction {
  const RouteInstruction._();

  const factory RouteInstruction.keep({
    required double distance,
    required KeepDirection direction,
    @Default(Duration.zero) Duration duration,
    required LatLng location,
    required int originalShapeIndex,
    String? streetName,
    String? instructionText,
    String? postInstructionText,
    String? verbalAlertInstruction,
    String? verbalInstruction,
  }) = Keep;

  const factory RouteInstruction.turn({
    required double distance,
    required TurnDirection direction,
    @Default(Duration.zero) Duration duration,
    required LatLng location,
    required int originalShapeIndex,
    String? streetName,
    String? instructionText,
    String? postInstructionText,
    String? verbalAlertInstruction,
    String? verbalInstruction,
  }) = Turn;

  const factory RouteInstruction.exit({
    required double distance,
    required ExitSide side,
    @Default(Duration.zero) Duration duration,
    required LatLng location,
    required int originalShapeIndex,
    String? streetName,
    String? instructionText,
    String? postInstructionText,
    String? verbalAlertInstruction,
    String? verbalInstruction,
  }) = Exit;

  const factory RouteInstruction.merge({
    required double distance,
    required MergeDirection direction,
    @Default(Duration.zero) Duration duration,
    required LatLng location,
    required int originalShapeIndex,
    String? streetName,
    String? instructionText,
    String? postInstructionText,
    String? verbalAlertInstruction,
    String? verbalInstruction,
  }) = Merge;

  const factory RouteInstruction.roundabout({
    required double distance,
    required RoundaboutSide side,
    required int exitNumber,
    @Default(Duration.zero) Duration duration,
    required LatLng location,
    required int originalShapeIndex,
    String? streetName,
    String? instructionText,
    String? postInstructionText,
    double? bearingBefore,
    double? bearingAfter,
    String? verbalAlertInstruction,
    String? verbalInstruction,
  }) = Roundabout;

  const factory RouteInstruction.other({
    required double distance,
    @Default(Duration.zero) Duration duration,
    required LatLng location,
    required int originalShapeIndex,
    String? streetName,
    String? instructionText,
    String? postInstructionText,
    String? verbalAlertInstruction,
    String? verbalInstruction,
  }) = Other;

  factory RouteInstruction.fromHint(List<int> hint, List<LatLng> polyline) {
    // [
    //  2,        hint.indexInTrack
    //  2,        hint.getJsonCommandIndex(turnInstructionMode)
    //  0,        hint.getExitNumber()
    //  173.0,    hint.distanceToNext
    //  -89,      hint.angle
    // ]
    final [indexInTrack, jsonCommandIndex, exitNumber, distanceToNext, angle] = hint;

    final voiceHint = VoiceHint.fromCode(jsonCommandIndex);
    final location = polyline[indexInTrack];

    return switch (voiceHint) {
      VoiceHint.turnLeft ||
      VoiceHint.turnRight ||
      VoiceHint.slightTurnLeft ||
      VoiceHint.slightTurnRight ||
      VoiceHint.sharpTurnLeft ||
      VoiceHint.sharpTurnRight ||
      VoiceHint.uTurn180 ||
      VoiceHint.rightUTurn ||
      VoiceHint.uTurn =>
        RouteInstruction.turn(
          distance: distanceToNext.toDouble(),
          direction: switch (voiceHint) {
            VoiceHint.turnLeft => TurnDirection.left,
            VoiceHint.turnRight => TurnDirection.right,
            VoiceHint.slightTurnLeft => TurnDirection.slightLeft,
            VoiceHint.slightTurnRight => TurnDirection.slightRight,
            VoiceHint.sharpTurnLeft => TurnDirection.sharpLeft,
            VoiceHint.sharpTurnRight => TurnDirection.sharpRight,
            VoiceHint.uTurn180 => TurnDirection.uTurn180,
            VoiceHint.rightUTurn => TurnDirection.rightUTurn,
            VoiceHint.uTurn => TurnDirection.uTurn,
            _ => throw UnimplementedError(),
          },
          duration: Duration.zero,
          location: location,
          originalShapeIndex: indexInTrack,
        ),
      VoiceHint.straight || VoiceHint.keepLeft || VoiceHint.keepRight => RouteInstruction.keep(
          distance: distanceToNext.toDouble(),
          direction: switch (voiceHint) {
            VoiceHint.straight => KeepDirection.straight,
            VoiceHint.keepLeft => KeepDirection.left,
            VoiceHint.keepRight => KeepDirection.right,
            _ => throw UnimplementedError(),
          },
          duration: Duration.zero,
          location: location,
          originalShapeIndex: indexInTrack,
        ),
      VoiceHint.roundabout || VoiceHint.roundaboutLeft => RouteInstruction.roundabout(
          distance: distanceToNext.toDouble(),
          side: switch (voiceHint) {
            VoiceHint.roundabout => RoundaboutSide.left,
            VoiceHint.roundaboutLeft => RoundaboutSide.left,
            _ => throw UnimplementedError(),
          },
          exitNumber: exitNumber,
          duration: Duration.zero,
          location: location,
          originalShapeIndex: indexInTrack,
        ),
      VoiceHint.beelineRouting || VoiceHint.offRoute => RouteInstruction.other(
          distance: distanceToNext.toDouble(),
          duration: Duration.zero,
          location: location,
          originalShapeIndex: indexInTrack,
        ),
      VoiceHint.exitLeft || VoiceHint.exitRight => RouteInstruction.exit(
          distance: distanceToNext.toDouble(),
          side: switch (voiceHint) {
            VoiceHint.exitLeft => ExitSide.left,
            VoiceHint.exitRight => ExitSide.right,
            _ => throw UnimplementedError(),
          },
          duration: Duration.zero,
          location: location,
          originalShapeIndex: indexInTrack,
        )
    };
  }

  factory RouteInstruction.fromJson(Map<String, dynamic> json) => _$RouteInstructionFromJson(json);
}

@freezed
abstract class Route with _$Route {
  const factory Route({
    required List<RouteInstruction> instructions,
    required List<LatLng> waypoints,
    required double distance,
    required Duration duration,
  }) = _Route;

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
}
