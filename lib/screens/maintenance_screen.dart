import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  final String? stateRaw;
  final String? statusMessage;

  const MaintenanceScreen({super.key, this.stateRaw, this.statusMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                if (statusMessage != null && statusMessage!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    statusMessage!,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ],
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
}
