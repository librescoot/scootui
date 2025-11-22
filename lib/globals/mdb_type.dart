import 'package:flutter/foundation.dart';

/// Simple global state to track if running stock UNU MDB
/// Initialized once on startup, never changes during app lifecycle
final ValueNotifier<bool> isStockUnuMdb = ValueNotifier<bool>(false);

/// Check if mdb-version matches stock UNU format (v1.15.0)
bool isStockMdbVersion(String? version) {
  if (version == null || version.isEmpty) return false;
  return RegExp(r'^v\d+\.\d+\.\d+$').hasMatch(version);
}
