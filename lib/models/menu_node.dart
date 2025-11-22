import 'package:flutter/material.dart';

enum MenuNodeType {
  action,    // Performs an action when selected
  submenu,   // Opens a submenu
  setting,   // Changes a setting value
}

/// Represents a node in the menu tree structure
class MenuNode {
  final String id;
  final String title;
  final String? headerTitle; // Optional uppercase title for submenu header
  final MenuNodeType type;
  final List<MenuNode> children;
  final Function(BuildContext)? onAction;
  final IconData? leadingIcon;

  /// Optional function to determine if this menu item should be visible
  final bool Function(BuildContext)? isVisible;

  /// For setting nodes: current value indicator
  final int? currentValue;

  const MenuNode({
    required this.id,
    required this.title,
    this.headerTitle,
    required this.type,
    this.children = const [],
    this.onAction,
    this.leadingIcon,
    this.isVisible,
    this.currentValue,
  });

  /// Create an action node (performs action when selected)
  factory MenuNode.action({
    required String id,
    required String title,
    required Function(BuildContext) onAction,
    IconData? leadingIcon,
    bool Function(BuildContext)? isVisible,
  }) {
    return MenuNode(
      id: id,
      title: title,
      type: MenuNodeType.action,
      onAction: onAction,
      leadingIcon: leadingIcon,
      isVisible: isVisible,
    );
  }

  /// Create a submenu node (opens submenu when selected)
  factory MenuNode.submenu({
    required String id,
    required String title,
    String? headerTitle,
    required List<MenuNode> children,
    bool Function(BuildContext)? isVisible,
  }) {
    return MenuNode(
      id: id,
      title: title,
      headerTitle: headerTitle,
      type: MenuNodeType.submenu,
      children: children,
      isVisible: isVisible,
    );
  }

  /// Create a setting node (shows checkmark when active)
  factory MenuNode.setting({
    required String id,
    required String title,
    required Function(BuildContext) onAction,
    required int currentValue,
  }) {
    return MenuNode(
      id: id,
      title: title,
      type: MenuNodeType.setting,
      onAction: onAction,
      currentValue: currentValue,
    );
  }

  /// Check if this node should be visible in the current context
  bool shouldShow(BuildContext context) {
    return isVisible?.call(context) ?? true;
  }

  /// Get visible children in the current context
  List<MenuNode> getVisibleChildren(BuildContext context) {
    return children.where((child) => child.shouldShow(context)).toList();
  }
}
