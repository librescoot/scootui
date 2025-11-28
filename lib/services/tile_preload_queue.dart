import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:vector_map_tiles/vector_map_tiles.dart';

/// A double-ended queue for tile loading with priority support.
///
/// Urgent tiles (from visible map) are added to the front via [pushFront].
/// Preload tiles (from route prediction) are added to the back via [pushBack].
/// A single worker processes tiles sequentially, always prioritizing urgent tiles.
class TilePreloadQueue {
  // Two separate queues - urgent always processed first
  final Queue<TileIdentity> _urgentQueue = Queue<TileIdentity>();
  final Queue<TileIdentity> _preloadQueue = Queue<TileIdentity>();

  final Set<String> _inQueue = {};
  final Set<String> _processed = {};

  /// Callback to fetch tile data - should be connected to the actual tile provider
  Future<Uint8List> Function(TileIdentity tile)? _fetchTile;

  bool _isProcessing = false;
  bool _isDisposed = false;
  Timer? _processingTimer;

  /// Maximum number of tiles to keep in the processed set to avoid memory growth
  static const int _maxProcessedCache = 1000;

  int _urgentCount = 0;
  int _preloadCount = 0;

  TilePreloadQueue();

  /// Set the tile fetch callback
  void setFetchCallback(Future<Uint8List> Function(TileIdentity tile) callback) {
    _fetchTile = callback;
  }

  /// Add a tile to the urgent queue (for visible map)
  void pushFront(TileIdentity tile) {
    if (_isDisposed) return;

    final key = _tileKey(tile);
    if (_inQueue.contains(key) || _processed.contains(key)) {
      return; // Already queued or processed
    }

    _urgentQueue.addLast(tile);
    _inQueue.add(key);
    _urgentCount++;
    // Only log every 10th urgent tile to reduce noise
    if (_urgentCount % 10 == 1) {
      print('TileQueue: [$_urgentCount] Added URGENT tile $key (urgent: ${_urgentQueue.length}, preload: ${_preloadQueue.length})');
    }
    _startProcessing();
  }

  /// Add a tile to the preload queue (for route ahead)
  void pushBack(TileIdentity tile) {
    if (_isDisposed) return;

    final key = _tileKey(tile);
    if (_inQueue.contains(key) || _processed.contains(key)) {
      return; // Already queued or processed
    }

    _preloadQueue.addLast(tile);
    _inQueue.add(key);
    _preloadCount++;
    _startProcessing();
  }

  /// Add multiple tiles to the preload queue (batch preload)
  void pushBackBatch(List<TileIdentity> tiles) {
    if (tiles.isEmpty) return;

    int addedCount = 0;
    for (final tile in tiles) {
      final key = _tileKey(tile);
      if (!_inQueue.contains(key) && !_processed.contains(key)) {
        addedCount++;
      }
      pushBack(tile);
    }

    if (addedCount > 0) {
      print('TileQueue: Added $addedCount PRELOAD tiles (urgent: ${_urgentQueue.length}, preload: ${_preloadQueue.length}, total preload requests: $_preloadCount)');
    }
  }

  /// Clear all preload tiles from the queue (keeps urgent tiles)
  /// This is useful when route changes and we need to restart preloading
  void clearPreload() {
    final clearedCount = _preloadQueue.length;

    // Remove preload tiles from the in-queue tracking
    for (final tile in _preloadQueue) {
      _inQueue.remove(_tileKey(tile));
    }

    _preloadQueue.clear();

    if (clearedCount > 0) {
      print('TileQueue: Cleared $clearedCount PRELOAD tiles (urgent queue preserved: ${_urgentQueue.length} tiles)');
    }
  }

  /// Clear all tiles from the queue and reset processing state
  void clear() {
    final urgentCount = _urgentQueue.length;
    final preloadCount = _preloadQueue.length;

    _urgentQueue.clear();
    _preloadQueue.clear();
    _inQueue.clear();
    _processed.clear();

    print('TileQueue: Cleared entire queue ($urgentCount urgent + $preloadCount preload tiles removed, stats reset)');
  }

  /// Start the processing worker if not already running
  void _startProcessing() {
    if (_isProcessing || _isDisposed || _fetchTile == null) {
      return;
    }

    _isProcessing = true;
    _processNext();
  }

  /// Process the next tile in the queue
  /// Always processes urgent tiles first, then preload tiles
  Future<void> _processNext() async {
    if (_isDisposed || _fetchTile == null) {
      _isProcessing = false;
      return;
    }

    // Check if we have any tiles to process (urgent first, then preload)
    if (_urgentQueue.isEmpty && _preloadQueue.isEmpty) {
      _isProcessing = false;
      print('TileQueue: Queue empty, processing stopped. (processed: ${_processed.length}, urgent: $_urgentCount, preload: $_preloadCount)');
      return;
    }

    // Always prioritize urgent tiles
    final TileIdentity tile;
    final String priority;

    if (_urgentQueue.isNotEmpty) {
      tile = _urgentQueue.removeFirst();
      priority = 'URGENT';
    } else {
      tile = _preloadQueue.removeFirst();
      priority = 'PRELOAD';
    }

    final key = _tileKey(tile);
    _inQueue.remove(key);

    print('TileQueue: Processing $priority tile $key (urgent: ${_urgentQueue.length}, preload: ${_preloadQueue.length})');

    try {
      // Fetch the tile (this will populate caches)
      await _fetchTile!(tile);

      // Mark as processed
      _processed.add(key);
      print('TileQueue: ✓ Successfully fetched $priority tile $key');

      // Limit the size of processed set
      if (_processed.length > _maxProcessedCache) {
        // Remove oldest entries (approximate LRU by removing first half)
        final toRemove = _processed.take(_maxProcessedCache ~/ 2).toList();
        _processed.removeAll(toRemove);
      }
    } catch (e) {
      // Log all errors with details
      print('TileQueue: ✗ Failed to fetch $priority tile $key: $e');
    }

    // Small delay to avoid overwhelming the system
    // Process one tile at a time - urgent tiles get 50ms delay, preload tiles get 200ms
    final delay = priority == 'URGENT'
        ? const Duration(milliseconds: 50)
        : const Duration(milliseconds: 200);

    if (!_isDisposed) {
      _processingTimer = Timer(delay, _processNext);
    } else {
      _isProcessing = false;
    }
  }

  /// Get a unique key for a tile
  String _tileKey(TileIdentity tile) {
    return '${tile.z}/${tile.x}/${tile.y}';
  }

  /// Get the current total queue size
  int get queueSize => _urgentQueue.length + _preloadQueue.length;

  /// Get the urgent queue size
  int get urgentQueueSize => _urgentQueue.length;

  /// Get the preload queue size
  int get preloadQueueSize => _preloadQueue.length;

  /// Check if the queue is processing
  bool get isProcessing => _isProcessing;

  /// Dispose the queue and stop processing
  void dispose() {
    print('TileQueue: Disposing queue. Final stats - Urgent: $_urgentCount, Preload: $_preloadCount, Processed: ${_processed.length}');
    _isDisposed = true;
    _processingTimer?.cancel();
    _processingTimer = null;
    _urgentQueue.clear();
    _preloadQueue.clear();
    _inQueue.clear();
    _processed.clear();
    _isProcessing = false;
  }
}
