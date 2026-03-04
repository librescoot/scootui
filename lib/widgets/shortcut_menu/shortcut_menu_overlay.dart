import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/l10n.dart';
import '../../cubits/shortcut_menu_cubit.dart';
import '../../cubits/screen_cubit.dart';
import '../../cubits/theme_cubit.dart';

class ShortcutMenuOverlay extends StatelessWidget {
  const ShortcutMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShortcutMenuCubit, ShortcutMenuState>(
      builder: (context, state) {
        if (state == ShortcutMenuState.hidden) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ShortcutMenuCubit>();
        final menuItems = cubit.menuItems;
        final isConfirming = cubit.isConfirming;

        // Use ValueListenableBuilder to listen to the selectedIndex changes
        return ValueListenableBuilder<int>(
          valueListenable: cubit.selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            return _buildMenuOverlay(
              context: context,
              menuItems: menuItems,
              selectedIndex: selectedIndex,
              isConfirming: isConfirming &&
                  state == ShortcutMenuState.confirmingSelection,
            );
          },
        );
      },
    );
  }

  Widget _buildMenuOverlay({
    required BuildContext context,
    required List<ShortcutMenuItem> menuItems,
    required int selectedIndex,
    required bool isConfirming,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
        children: [
          // Menu items in a row at the bottom with improved container styling
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Center(
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(menuItems.length, (index) {
                    final isSelected = index == selectedIndex;
                    return _buildMenuItem(
                      context: context,
                      item: menuItems[index],
                      isSelected: isSelected,
                      isDark: isDark,
                    );
                  }),
                ),
              ),
            ),
          ),

          // Confirmation UI with improved styling
          if (isConfirming)
            Positioned(
              bottom: 20,
              left: 60,
              right: 60,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      context.l10n.shortcutPressToConfirm,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 1.0, end: 0.0),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor:
                                  isDark ? Colors.white24 : Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ShortcutMenuItem item,
    required bool isSelected,
    required bool isDark,
  }) {
    final size = isSelected ? 80.0 : 60.0;
    final color = isSelected
        ? Colors.orange // Use orange for selected items for better contrast
        : isDark
            ? Colors.white
            : Colors.black87;

    // Add a key that depends on isSelected to force rebuild
    return AnimatedContainer(
      key: ValueKey(
          'menu_item_${item.name}_${isSelected ? 'selected' : 'normal'}'),
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: isSelected ? 4 : 2, // Thicker borders for better contrast
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Center(
        child: _getIconForMenuItem(context, item, color, isSelected ? 36 : 28),
      ),
    );
  }

  Widget _getIconForMenuItem(BuildContext context, ShortcutMenuItem item, Color color, double size) {
    // Get icon from centralized menu structure
    IconData iconData;
    
    switch (item) {
      case ShortcutMenuItem.toggleHazards:
        iconData = MenuItems.getItemData(item).icon;
        break;
      case ShortcutMenuItem.toggleView:
        // Dynamic icon based on current screen state
        final screenCubit = context.read<ScreenCubit>();
        final isClusterView = screenCubit.state is ScreenCluster;
        iconData = MenuItems.getViewToggleIcon(isClusterView);
        break;
      case ShortcutMenuItem.toggleTheme:
        // Dynamic icon based on next theme state
        final themeCubit = context.read<ThemeCubit>();
        final themeState = themeCubit.state;
        iconData = MenuItems.getThemeToggleIcon(themeState.isAutoMode, themeState.themeMode);
        break;
      case ShortcutMenuItem.toggleDebugOverlay:
        iconData = MenuItems.getItemData(item).icon;
        break;
    }
    
    return Icon(
      iconData,
      key: ValueKey('icon_${item.name}_$size'),
      color: color,
      size: size,
    );
  }
}
