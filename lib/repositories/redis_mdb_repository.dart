import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:redis/redis.dart';

import '../services/l10n_service.dart';
import '../services/serial_number_service.dart';
import '../services/toast_service.dart';
import 'mdb_repository.dart';

enum RedisConnectionState {
  connected,
  reconnecting,
  disconnected,
}

class ConnectionPool {
  final String host;
  final int port;
  final int maxConnections;
  final List<Command> _connections = [];
  final List<Completer<Command>> _waitingQueue = [];
  int _activeConnections = 0;

  ConnectionPool({
    required this.host,
    required this.port,
    this.maxConnections = 10,
  });

  Future<Command> getConnection() async {
    if (_connections.isNotEmpty) {
      return _connections.removeLast();
    }

    if (_activeConnections < maxConnections) {
      _activeConnections++;
      try {
        final con = RedisConnection();
        return await con.connect(host, port);
      } catch (e) {
        _activeConnections--;
        rethrow;
      }
    }

    final completer = Completer<Command>();
    _waitingQueue.add(completer);
    return completer.future;
  }

  void releaseConnection(Command cmd) {
    // If someone is waiting for a connection, give it to them directly
    if (_waitingQueue.isNotEmpty) {
      final completer = _waitingQueue.removeAt(0);
      completer.complete(cmd);
      return;
    }

    // Otherwise, return it to the pool
    _connections.add(cmd);
  }

  Future<void> closeAll() async {
    for (final cmd in _connections) {
      try {
        await cmd.get_connection().close();
      } catch (_) {}
    }
    _connections.clear();

    // Fail any waiters so they don't hang forever
    for (final completer in _waitingQueue) {
      completer.completeError(StateError('Connection pool reset'));
    }
    _waitingQueue.clear();

    _activeConnections = 0;
  }

  Future<void> dispose() async {
    for (final cmd in _connections) {
      try {
        await cmd.get_connection().close();
      } catch (_) {}
    }
    _connections.clear();
    for (final completer in _waitingQueue) {
      completer.completeError(StateError('Connection pool disposed'));
    }
    _waitingQueue.clear();
    _activeConnections = 0;
  }
}

class RedisMDBRepository implements MDBRepository {
  final ConnectionPool _pool;
  static const Duration _operationTimeout = Duration(seconds: 2);

  // When true, suppresses connection state toast notifications (used during UMS mode)
  bool suppressConnectionToasts = false;

  // Connection state management
  RedisConnectionState _connectionState = RedisConnectionState.connected;
  final _connectionStateController = StreamController<RedisConnectionState>.broadcast();
  Stream<RedisConnectionState> get connectionStateStream => _connectionStateController.stream;
  RedisConnectionState get connectionState => _connectionState;
  bool _hasEverConnected = false;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  // Track prolonged disconnection (>5s) for UI fallback
  static const Duration _prolongedDisconnectThreshold = Duration(seconds: 5);
  Timer? _prolongedDisconnectTimer;
  bool _prolongedDisconnect = false;
  final _prolongedDisconnectController = StreamController<bool>.broadcast();
  Stream<bool> get prolongedDisconnectStream => _prolongedDisconnectController.stream;
  bool get prolongedDisconnect => _prolongedDisconnect;

  static String getRedisHost() {
    final runtime = Platform.environment['SCOOTUI_REDIS_HOST'];
    if (runtime != null && runtime.isNotEmpty) return runtime;
    const compiled = String.fromEnvironment('SCOOTUI_REDIS_HOST',
        defaultValue: '192.168.7.1');
    return compiled;
  }

  static MDBRepository create(BuildContext context) {
    final repo = RedisMDBRepository(host: getRedisHost(), port: 6379);
    // Call dashboardReady without awaiting - errors will be handled internally
    repo.dashboardReady();
    return repo;
  }

  RedisMDBRepository({required String host, required int port})
      : _pool = ConnectionPool(host: host, port: port);

