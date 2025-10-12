import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/navigation_cubit.dart';
import '../../cubits/navigation_state.dart';
import '../../routing/models.dart';
import 'roundabout_icon_painter.dart';

class TurnByTurnWidget extends StatelessWidget {
  final bool compact;
  final EdgeInsets? padding;

  const TurnByTurnWidget({
    super.key,
    this.compact = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        // Show pending conditions if navigation is idle but has destination
        if (state.status == NavigationStatus.idle && state.hasDestination && state.hasPendingConditions) {
          return Container(
            padding: padding ?? const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.orange.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: compact ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Navigation Pending",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...state.pendingConditions.map((condition) => Text(
                        "• $condition",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        if (!state.hasInstructions || state.status == NavigationStatus.idle) {
          return const SizedBox.shrink();
        }

        // Special handling for rerouting status - just show small box
        if (state.status == NavigationStatus.rerouting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.orange.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recalculating route...',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Special handling for arrival status
        if (state.status == NavigationStatus.arrived) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.green.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.place,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'You have arrived!',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // Return the two-box layout directly, no wrapper
        return compact ? _buildCompactView(state, isDark) : _buildFullView(state, isDark);
      },
    );
  }

  Widget _buildCompactView(NavigationState state, bool isDark) {
    final instructions = state.upcomingInstructions;
    if (instructions.isEmpty) return const SizedBox.shrink();
    final instruction = instructions.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact: icon above, distance below
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInstructionIcon(instruction, size: 24, isDark: isDark),
            const SizedBox(height: 2),
            Text(
              _formatDistance(instruction.distance),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullView(NavigationState state, bool isDark) {
    final instructions = state.upcomingInstructions;
    if (instructions.isEmpty) return const SizedBox.shrink();
    final instruction = instructions.first;
    final nextInstruction = instructions.length > 1 ? instructions[1] : null;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background: Instruction text box (full width, behind icon box)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 90, right: 12, top: 14, bottom: 14),
            constraints: const BoxConstraints(minHeight: 80), // Ensure minimum height
            decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getInstructionText(instruction, null),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 15,
                  fontWeight: isDark ? FontWeight.normal : FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (nextInstruction != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Then ${_getShortInstructionText(nextInstruction)}',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        // Foreground: Icon/distance box (layered on top, jutting out)
        Positioned(
          left: 0,
          top: -6,
          child: Container(
            width: 72, // Fixed narrow width
            constraints: const BoxConstraints(minHeight: 92), // Taller than instruction box
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInstructionIcon(instruction, size: 48, isDark: isDark),
                const SizedBox(height: 8),
                Text(
                  _formatDistance(instruction.distance),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildInstructionIcon(RouteInstruction instruction, {required double size, required bool isDark}) {
    IconData iconData;
    Color iconColor = isDark ? Colors.white : Colors.black87;

    // For long distances (>1km), show straight arrow
    if (instruction.distance > 1000) {
      iconData = Icons.straight;
    } else {
      switch (instruction) {
      case Keep(direction: final direction):
        iconData = switch (direction) {
          KeepDirection.straight => Icons.straight,
          KeepDirection.left => Icons.turn_slight_left,
          KeepDirection.right => Icons.turn_slight_right,
        };
        break;
      case Turn(direction: final direction):
        iconData = switch (direction) {
          TurnDirection.left => Icons.turn_left,
          TurnDirection.right => Icons.turn_right,
          TurnDirection.slightLeft => Icons.turn_slight_left,
          TurnDirection.slightRight => Icons.turn_slight_right,
          TurnDirection.sharpLeft => Icons.turn_sharp_left,
          TurnDirection.sharpRight => Icons.turn_sharp_right,
          TurnDirection.uTurn180 || TurnDirection.uTurn => Icons.u_turn_left,
          TurnDirection.rightUTurn => Icons.u_turn_right,
        };
        break;
      case Roundabout(side: final side, exitNumber: final exitNumber, bearingBefore: final bearingBefore):
        // Handle roundabout with custom widget below
        return _buildRoundaboutIcon(side, exitNumber, bearingBefore, size, isDark);
      case Exit(side: final side):
        iconData = side == ExitSide.left ? Icons.exit_to_app : Icons.exit_to_app;
        break;
      case Other():
        iconData = Icons.navigation;
        break;
      }
    }

    return Icon(
      iconData,
      color: iconColor,
      size: size,
    );
  }

  String _formatDistance(double distance) {
    if (distance > 500) {
      return '${((((distance + 99) ~/ 100) * 100) / 1000).toStringAsFixed(1)} km';
    } else if (distance > 100) {
      return '${(((distance + 99) ~/ 100) * 100)} m';
    } else if (distance > 10) {
      return '${(((distance + 9) ~/ 10) * 10)} m';
    } else {
      return '${distance.toInt()} m';
    }
  }

  String _getInstructionText(RouteInstruction instruction, [RouteInstruction? nextInstruction]) {
    // For long distances (>1km), show "Continue for X.X km" message
    if (instruction.distance > 1000) {
      final distanceKm = (instruction.distance / 1000).toStringAsFixed(1);
      return 'Continue for $distanceKm km';
    }

    // Use Valhalla's instruction text if available.
    String baseText = instruction.instructionText ?? '';

    // If Valhalla's text is empty, generate a fallback.
    if (baseText.isEmpty) {
      baseText = switch (instruction) {
        Keep(direction: final direction, streetName: final streetName) =>
          streetName != null ? 'Keep ${direction.name} on $streetName' : 'Keep ${direction.name}',
        Turn(direction: final direction, streetName: final streetName) =>
          streetName != null ? 'Turn ${direction.name} onto $streetName' : 'Turn ${direction.name}',
        Roundabout(exitNumber: final exitNumber, streetName: final streetName) =>
          streetName != null ? 'Take exit ${exitNumber} onto $streetName' : 'Take exit $exitNumber',
        Exit(side: final side, streetName: final streetName) =>
          streetName != null ? 'Take the ${side.name} exit to $streetName' : 'Take the ${side.name} exit',
        Other(streetName: final streetName) => streetName != null ? 'Continue on $streetName' : 'Continue',
      };
    }

    // Append the post-maneuver instruction if available.
    if (instruction.postInstructionText?.isNotEmpty == true) {
      // Ensure the base text ends correctly before appending.
      final cleanBaseText = baseText.endsWith('.') ? baseText.substring(0, baseText.length - 1) : baseText;
      return '$cleanBaseText. ${instruction.postInstructionText!}';
    }

    return baseText;
  }

  String _getShortInstructionText(RouteInstruction instruction) {
    // Generate short instruction text for "then" clauses
    return switch (instruction) {
      Keep(direction: final direction) => switch (direction) {
          KeepDirection.straight => 'continue straight',
          _ => 'keep ${direction.name}',
        },
      Turn(direction: final direction) => switch (direction) {
          TurnDirection.left => 'turn left',
          TurnDirection.right => 'turn right',
          TurnDirection.slightLeft => 'turn slightly left',
          TurnDirection.slightRight => 'turn slightly right',
          TurnDirection.sharpLeft => 'turn sharply left',
          TurnDirection.sharpRight => 'turn sharply right',
          TurnDirection.uTurn180 => 'make a U-turn',
          TurnDirection.rightUTurn => 'make a right U-turn',
          TurnDirection.uTurn => 'make a U-turn',
        },
      Roundabout(exitNumber: final exitNumber) =>
        'take the ${exitNumber == 1 ? '1st' : exitNumber == 2 ? '2nd' : exitNumber == 3 ? '3rd' : '${exitNumber}th'} exit',
      Other() => 'continue',
      Exit(side: final side) => 'take the ${side.name} exit',
    };
  }

  Widget _buildRoundaboutIcon(RoundaboutSide side, int exitNumber, double? bearingBefore, double size, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RoundaboutIconPainter(
          exitNumber: exitNumber,
          bearingBefore: bearingBefore,
          isDark: isDark,
          size: size,
        ),
      ),
    );
  }
}
