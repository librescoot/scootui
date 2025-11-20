import 'package:flutter/material.dart';

import '../../cubits/theme_cubit.dart';

enum MenuItemType {
  action,    // Single action item (e.g. reset trip)
  toggle,    // Toggle between two states (e.g. theme)
  submenu,   // Opens a submenu
  value,     // Change a value (e.g. brightness)
}

enum SubmenuType {
  savedLocations,
  theme,
  other,
}

class MenuItem {
  final String title;
  final MenuItemType type;
  final List<String>? options;  // For toggle items
  int? currentValue;      // For value items
  final Function(dynamic)? onChanged;
  final List<MenuItem>? submenuItems;
  final SubmenuType? submenuId;  // Identifier for the submenu type
  final String? submenuTitle;  // Custom title displayed when entering this submenu
  final IconData? leadingIcon;  // Optional icon to show before the title

  MenuItem({
    required this.title,
    required this.type,
    this.options,
    this.currentValue,
    this.onChanged,
    this.submenuItems,
    this.submenuId,
    this.submenuTitle,
    this.leadingIcon,
  }) : assert(
    (type == MenuItemType.toggle && options != null && currentValue != null) ||
    (type == MenuItemType.value && currentValue != null) ||
    (type == MenuItemType.submenu && submenuItems != null) ||
    type == MenuItemType.action
  );

  // Factory constructor for theme toggle
  factory MenuItem.themeToggle(Function(ThemeMode) onChanged, ThemeMode currentTheme) {
    return MenuItem(
      title: 'Change Theme',
      type: MenuItemType.toggle,
      options: ['Dark', 'Light'],
      currentValue: currentTheme == ThemeMode.dark ? 0 : 1,
      onChanged: (value) {
        onChanged(value == 0 ? ThemeMode.dark : ThemeMode.light);
      },
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final bool isSelected;
  final bool isInSubmenu;

  const MenuItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    this.isInSubmenu = false,
  });

  String _getCurrentThemeText(BuildContext context) {
    final themeState = ThemeCubit.watch(context);
    if (themeState.isAutoMode) {
      return 'Auto';
    } else {
      return themeState.isDark ? 'Dark' : 'Light';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState(:isDark) = ThemeCubit.watch(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.white24 : Colors.black12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (item.leadingIcon != null) ...[
                  Icon(
                    item.leadingIcon,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: isSelected ? TextOverflow.visible : TextOverflow.ellipsis,
                    softWrap: isSelected,
                    maxLines: isSelected ? null : 1,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // For theme item, show current theme name
              if (item.title == 'Change Theme') ...[
                Text(
                  _getCurrentThemeText(context),
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Show checkmark for selected theme options (currentValue == 1)
              if (item.currentValue == 1)
                Icon(
                  Icons.check,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              // Show submenu arrow for submenu items
              if (item.type == MenuItemType.submenu)
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
            ],
          ),
        ],
      ),
    );
  }
}