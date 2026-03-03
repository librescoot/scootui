import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

class MaintenanceScreen extends StatelessWidget {
  final String? stateRaw;
  final bool showConnectionInfo;

  const MaintenanceScreen({
    super.key,
    this.stateRaw,
    this.showConnectionInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = showConnectionInfo
        ? Localizations.of<AppLocalizations>(context, AppLocalizations)
        : null;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: showConnectionInfo
                ? _buildConnectionInfo(l10n)
                : const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
          ),
          if (stateRaw != null && stateRaw!.isNotEmpty)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  stateRaw!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionInfo(AppLocalizations? l10n) {
    final title = l10n?.connectingTitle
        ?? 'Trying to connect to vehicle system...';
    final explanation = l10n?.connectingExplanation
        ?? 'This usually indicates a missing or unreliable connection between the dashboard computer (DBC) and the middle driver board (MDB). Check the USB cable if this persists.';
    final bypass = l10n?.connectingBypassHint
        ?? 'To put your scooter into drive mode anyway, raise the kickstand, hold both brakes and press the seatbox button.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          Text(
            explanation,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          Text(
            bypass,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
