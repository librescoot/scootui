import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/navigation_cubit.dart';
import '../../cubits/navigation_state.dart';

class NavigationStatusOverlay extends StatelessWidget {
  const NavigationStatusOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        // Show pending conditions (GPS waiting, etc.)
        if (state.status == NavigationStatus.idle && state.hasDestination && state.hasPendingConditions) {
          return _buildStatusBox(
            isDark: isDark,
            color: Colors.orange,
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
                  state.pendingConditions.first,
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

        // Show rerouting status
        if (state.status == NavigationStatus.rerouting) {
          return _buildStatusBox(
            isDark: isDark,
            color: Colors.orange,
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

        // Show arrival message
        if (state.status == NavigationStatus.arrived) {
          return _buildStatusBox(
            isDark: isDark,
            color: Colors.green,
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

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatusBox({
    required bool isDark,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}
