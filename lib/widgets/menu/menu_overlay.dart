import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/mdb_cubits.dart';
import '../../cubits/menu_cubit.dart';
import '../../cubits/saved_locations_cubit.dart';
import '../../cubits/theme_cubit.dart';
import '../../data/menu_structure.dart';
import '../../models/menu_node.dart';
import '../../utils/menu_navigator.dart';
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

  // Data-driven menu navigation (rebuilt each frame with current state)
  late MenuNavigator _menuNav;
  final List<String> _navigationPath = []; // Path through menu tree (list of node IDs)
  final List<int> _selectedIndexStack = []; // Selected index at each level
  final List<double> _scrollPositionStack = []; // Scroll position at each level

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

  /// Navigate into a submenu by node ID
  void _enterSubmenu(String nodeId) {
    // Save current state before navigating
    final currentScrollPosition = _scrollController.hasClients ? _scrollController.offset : 0.0;

    setState(() {
      _selectedIndexStack.add(_selectedIndex);
      _scrollPositionStack.add(currentScrollPosition);
      _navigationPath.add(nodeId);
      _selectedIndex = 0;
    });

    // Reset scroll to top for new submenu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
        _updateScrollIndicators();
      }
    });
  }

  /// Navigate back to parent menu
  void _exitSubmenu() {
    if (_navigationPath.isEmpty) return;

    final savedScrollPosition = _scrollPositionStack.isNotEmpty
        ? _scrollPositionStack.removeLast()
        : 0.0;

    setState(() {
      _navigationPath.removeLast();
      _selectedIndex = _selectedIndexStack.isNotEmpty
          ? _selectedIndexStack.removeLast()
          : 0;
    });

    // Restore scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(savedScrollPosition);
        _updateScrollIndicators();
      }
    });
  }

  /// Reset menu to root
  void _resetMenuState() {
    _navigationPath.clear();
    _selectedIndexStack.clear();
    _scrollPositionStack.clear();
    _selectedIndex = 0;
  }

  /// Get the current menu's header title
  String _getSubmenuTitle() {
    return _menuNav.getHeaderTitle(_navigationPath);
  }

  /// Get the parent menu's title for the back button
  String _getParentMenuTitle() {
    return _menuNav.getParentTitle(_navigationPath);
  }

  /// Convert a MenuNode to a MenuItem
  MenuItem _nodeToMenuItem(MenuNode node, BuildContext context) {
    if (node.type == MenuNodeType.submenu) {
      return MenuItem(
        title: node.title,
        type: MenuItemType.submenu,
        leadingIcon: node.leadingIcon,
        onChanged: (_) => _enterSubmenu(node.id),
      );
    } else if (node.type == MenuNodeType.setting) {
      return MenuItem(
        title: node.title,
        type: MenuItemType.action,
        currentValue: node.currentValue ?? 0,
        leadingIcon: node.leadingIcon,
        onChanged: (_) => node.onAction?.call(context),
      );
    } else {
      // MenuNodeType.action
      return MenuItem(
        title: node.title,
        type: MenuItemType.action,
        leadingIcon: node.leadingIcon,
        onChanged: (_) => node.onAction?.call(context),
      );
    }
  }

  MenuItem _buildBackButton() {
    return MenuItem(
      title: _getParentMenuTitle(),
      type: MenuItemType.action,
      leadingIcon: Icons.chevron_left,
      onChanged: (_) => _exitSubmenu(),
    );
  }


  /// Build menu items from the current position in the menu tree
  List<MenuItem> _buildCurrentMenuItems(BuildContext context) {
    // Rebuild menu tree with current state
    _menuNav = MenuNavigator(buildMenuTree(context));

    // Get visible children from current position in tree
    final children = _menuNav.getCurrentChildren(_navigationPath, context);

    final items = <MenuItem>[];

    // Add back button if in a submenu
    if (_menuNav.isInSubmenu(_navigationPath)) {
      items.add(_buildBackButton());
    }

    // Convert MenuNodes to MenuItems
    for (final node in children) {
      items.add(_nodeToMenuItem(node, context));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuCubit>();
    final theme = context.watch<ThemeCubit>(); // Watch theme for menu item updates

    // Watch for saved locations changes - menu will rebuild automatically
    context.watch<SavedLocationsCubit>();

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

    final items = _buildCurrentMenuItems(context);

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
        // Execute the item's action (works for both submenus and actions)
        item.onChanged?.call(item.currentValue);
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
                            isInSubmenu: _menuNav.isInSubmenu(_navigationPath),
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
                      _menuNav.isInSubmenu(_navigationPath) ? 'Select' : 'Select',
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
