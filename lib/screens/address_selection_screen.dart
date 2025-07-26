import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/address_repository.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/screen_cubit.dart';
import '../repositories/mdb_repository.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/general/settings_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenCubit = context.read<ScreenCubit>();
    final addressRepository = context.read<AddressRepository>();

    return SettingsScreen(
      title: 'Enter Destination Code',
      leftAction: 'Scroll',
      rightAction: 'Next',
      child: ControlGestureDetector(
        stream: context.read<VehicleSync>().stream,
        onLeftPress: () => _controller.scroll(),
        onLeftHold: () => _controller.scroll(isLongPress: true),
        onLeftRelease: () => _controller.stopScroll(),
        onRightPress: () => _controller.next(),
        child: LocationDialInput(
          length: 5,
          controller: _controller,
          onSubmit: (code) async {
            final address = await addressRepository.findAddress(code);
            if (address != null) {
              final mdbRepo = context.read<MDBRepository>();
              final coordinates =
                  "${address.coordinates.latitude},${address.coordinates.longitude}";
              mdbRepo.set("navigation", "destination", coordinates);
            }
            screenCubit.showMap();
          },
        ),
      ),
    );
  }
}