  void _updateConnectionState(RedisConnectionState newState) {
    if (_connectionState == newState) return;

    final oldState = _connectionState;
    final hadConnected = _hasEverConnected;
    _connectionState = newState;
    _connectionStateController.add(newState);

    if (newState == RedisConnectionState.connected) {
      _hasEverConnected = true;
      _prolongedDisconnectTimer?.cancel();
      _prolongedDisconnectTimer = null;
      if (_prolongedDisconnect) {
        _prolongedDisconnect = false;
        _prolongedDisconnectController.add(false);
      }
      // Re-send dashboard ready after (re)connection
      dashboardReady();
    } else if (oldState == RedisConnectionState.connected) {
      _prolongedDisconnectTimer?.cancel();
      _prolongedDisconnectTimer = Timer(_prolongedDisconnectThreshold, () {
        if (_connectionState != RedisConnectionState.connected) {
          _prolongedDisconnect = true;
          _prolongedDisconnectController.add(true);
        }
      });
    }

    // Suppress toasts until we've had at least one successful connection
    if (suppressConnectionToasts || !hadConnected) return;

    if (newState == RedisConnectionState.disconnected) {
      ToastService.showError(L10nService.current.connectionLost);
    } else if (newState == RedisConnectionState.reconnecting && oldState == RedisConnectionState.disconnected) {
      ToastService.showWarning(L10nService.current.connectionReconnecting);
    } else if (newState == RedisConnectionState.connected && oldState != RedisConnectionState.connected) {
      ToastService.showSuccess(L10nService.current.connectionRestored);
      _reconnectAttempts = 0;
    }
  }

  Future<T> _withConnection<T>(Future<T> Function(Command) action, {Duration? timeout, bool allowWhileDisconnected = false}) async {
    if (!allowWhileDisconnected && _connectionState != RedisConnectionState.connected) {
      throw StateError('Redis not connected');
    }

    Command? cmd;
    try {
      cmd = await _pool.getConnection().timeout(
        timeout ?? _operationTimeout,
        onTimeout: () => throw TimeoutException('Redis connection pool timeout'),
      );
      final result = await action(cmd).timeout(
        timeout ?? _operationTimeout,
        onTimeout: () => throw TimeoutException('Redis operation timeout'),
      );

      // Operation succeeded - mark as connected
      if (!_hasEverConnected) _hasEverConnected = true;
      if (_connectionState != RedisConnectionState.connected) {
        _updateConnectionState(RedisConnectionState.connected);
      }

      return result;
    } on TimeoutException catch (e) {
      if (_connectionState == RedisConnectionState.connected) {
        print('RedisMDBRepository: Operation timed out: $e');
      }
      // Discard broken connection instead of returning it to pool
      if (cmd != null) {
        try { cmd.get_connection().close(); } catch (_) {}
        cmd = null;
      }
      _handleConnectionFailure();
      rethrow;
    } catch (e) {
      if (_connectionState == RedisConnectionState.connected) {
        print('RedisMDBRepository: Operation failed: $e');
      }
      if (cmd != null) {
        try { cmd.get_connection().close(); } catch (_) {}
        cmd = null;
      }
      _handleConnectionFailure();
      rethrow;
    } finally {
      if (cmd != null) {
        _pool.releaseConnection(cmd);
      }
    }
  }


  @override
  Future<void> dashboardReady() async {
    try {
      // Read and publish the device serial number
      try {
        final serialNumber = await SerialNumberService.readSerialNumber();
        if (serialNumber != null) {
          await set("dashboard", "serial-number", serialNumber.toString());
          print('Published device serial number: $serialNumber');
        } else {
          print('Failed to read device serial number');
        }
      } catch (e) {
        print('Error publishing serial number: $e');
      }

      await set("dashboard", "ready", "true");
    } catch (e) {
      // Redis not available - will reconnect automatically
      print('dashboardReady failed (will retry on reconnect): $e');
    }
  }

  @override
  Future<void> set(String cluster, String variable, String value,
      {bool publish = true}) {
    return _withConnection((cmd) async {
      await cmd.send_object(["HSET", cluster, variable, value]);
      if (publish) {
        await cmd.send_object(["PUBLISH", cluster, variable]);
      }
    });
  }

  @override
  Future<void> publish(String channel, String message) {
    return _withConnection((cmd) async {
      await cmd.send_object(["PUBLISH", channel, message]);
    });
  }

  @override
  Future<List<(String, String)>> getAll(String cluster) {
    return _withConnection((cmd) async {
      final result = await cmd.send_object(["HGETALL", cluster]);
      final List<(String, String)> values = [];

      if (result is List) {
        for (int i = 0; i < result.length; i += 2) {
          final key = result[i].toString();
          final value = result[i + 1].toString();
          values.add((key, value));
        }
      }

      return values;
    });
  }

