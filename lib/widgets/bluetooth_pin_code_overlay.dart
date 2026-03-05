import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/mdb_cubits.dart';
import '../l10n/l10n.dart';
import '../state/bluetooth.dart';

class BluetoothPinCodeOverlay extends StatefulWidget {
  const BluetoothPinCodeOverlay({super.key});

  @override
  State<BluetoothPinCodeOverlay> createState() => _BluetoothPinCodeOverlayState();
}

class _BluetoothPinCodeOverlayState extends State<BluetoothPinCodeOverlay> {
  Timer? _pinCodeTimer;
  String? _bluetoothPinCode;

  @override
  void dispose() {
    _pinCodeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothSync, BluetoothData>(
      listener: (context, bluetoothState) {
        if (bluetoothState.pinCode.isNotEmpty && _bluetoothPinCode != bluetoothState.pinCode) {
          setState(() {
            _bluetoothPinCode = bluetoothState.pinCode;
          });
          // Start a timer to clear the pin code after a delay
          _pinCodeTimer?.cancel(); // Cancel previous timer if any
          _pinCodeTimer = Timer(const Duration(seconds: 30), () {
            setState(() {
              _bluetoothPinCode = null;
            });
          });
        } else if (bluetoothState.pinCode.isEmpty && _bluetoothPinCode != null) {
          setState(() {
            _bluetoothPinCode = null;
          });
          _pinCodeTimer?.cancel(); // Cancel timer if pin code is cleared externally
        }
      },
      child: _bluetoothPinCode != null
          ? Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.30,
                color: Colors.blue.withOpacity(0.8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8), // Add some spacing
                    Text(
                      context.l10n.bluetoothPinInstruction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$_bluetoothPinCode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 80,
                        letterSpacing: 14,
                        height: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
