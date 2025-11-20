import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../cubits/address_cubit.dart';
// import '../cubits/navigation_cubit.dart'; // Not needed directly for setting destination via Redis
import '../cubits/mdb_cubits.dart';
import '../cubits/screen_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../env_config.dart';
import '../repositories/address_repository.dart';
import '../repositories/mdb_repository.dart';
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
        onSubmit: (code) {
          final index = _fromBase32(code);
          if (index >= 0 && index < addresses.length) {
            final address = addresses[index];
            developer.log('Destination code entered: $code (index: $index, lat: ${address.latitude}, lon: ${address.longitude})', name: 'AddressSelection');
            // Set destination via NavigationSync with address code as label
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

  @override
  Widget build(BuildContext context) {
    final screenCubit = context.read<ScreenCubit>();
    // final mapCubit = context.read<MapCubit>(); // Removed
    final addressCubit = context.watch<AddressCubit>();

    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    final child = switch (addressCubit.state) {
      AddressStateLoaded(:final addresses) => _buildDialInput(screenCubit, addresses), // Removed mapCubit
      AddressStateLoading(:final message) => Center(
            child: Column(
          children: [
            Text(message),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        )),
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
              AddressStateLoaded() => 'Scroll',
              _ => null,
            },
            rightAction: switch (addressCubit.state) {
              AddressStateLoaded() => 'Next',
              AddressStateError() => 'Close',
              _ => null,
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
      'Enter Destination Code',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