  @override
  Future<String?> get(String cluster, String variable) {
    return _withConnection((cmd) async {
      final result = await cmd.send_object(["HGET", cluster, variable]);
      if (result is String) {
        return result;
      }

      return null;
    });
  }

  @override
  Stream<(String, String)> subscribe(String channel) async* {
    // Create a dedicated connection for pubsub - DO NOT use the pool
    // Pubsub connections cannot be reused for regular commands
    Command? cmd;
    try {
      final con = RedisConnection();
      cmd = await con.connect(_pool.host, _pool.port).timeout(
        _operationTimeout,
        onTimeout: () => throw TimeoutException('Redis pubsub connection timeout'),
      );

      final ps = PubSub(cmd);
      ps.subscribe([channel]);

      yield* ps
          .getStream()
          .map((msg) {
            if (msg is List && msg.length >= 3 && msg[0] == 'message') {
              return (msg[1].toString(), msg[2].toString());
            }
            return null;
          })
          .where((result) => result != null)
          .map((rec) => rec!);
    } catch (e) {
      if (_connectionState == RedisConnectionState.connected) {
        print('RedisMDBRepository: Pubsub connection failed: $e');
      }
      _handleConnectionFailure();
      rethrow;
    } finally {
      // Close the dedicated pubsub connection - DO NOT return to pool
      if (cmd != null) {
        try {
          await cmd.get_connection().close();
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> hdel(String key, String field) {
    return _withConnection((cmd) async {
      await cmd.send_object(["HDEL", key, field]);
      // Publish notification so subscribers know the field was deleted
      await cmd.send_object(["PUBLISH", key, field]);
    });
  }

  void _handleConnectionFailure() {
    if (_connectionState == RedisConnectionState.connected) {
      _updateConnectionState(RedisConnectionState.disconnected);
      _startReconnecting();
    }
  }

  void _startReconnecting() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return; // Already reconnecting
    }

    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _attemptReconnect();
  }

  Future<void> _attemptReconnect() async {
    _reconnectAttempts++;
    _updateConnectionState(RedisConnectionState.reconnecting);

    // Exponential backoff: 1s, 2s, 5s, 10s, 10s, ...
    final delays = [1, 2, 5, 10];
    final delayIndex = _reconnectAttempts - 1;
    final delaySeconds = delayIndex < delays.length ? delays[delayIndex] : 10;

    print('RedisMDBRepository: Reconnection attempt $_reconnectAttempts in ${delaySeconds}s');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      try {
        // Close idle connections — active ones will fail on next use
        await _pool.closeAll();

        // Test connection with a simple PING
        await _withConnection((cmd) => cmd.send_object(['PING']), timeout: const Duration(seconds: 3), allowWhileDisconnected: true);

        // If we get here, connection succeeded
        _updateConnectionState(RedisConnectionState.connected);
        print('RedisMDBRepository: Reconnection successful');
      } catch (e) {
        print('RedisMDBRepository: Reconnection attempt $_reconnectAttempts failed: $e');
        // Schedule next attempt
        _attemptReconnect();
      }
    });
  }

  Future<void> dispose() async {
    _reconnectTimer?.cancel();
    _prolongedDisconnectTimer?.cancel();
    await _prolongedDisconnectController.close();
    await _connectionStateController.close();
    await _pool.dispose();
  }

  @override
  Future<void> push(String channel, String command) {
    return _withConnection(
        (cmd) => cmd.send_object(["LPUSH", channel, command]));
  }

  @override
  Future<void> publishButtonEvent(String event) {
    return _withConnection((cmd) {
      return cmd.send_object(["PUBLISH", "buttons", event]);
    });
  }

  @override
  Future<List<String>> getSetMembers(String setKey) {
    return _withConnection((cmd) async {
      final result = await cmd.send_object(["SMEMBERS", setKey]);
      final List<String> members = [];

      if (result is List) {
        for (final item in result) {
          members.add(item.toString());
        }
      }

      return members;
    });
  }

  @override
  Future<void> addToSet(String setKey, String member) {
    return _withConnection((cmd) async {
      await cmd.send_object(["SADD", setKey, member]);
    });
  }

  @override
  Future<void> removeFromSet(String setKey, String member) {
    return _withConnection((cmd) async {
      await cmd.send_object(["SREM", setKey, member]);
    });
  }
}
