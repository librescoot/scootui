import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/mdb_cubits.dart';
import '../cubits/menu_cubit.dart';
import '../cubits/screen_cubit.dart';
import '../widgets/general/control_gestures_detector.dart';
import '../widgets/menu/menu_overlay.dart';
import 'address_selection_screen.dart';
import 'cluster_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ScreenCubit>().state;
    final menu = context.watch<MenuCubit>();
    Widget menuTrigger(Widget child) => ControlGestureDetector(
          stream: context.read<VehicleSync>().stream,
          onLeftDoubleTap: () => menu.showMenu(),
          child: child,
        );

    return SizedBox(
      width: 480,
      height: 480,
      child: Stack(
        children: [
          switch (state) {
            // only map and cluster should trigger the menu
            ScreenMap() => menuTrigger(const MapScreen()),
            ScreenCluster() => menuTrigger(const ClusterScreen()),
            ScreenAddressSelection() => const AddressSelectionScreen(),
          },

          // Menu overlay
          MenuOverlay(),
        ],
      ),
    );
  }
}
