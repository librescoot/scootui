import 'package:flutter/material.dart';

import '../../cubits/shutdown_cubit.dart';
import '../../l10n/l10n.dart';

class ShutdownContent extends StatelessWidget {
  final ShutdownStatus status;

  const ShutdownContent({super.key, required this.status});

  String _getStatusText(BuildContext context) {
    final l10n = context.l10n;
    switch (status) {
      case ShutdownStatus.shuttingDown:
        return l10n.shutdownShuttingDown;
      case ShutdownStatus.shutdownComplete:
        return l10n.shutdownComplete;
      case ShutdownStatus.suspending:
        return l10n.shutdownSuspending;
      case ShutdownStatus.hibernatingImminent:
        return l10n.shutdownHibernationImminent;
      case ShutdownStatus.suspendingImminent:
        return l10n.shutdownSuspensionImminent;
      case ShutdownStatus.backgroundProcessing:
        return l10n.shutdownProcessing;
      case ShutdownStatus.exiting:
      case ShutdownStatus.blackout:
      case ShutdownStatus.hidden:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == ShutdownStatus.hidden) {
      return const SizedBox.shrink();
    }

    final statusText = _getStatusText(context);

    final showSpinner = status != ShutdownStatus.shutdownComplete;

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinner (only show for active shutdown states, not shutdownComplete)
              if (showSpinner) ...[
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3.0,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Text
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
