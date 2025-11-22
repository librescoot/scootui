import 'package:flutter/material.dart';

import '../../cubits/theme_cubit.dart';

enum MenuItemType {
  action,    // Single action item (e.g. reset trip, settings option)
  submenu,   // Opens a submenu
}

class MenuItem {
  final String title;
  final MenuItemType type;
  int? currentValue;      // For action items: 0 = not selected, 1 = selected (shows checkmark)
  final Function(dynamic)? onChanged;
  final IconData? leadingIcon;  // Optional icon to show before the title

  MenuItem({
    required this.title,
    required this.type,
    this.currentValue,
    this.onChanged,
    this.leadingIcon,
  });
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
              // Show checkmark for selected settings (currentValue == 1)
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