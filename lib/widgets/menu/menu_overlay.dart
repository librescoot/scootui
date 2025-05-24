import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/menu_cubit.dart';
import '../../cubits/screen_cubit.dart';
import '../../cubits/theme_cubit.dart';
import '../../cubits/trip_cubit.dart';
import '../general/control_gestures_detector.dart';
import 'menu_item.dart';

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  bool _showTopScrollIndicator = false;
  bool _showBottomScrollIndicator = true;

  int _selectedIndex = 0;
  bool _showMapView = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scrollController = ScrollController()..addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!mounted) return;
    setState(() {
      _showTopScrollIndicator = _scrollController.offset > 20;
      _showBottomScrollIndicator = _scrollController.offset < _scrollController.position.maxScrollExtent - 20;
    });
  }

  void _scrollToSelectedItem() {
    if (!mounted) return;
    final itemHeight = 70.0; // Approximate height of each menu item
    final viewportHeight = MediaQuery.of(context).size.height - 200;
    final targetOffset = _selectedIndex * itemHeight;

    if (targetOffset < (viewportHeight - _scrollController.offset)) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else if (targetOffset + itemHeight > _scrollController.offset + viewportHeight) {
      _scrollController.animateTo(
        targetOffset - viewportHeight + itemHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuCubit>();
    final screen = context.read<ScreenCubit>();
    final trip = context.read<TripCubit>();
    final theme = context.read<ThemeCubit>();
    final vehicle = context.read<VehicleSync>();
    final isDark = theme.state.themeMode == ThemeMode.dark;

    final items = [
      MenuItem(
        title: 'Hazard lights',
        type: MenuItemType.action,
        onChanged: (_) {
          vehicle.toggleHazardLights();
          menu.hideMenu();
        },
      ),
      if (_showMapView) ...[
        MenuItem(
          title: 'Show Cluster View',
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showCluster();
            menu.hideMenu();
          },
        ),
        MenuItem(
          title: "Set Destination",
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showAddressSelection();
            menu.hideMenu();
          },
        ),
      ],
      if (!_showMapView)
        MenuItem(
          title: 'Show Map View',
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showMap();
            menu.hideMenu();
          },
        ),
      MenuItem(
          title: "Switch Theme",
          type: MenuItemType.action,
          onChanged: (_) {
            theme.toggleTheme();
            menu.hideMenu();
          }),
      MenuItem(
        title: 'Reset Trip',
        type: MenuItemType.action,
        onChanged: (_) {
          trip.reset();
          menu.hideMenu();
        },
      ),
      MenuItem(
        title: 'Exit Menu',
        type: MenuItemType.action,
        onChanged: (_) => menu.hideMenu(),
      )
    ];

    bool isMenuInteractable = menu.state is MenuVisible;

    switch (menu.state) {
      case MenuHidden():
        if (!_animController.isDismissed) {
          _animController.reverse();
          isMenuInteractable = false;
        } else {
          _selectedIndex = 0;
          return const SizedBox.shrink();
        }
        break;
      case MenuVisible():
        if (_animController.isDismissed) {
          _selectedIndex = 0;
          _showMapView = screen.state is ScreenMap;
          _animController.forward();
        }
        break;
    }

    final menuContentAndVisuals = FadeTransition(
      opacity: _animation,
      child: Container(
        color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
        padding: const EdgeInsets.only(top: 40),
        // Leave space for top status bar
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'MENU',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Menu items with scroll indicators
            Expanded(
              child: Stack(
                children: [
                  // Menu items list
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: MenuItemWidget(
                          item: item,
                          isSelected: _selectedIndex == index,
                          isInSubmenu: false, //widget.isInSubmenu && widget.selectedIndex == index,
                        ),
                      );
                    },
                  ),

                  // Top scroll indicator
                  if (_showTopScrollIndicator)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                              isDark ? Colors.black.withOpacity(0.0) : Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                    ),

                  // Bottom scroll indicator
                  if (_showBottomScrollIndicator)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                              isDark ? Colors.black.withOpacity(0.0) : Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Controls help
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlHint(
                    context,
                    'Left Brake',
                    false ? 'Change Value' : 'Next Item',
                    // widget.isInSubmenu ? 'Change Value' : 'Next Item',
                  ),
                  _buildControlHint(
                    context,
                    'Right Brake',
                    false ? 'Confirm' : 'Select',
                    // widget.isInSubmenu ? 'Confirm' : 'Select',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isMenuInteractable) {
      return ControlGestureDetector(
        stream: context.read<VehicleSync>().stream,
        onLeftPress: () => setState(() {
          _selectedIndex = (_selectedIndex + 1) % items.length;
          _scrollToSelectedItem();
        }),
        onRightPress: () {
          final item = items[_selectedIndex];
          item.onChanged?.call(item.currentValue);
        },
        child: menuContentAndVisuals,
      );
    } else {
      return menuContentAndVisuals;
    }
  }

  Widget _buildControlHint(BuildContext context, String control, String action) {
    final theme = ThemeCubit.watch(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          control,
          style: TextStyle(
            fontSize: 14,
            color: theme.isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          action,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
