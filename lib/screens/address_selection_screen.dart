import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../cubits/address_cubit.dart';
import '../l10n/l10n.dart';
// import '../cubits/navigation_cubit.dart'; // Not needed directly for setting destination via Redis
import '../cubits/mdb_cubits.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../env_config.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/general/control_hints.dart';
import '../widgets/location_dial/location_dial.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final _controller = LocationDialController();
  bool _isConfirming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _fromBase32(String code) {
    const chars = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    var result = 0;
    for (var i = 0; i < code.length; i++) {
      result = result * 32 + chars.indexOf(code[i]);
    }
    return result;
  }

  Widget _buildDialInput(ScreenCubit screenCubit, List<LatLng> addresses) {
    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      onLeftPress: () => _controller.scroll(),
      onLeftHold: () => _controller.scroll(isLongPress: true),
      onLeftRelease: () => _controller.stopScroll(),
      onRightPress: () => _controller.next(),
      child: LocationDialInput(
        length: 4,
        controller: _controller,
        onComplete: (code) {
          setState(() {
            _isConfirming = true;
          });
        },
        onSubmit: (code) {
          final index = _fromBase32(code);
          if (index >= 0 && index < addresses.length) {
            final address = addresses[index];
            developer.log('Destination code entered: $code (index: $index, lat: ${address.latitude}, lon: ${address.longitude})', name: 'AddressSelection');
            final navigationSync = context.read<NavigationSync>();
            navigationSync.setDestination(
              address.latitude,
              address.longitude,
              address: code,
            );
          } else {
            developer.log('Invalid destination code entered: $code (index: $index, out of range)', name: 'AddressSelection');
          }
          screenCubit.showMap();
        },
      ),
    );
  }

  Widget _buildConfirmation(String code) {
    final screenCubit = context.read<ScreenCubit>();
    final addressCubit = context.watch<AddressCubit>();
    final addresses = (addressCubit.state as AddressStateLoaded).addresses;

    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      onLeftPress: () {
        setState(() {
          _isConfirming = false;
          _controller.reset();
        });
      },
      onRightPress: () {
        final index = _fromBase32(code);
        if (index >= 0 && index < addresses.length) {
          final address = addresses[index];
          developer.log('Destination confirmed: $code (index: $index, lat: ${address.latitude}, lon: ${address.longitude})', name: 'AddressSelection');
          final navigationSync = context.read<NavigationSync>();
          navigationSync.setDestination(
            address.latitude,
            address.longitude,
            address: code,
          );
          screenCubit.showMap();
        }
      },
      child: LocationDialConfirmation(code: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenCubit = context.read<ScreenCubit>();
    // final mapCubit = context.read<MapCubit>(); // Removed
    final addressCubit = context.watch<AddressCubit>();

    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    final child = switch (addressCubit.state) {
      AddressStateLoaded(:final addresses) => _isConfirming
          ? _buildConfirmation(_controller.getCode())
          : _buildDialInput(screenCubit, addresses),
      AddressStateLoading(:final message, :final progress, :final addressCount) => ControlGestureDetector(
          stream: context.read<VehicleSync>().stream,
          onRightPress: () => screenCubit.showMap(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 16),
                if (progress != null) ...[
                  Text('${(progress * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  if (addressCount != null && addressCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(context.l10n.addressBuildProgress(addressCount)),
                  ],
                ] else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      AddressStateError(:final message) => ControlGestureDetector(
          stream: context.read<VehicleSync>().stream,
          onRightPress: () {
            developer.log('Address selection closed due to error', name: 'AddressSelection');
            screenCubit.showMap();
          },
          child: Center(child: Text(message))),
    };

    return Container(
      width: EnvConfig.resolution.width,
      height: EnvConfig.resolution.height,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Column(
        children: [
          _DialTitle(isDark: isDark),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [child],
              ),
            ),
          ),
          ControlHints(
            leftAction: switch (addressCubit.state) {
              AddressStateLoaded() => _isConfirming ? context.l10n.addressEditAction : context.l10n.addressScrollAction,
              _ => null,
            },
            rightAction: switch (addressCubit.state) {
              AddressStateLoaded() => _isConfirming ? context.l10n.addressConfirmAction : context.l10n.addressNextAction,
              AddressStateError() => context.l10n.addressCloseAction,
              AddressStateLoading() => context.l10n.addressCancelAction,
            },
          ),
        ],
      ),
    );
  }
}

class _DialTitle extends StatelessWidget {
  final bool isDark;

  const _DialTitle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.addressScreenTitle,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
