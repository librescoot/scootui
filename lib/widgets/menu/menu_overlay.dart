import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/menu_cubit.dart';
import '../../cubits/saved_locations_cubit.dart';
import '../../cubits/screen_cubit.dart';
import '../../cubits/theme_cubit.dart';
import '../../cubits/trip_cubit.dart';
import '../../repositories/mdb_repository.dart';
import '../../services/toast_service.dart';
import '../general/control_gestures_detector.dart';
import 'menu_item.dart';

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  bool _showTopScrollIndicator = false;
  bool _showBottomScrollIndicator = true;

  int _selectedIndex = 0;
  bool _showMapView = false;

  // Submenu state
  final List<List<MenuItem>> _menuStack = [];
  final List<int> _selectedIndexStack = [];
  bool _isInSubmenu = false;

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
    _scrollController = ScrollController()
      ..addListener(_updateScrollIndicators);
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
      _showBottomScrollIndicator = _scrollController.offset <
          _scrollController.position.maxScrollExtent - 20;
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
    } else if (targetOffset + itemHeight >
        _scrollController.offset + viewportHeight) {
      _scrollController.animateTo(
        targetOffset - viewportHeight + itemHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _enterSubmenu(List<MenuItem> submenuItems) {
    setState(() {
      _menuStack.add(submenuItems);
      _selectedIndexStack.add(_selectedIndex);
      _selectedIndex = 0;
      _isInSubmenu = true;
    });
  }

  void _exitSubmenu() {
    if (_selectedIndexStack.isNotEmpty) {
      setState(() {
        _menuStack.removeLast();
        _selectedIndex = _selectedIndexStack.removeLast();
        _isInSubmenu = _menuStack.isNotEmpty;
      });
    }
  }

  void _resetMenuState() {
    _menuStack.clear();
    _selectedIndexStack.clear();
    _selectedIndex = 0;
    _isInSubmenu = false;
  }

  List<MenuItem> _buildSavedLocationsSubmenu(BuildContext context) {
    final savedLocationsCubit = context.read<SavedLocationsCubit>();
    final locations = savedLocationsCubit.currentLocations;

    if (locations.isEmpty) {
      return [
        MenuItem(
          title: 'No saved locations',
          type: MenuItemType.action,
          onChanged: (_) {
            _exitSubmenu();
          },
        ),
        MenuItem(
          title: 'Go back',
          type: MenuItemType.action,
          onChanged: (_) {
            _exitSubmenu();
          },
        ),
      ];
    }

    final items = <MenuItem>[];

    for (final location in locations) {
      items.add(MenuItem(
        title: location.label,
        type: MenuItemType.submenu,
        submenuItems: [
          MenuItem(
            title: 'Start navigation',
            type: MenuItemType.action,
            onChanged: (_) {
              final mdbRepo = context.read<MDBRepository>();
              mdbRepo.set(
                  "navigation", "destination", location.coordinatesString);
              savedLocationsCubit.updateLastUsed(location.id);
              context.read<MenuCubit>().hideMenu();
            },
          ),
          MenuItem(
            title: 'Go back',
            type: MenuItemType.action,
            onChanged: (_) {
              _exitSubmenu();
            },
          ),
          MenuItem(
            title: 'Delete saved location',
            type: MenuItemType.action,
            onChanged: (_) async {
              final success =
                  await savedLocationsCubit.deleteLocation(location.id);
              if (success) {
                ToastService.showSuccess('Location deleted successfully!');
              } else {
                ToastService.showError('Failed to delete location.');
              }
              // Exit to the individual location submenu
              _exitSubmenu();
            },
          ),
        ],
      ));
    }

    items.add(MenuItem(
      title: 'Go back',
      type: MenuItemType.action,
      onChanged: (_) {
        _exitSubmenu();
      },
    ));

    return items;
  }

  List<MenuItem> _buildCurrentMenuItems(
    BuildContext context,
    MenuCubit menu,
    ScreenCubit screen,
    TripCubit trip,
    ThemeCubit theme,
    VehicleSync vehicle,
  ) {
    // If we're in a submenu, return the current submenu items
    if (_isInSubmenu && _menuStack.isNotEmpty) {
      return _menuStack.last;
    }

    // Main menu items
    return [
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
        title: 'Saved Locations',
        type: MenuItemType.submenu,
        submenuItems: _buildSavedLocationsSubmenu(context),
      ),
      MenuItem(
        title: 'Save current location',
        type: MenuItemType.action,
        onChanged: (_) async {
          final gpsData = context.read<GpsSync>().state;
          final internetData = context.read<InternetSync>().state;
          final savedLocationsCubit = context.read<SavedLocationsCubit>();

          // Validate GPS before attempting to save
          if (!gpsData.hasRecentFix) {
            ToastService.showError(
                'No recent GPS fix available. Please wait for GPS signal.');
            return;
          }

          if (gpsData.latitude == 0.0 && gpsData.longitude == 0.0) {
            ToastService.showError(
                'Invalid GPS coordinates. Please wait for valid location.');
            return;
          }

          final success = await savedLocationsCubit.saveCurrentLocation(
              gpsData, internetData);
          if (success) {
            ToastService.showSuccess('Location saved successfully!');
          } else {
            ToastService.showError(
                'Failed to save location. Storage may be full.');
          }

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
      if (!kIsWeb)
        MenuItem(
          title: 'Download Map',
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showDownloadMap();
            menu.hideMenu();
          },
        ),
      MenuItem(
        title: 'Exit Menu',
        type: MenuItemType.action,
        onChanged: (_) => menu.hideMenu(),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuCubit>();
    final screen = context.read<ScreenCubit>();
    final trip = context.read<TripCubit>();
    final theme = context.read<ThemeCubit>();
    final vehicle = context.read<VehicleSync>();

    // Watch for saved locations changes and refresh submenu if needed
    context.watch<SavedLocationsCubit>();

    // If we're in the saved locations submenu, refresh it when locations change
    if (_isInSubmenu && _menuStack.isNotEmpty && _menuStack.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _menuStack[0] = _buildSavedLocationsSubmenu(context);
          });
        }
      });
    }

    switch (menu.state) {
      case MenuHidden():
        if (!_animController.isDismissed) {
          // if the menu is still visible, but should be hidden =>
          // start the animation
          _animController.reverse();
        } else {
          // once menu is completely hidden, reset the selected index.
          // we don't need to use setState here, because we don't need
          // to re-render. this is just setting it up for next time it's shown
          // if the menu is already hidden, just return an empty widget
          return const SizedBox.shrink();
        }
        break;
      case MenuVisible():
        if (_animController.isDismissed) {
          _resetMenuState();
          // use a separate variable here, because we only want to set this
          // just before we start fading in the menu
          _showMapView = screen.state is ScreenMap;
          _animController.forward();
        }
        break;
    }

    // Use the proper isDark getter that handles auto mode
    final isDark = theme.state.isDark;

    final items =
        _buildCurrentMenuItems(context, menu, screen, trip, theme, vehicle);

    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      onLeftPress: () => setState(() {
        _selectedIndex = (_selectedIndex + 1) % items.length;
        _scrollToSelectedItem();
      }),
      onRightPress: () {
        final item = items[_selectedIndex];
        if (item.type == MenuItemType.submenu) {
          _enterSubmenu(item.submenuItems ?? []);
        } else {
          item.onChanged?.call(item.currentValue);
        }
      },
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          color: isDark
              ? Colors.black.withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          padding: const EdgeInsets.only(top: 40),
          // Leave space for top status bar
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _isInSubmenu ? 'SAVED LOCATIONS' : 'MENU',
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
                            isInSubmenu: _isInSubmenu,
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
                                isDark
                                    ? Colors.black.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.9),
                                isDark
                                    ? Colors.black.withOpacity(0.0)
                                    : Colors.white.withOpacity(0.0),
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
                                isDark
                                    ? Colors.black.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.9),
                                isDark
                                    ? Colors.black.withOpacity(0.0)
                                    : Colors.white.withOpacity(0.0),
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
                      'Next Item',
                    ),
                    _buildControlHint(
                      context,
                      'Right Brake',
                      _isInSubmenu ? 'Select' : 'Select',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlHint(
      BuildContext context, String control, String action) {
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
