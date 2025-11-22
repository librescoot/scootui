import 'package:flutter/material.dart';
import '../models/menu_node.dart';

/// Helper class for navigating the menu tree structure
class MenuNavigator {
  final MenuNode root;

  const MenuNavigator(this.root);

  /// Get the current node based on the navigation path
  MenuNode getCurrentNode(List<String> path) {
    if (path.isEmpty) return root;

    MenuNode current = root;
    for (final nodeId in path) {
      final child = current.children.firstWhere(
        (node) => node.id == nodeId,
        orElse: () => root,
      );
      current = child;
    }
    return current;
  }

  /// Get visible children of the current node
  List<MenuNode> getCurrentChildren(List<String> path, BuildContext context) {
    final current = getCurrentNode(path);
    return current.getVisibleChildren(context);
  }

  /// Get the parent node title for the back button
  String getParentTitle(List<String> path) {
    if (path.length < 2) {
      // At root or one level deep - parent is root
      return root.title;
    }

    // Get the parent node (second-to-last in path)
    final parentPath = path.sublist(0, path.length - 1);
    final parent = getCurrentNode(parentPath);
    return parent.title;
  }

  /// Get the header title for the current menu
  String getHeaderTitle(List<String> path) {
    final current = getCurrentNode(path);
    return current.headerTitle ?? current.title.toUpperCase();
  }

  /// Navigate into a submenu
  List<String> enterSubmenu(List<String> path, String nodeId) {
    return [...path, nodeId];
  }

  /// Navigate back to parent menu
  List<String> exitSubmenu(List<String> path) {
    if (path.isEmpty) return path;
    return path.sublist(0, path.length - 1);
  }

  /// Check if currently in a submenu (not at root)
  bool isInSubmenu(List<String> path) {
    return path.isNotEmpty;
  }
}
