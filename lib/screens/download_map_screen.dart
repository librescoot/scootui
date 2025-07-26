import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scooter_cluster/cubits/map_cubit.dart';
import 'package:scooter_cluster/cubits/mdb_cubits.dart';
import 'package:scooter_cluster/cubits/theme_cubit.dart';
import 'package:scooter_cluster/repositories/tiles_update_repository.dart';
import 'package:scooter_cluster/widgets/general/control_gestures_detector.dart';
import 'package:scooter_cluster/widgets/general/settings_screen.dart';

import '../cubits/screen_cubit.dart';

class DownloadMapScreen extends StatefulWidget {
  const DownloadMapScreen({Key? key}) : super(key: key);

  @override
  _DownloadMapScreenState createState() => _DownloadMapScreenState();
}

class _DownloadMapScreenState extends State<DownloadMapScreen> {
  int _selectedIndex = 0;
  final List<GlobalKey> _keys = regions.map((e) => GlobalKey()).toList();
  final ScrollController _scrollController = ScrollController();

  String get currentMonth => DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:theme, :isDark) = ThemeCubit.watch(context);

    final renderObject =
        _keys[_selectedIndex].currentContext?.findRenderObject();

    if (_scrollController.hasClients) {
      if (renderObject == null) {
        // if no render object is found, it means the currently selected item is not in the viewport.
        // this can only happen when we jump back up to the first item, so let's just scroll to the top

        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.position.ensureVisible(
          renderObject,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      onLeftPress: () {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % regions.length;
        });
      },
      onRightPress: () {
        final region = regions[_selectedIndex];

        // Fire download and immediately navigate back
        context.read<MapCubit>().downloadMap(region);
        context.read<ScreenCubit>().showMap();
      },
      child: SettingsScreen(
        title: 'Download Map',
        leftAction: 'Scroll',
        rightAction: 'Download',
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              child: Text(
                'Maps from $currentMonth',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Material(
                color: theme.scaffoldBackgroundColor,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final isSelected = index == _selectedIndex;
                    return ListTile(
                      key: _keys[index],
                      title: Text(region.name),
                      tileColor: isSelected
                          ? isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
