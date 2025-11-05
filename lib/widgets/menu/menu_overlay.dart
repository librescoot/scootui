import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/menu_cubit.dart';
import '../../cubits/saved_locations_cubit.dart';
import '../../cubits/screen_cubit.dart';
import '../../cubits/theme_cubit.dart';
import '../../cubits/trip_cubit.dart';
import '../../services/toast_service.dart';
import '../../state/carplay_availability.dart';
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

  // Submenu state
  final List<List<MenuItem>> _menuStack = [];
  final List<int> _selectedIndexStack = [];
  final List<SubmenuType> _submenuTypeStack = []; // Track submenu types
  final List<double> _scrollPositionStack = []; // Track scroll positions for each menu level
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
    _scrollController = ScrollController()..addListener(_updateScrollIndicators);

    // Force rebuild when animation completes to ensure widget returns SizedBox.shrink()
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {});
      }
    });
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
      _showTopScrollIndicator = _scrollController.offset > 5;
      _showBottomScrollIndicator = _scrollController.offset < _scrollController.position.maxScrollExtent - 5;
    });
  }

  void _scrollToSelectedItem() {
    if (!mounted || !_scrollController.hasClients) return;

    // Use post frame callback to ensure ListView is built and has dimensions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final itemHeight = 54.0; // Updated height for reduced padding menu items
      final viewportHeight = _scrollController.position.viewportDimension;
      final halfViewport = viewportHeight / 2;

      // Calculate target offset to center the selected item
      final targetOffset = (_selectedIndex * itemHeight) - halfViewport + (itemHeight / 2);

      // Clamp the offset to valid scroll range
      final maxOffset = _scrollController.position.maxScrollExtent;
      final clampedOffset = targetOffset.clamp(0.0, maxOffset);

      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _enterSubmenu(List<MenuItem> submenuItems, SubmenuType submenuType) {
    // Save current scroll position before entering submenu
    final currentScrollPosition = _scrollController.hasClients ? _scrollController.offset : 0.0;

    setState(() {
      _menuStack.add(submenuItems);
      _selectedIndexStack.add(_selectedIndex);
      _submenuTypeStack.add(submenuType);
      _scrollPositionStack.add(currentScrollPosition);
      _selectedIndex = 0;
      _isInSubmenu = true;
    });

    // Reset scroll position to top for submenu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
        _updateScrollIndicators();
      }
    });
  }

  void _exitSubmenu() {
    if (_selectedIndexStack.isNotEmpty) {
      final savedScrollPosition = _scrollPositionStack.isNotEmpty ? _scrollPositionStack.removeLast() : 0.0;

      setState(() {
        _menuStack.removeLast();
        _selectedIndex = _selectedIndexStack.removeLast();
        _submenuTypeStack.removeLast();
        _isInSubmenu = _menuStack.isNotEmpty;
      });

      // Restore previous scroll position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(savedScrollPosition);
          _updateScrollIndicators();
        }
      });
    }
  }

  void _resetMenuState() {
    _menuStack.clear();
    _selectedIndexStack.clear();
    _submenuTypeStack.clear();
    _scrollPositionStack.clear();
    _selectedIndex = 0;
    _isInSubmenu = false;
  }

  String _getSubmenuTitle() {
    if (!_isInSubmenu || _submenuTypeStack.isEmpty) return 'MENU';

    // Use the submenu type to determine title
    switch (_submenuTypeStack.last) {
      case SubmenuType.savedLocations:
        return 'SAVED LOCATIONS';
      case SubmenuType.theme:
        return 'CHANGE THEME';
      case SubmenuType.other:
        return 'SUBMENU';
    }
  }

  List<MenuItem> _buildSavedLocationsSubmenu(BuildContext context) {
    final savedLocationsCubit = context.read<SavedLocationsCubit>();
    final locations = savedLocationsCubit.currentLocations;

    final items = <MenuItem>[];

    // Add "Go back" as first item
    items.add(MenuItem(
      title: '< Back',
      type: MenuItemType.action,
      onChanged: (_) {
        _exitSubmenu();
      },
    ));

    // Add "Save Current Location" as second item
    items.add(MenuItem(
      title: 'Save Current Location',
      type: MenuItemType.action,
      onChanged: (_) async {
        final gpsData = context.read<GpsSync>().state;
        final internetData = context.read<InternetSync>().state;
        final savedLocationsCubit = context.read<SavedLocationsCubit>();
        final menuCubit = context.read<MenuCubit>();

        // Validate GPS before attempting to save
        if (!gpsData.hasRecentFix) {
          ToastService.showError('No recent GPS fix available. Please wait for GPS signal.');
          return;
        }

        if (gpsData.latitude == 0.0 && gpsData.longitude == 0.0) {
          ToastService.showError('Invalid GPS coordinates. Please wait for valid location.');
          return;
        }

        final success = await savedLocationsCubit.saveCurrentLocation(gpsData, internetData);
        if (success) {
          ToastService.showSuccess('Location saved successfully!');
        } else {
          ToastService.showError('Failed to save location. Storage may be full.');
        }

        if (mounted) {
          menuCubit.hideMenu();
        }
      },
    ));

    if (locations.isEmpty) {
      items.add(MenuItem(
        title: 'No Saved Locations',
        type: MenuItemType.action,
        onChanged: (_) {},
      ));
    } else {
      for (final location in locations) {
        items.add(MenuItem(
          title: location.label,
          type: MenuItemType.submenu,
          submenuItems: [
            MenuItem(
              title: '< Back',
              type: MenuItemType.action,
              onChanged: (_) {
                _exitSubmenu();
              },
            ),
            MenuItem(
              title: 'Start Navigation',
              type: MenuItemType.action,
              onChanged: (_) {
                // Set destination via NavigationSync with saved location label
                final navigationSync = context.read<NavigationSync>();
                navigationSync.setDestination(
                  location.latitude,
                  location.longitude,
                  address: location.label,
                );
                savedLocationsCubit.updateLastUsed(location.id);
                context.read<MenuCubit>().hideMenu();
              },
            ),
            MenuItem(
              title: 'Delete Saved Location',
              type: MenuItemType.action,
              onChanged: (_) async {
                final success = await savedLocationsCubit.deleteLocation(location.id);
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
    }

    return items;
  }

  List<MenuItem> _buildThemeSubmenu(BuildContext context, ThemeCubit theme) {
    final themeState = theme.state;

    return [
      MenuItem(
        title: '< Back',
        type: MenuItemType.action,
        onChanged: (_) {
          _exitSubmenu();
        },
      ),
      MenuItem(
        title: 'Automatic',
        type: MenuItemType.action,
        currentValue: themeState.isAutoMode ? 1 : 0, // Use currentValue to indicate selection
        onChanged: (_) {
          theme.updateAutoTheme(true);
          context.read<MenuCubit>().hideMenu();
        },
      ),
      MenuItem(
        title: 'Dark Theme',
        type: MenuItemType.action,
        currentValue: (!themeState.isAutoMode && themeState.themeMode == ThemeMode.dark) ? 1 : 0,
        onChanged: (_) {
          theme.updateAutoTheme(false);
          theme.updateTheme(ThemeMode.dark);
          context.read<MenuCubit>().hideMenu();
        },
      ),
      MenuItem(
        title: 'Light Theme',
        type: MenuItemType.action,
        currentValue: (!themeState.isAutoMode && themeState.themeMode == ThemeMode.light) ? 1 : 0,
        onChanged: (_) {
          theme.updateAutoTheme(false);
          theme.updateTheme(ThemeMode.light);
          context.read<MenuCubit>().hideMenu();
        },
      ),
    ];
  }

  List<MenuItem> _buildCurrentMenuItems(
    BuildContext context,
    MenuCubit menu,
    ScreenCubit screen,
    TripCubit trip,
    ThemeCubit theme,
    VehicleSync vehicle,
    CarPlayAvailabilityData carplayAvailability,
  ) {
    // If we're in a submenu, return the current submenu items
    if (_isInSubmenu && _menuStack.isNotEmpty) {
      return _menuStack.last;
    }

    // Main menu items
    return [
      // Show CarPlay/Android Auto menu entry when dongle is available
      if (carplayAvailability.isDongleAvailable)
        MenuItem(
          title: carplayAvailability.displayName,
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showCarPlay();
            menu.hideMenu();
          },
        ),
      MenuItem(
        title: 'Toggle Hazard Lights',
        type: MenuItemType.action,
        onChanged: (_) {
          vehicle.toggleHazardLights();
          menu.hideMenu();
        },
      ),
      if (_showMapView) ...[
        MenuItem(
          title: 'Switch to Cluster View',
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showCluster();
            menu.hideMenu();
          },
        ),
        MenuItem(
          title: "Enter Destination Code",
          type: MenuItemType.action,
          onChanged: (_) {
            screen.showAddressSelection();
            menu.hideMenu();
          },
        ),
      ],
      if (!_showMapView)
        MenuItem(
          title: 'Switch to Map View',
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
        submenuId: SubmenuType.savedLocations,
      ),
      MenuItem(
        title: 'Change Theme',
        type: MenuItemType.submenu,
        submenuItems: _buildThemeSubmenu(context, theme),
        submenuId: SubmenuType.theme,
      ),
      MenuItem(
        title: 'Reset Trip Statistics',
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
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuCubit>();
    final screen = context.read<ScreenCubit>();
    final trip = context.read<TripCubit>();
    final theme = context.read<ThemeCubit>();
    final vehicle = context.read<VehicleSync>();
    final carplayAvailability = context.watch<CarPlayAvailabilitySync>().state;

    // Watch for saved locations changes and refresh submenu if needed
    context.watch<SavedLocationsCubit>();

    // If we're in the saved locations submenu, refresh it when locations change
    if (_isInSubmenu &&
        _submenuTypeStack.isNotEmpty &&
        _submenuTypeStack.last == SubmenuType.savedLocations &&
        _menuStack.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isInSubmenu && _menuStack.isNotEmpty) {
          setState(() {
            _menuStack[_menuStack.length - 1] = _buildSavedLocationsSubmenu(context);
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
          // Reset scroll position and indicators when menu opens
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
              _updateScrollIndicators();
            }
          });
        }
        break;
    }

    // Use the proper isDark getter that handles auto mode
    final isDark = theme.state.isDark;

    final items = _buildCurrentMenuItems(context, menu, screen, trip, theme, vehicle, carplayAvailability);

    return ControlGestureDetector(
      stream: context.read<VehicleSync>().stream,
      onLeftPress: () {
        // Ignore input if menu is hidden
        if (menu.state is MenuHidden) return;
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % items.length;
          _scrollToSelectedItem();
        });
      },
      onRightPress: () {
        // Ignore input if menu is hidden
        if (menu.state is MenuHidden) return;
        final item = items[_selectedIndex];
        if (item.type == MenuItemType.submenu) {
          _enterSubmenu(item.submenuItems ?? [], item.submenuId ?? SubmenuType.other);
        } else {
          item.onChanged?.call(item.currentValue);
        }
      },
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
          padding: const EdgeInsets.only(top: 40),
          // Leave space for top status bar
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                _getSubmenuTitle(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Menu items with scroll indicators
              Expanded(
                child: Stack(
                  children: [
                    // Menu items list
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(40, 12, 40, 12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          key: ValueKey(item.title),
                          padding: const EdgeInsets.symmetric(vertical: 2),
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

              // Controls help - styled like unified bottom status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
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

  Widget _buildControlHint(BuildContext context, String control, String action) {
    final theme = ThemeCubit.watch(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          control,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: theme.isDark ? Colors.white60 : Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          action,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
