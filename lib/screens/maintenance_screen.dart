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
    final l10n = context.l10n;

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

  Widget _buildConnectionInfo(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.connectingTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white12,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.connectingExplanation,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w300,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white12,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.connectingBypassHint,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w300,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
