import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:redis/redis.dart';

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
  Timer? _healthCheckTimer;
  final Duration _healthCheckInterval = const Duration(seconds: 10);

  ConnectionPool({
    required this.host,
    required this.port,
    this.maxConnections = 50,
  }) {
    _startHealthCheck();
  }

  void _startHealthCheck() {
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
      _checkConnections();
    });
  }

  Future<void> _checkConnections() async {
    if (_connections.isEmpty) return;

    final List<Command> validConnections = [];

    for (final cmd in List.from(_connections)) {
      try {
        // Use PING command to check if connection is still alive
        final result = await cmd.send_object(["PING"]);
        if (result == "PONG") {
          validConnections.add(cmd);
        } else {
          _activeConnections--;
        }
      } catch (e) {
        cmd.get_connection().close();
        _activeConnections--;
        // Connection is invalid, discard it
      }
    }

    _connections
      ..clear()
      ..addAll(validConnections);
  }

  Future<Command> getConnection() async {
    // If there's an available connection, return it immediately
    if (_connections.isNotEmpty) {
      return _connections.removeLast();
    }

    // If we haven't reached max connections yet, create a new one
    if (_activeConnections < maxConnections) {
      _activeConnections++;
      final con = RedisConnection();
      return await con.connect(host, port);
    }

    // If we reached here, we need to wait for a connection to be released
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

  Future<void> dispose() async {
    _healthCheckTimer?.cancel();

    // Close all connections in the pool
    for (final cmd in _connections) {
      try {
        await cmd.get_connection().close();
      } catch (_) {
        // Ignore errors during disposal
      }
    }
    _connections.clear();
    _activeConnections = 0;
  }
}

class RedisMDBRepository implements MDBRepository {
  final ConnectionPool _pool;
  static const Duration _operationTimeout = Duration(seconds: 10);

  // Connection state management
  RedisConnectionState _connectionState = RedisConnectionState.connected;
  final _connectionStateController = StreamController<RedisConnectionState>.broadcast();
  Stream<RedisConnectionState> get connectionStateStream => _connectionStateController.stream;
  RedisConnectionState get connectionState => _connectionState;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  static String getRedisHost() {
    // Use an environment variable to determine the Redis host, defaulting to the target system address
    const redisHost = String.fromEnvironment('SCOOTUI_REDIS_HOST',
        defaultValue: '192.168.7.1');
    return redisHost;
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
    _connectionState = newState;
    _connectionStateController.add(newState);

    // Show user notifications for state changes
    if (newState == RedisConnectionState.disconnected) {
      ToastService.showError('Connection to vehicle system lost');
    } else if (newState == RedisConnectionState.reconnecting && oldState == RedisConnectionState.disconnected) {
      ToastService.showWarning('Attempting to reconnect to vehicle system...');
    } else if (newState == RedisConnectionState.connected && oldState != RedisConnectionState.connected) {
      ToastService.showSuccess('Connected to vehicle system');
      _reconnectAttempts = 0;
    }
  }

  Future<T> _withConnection<T>(Future<T> Function(Command) action, {Duration? timeout}) async {
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

      // Operation succeeded - ensure we're in connected state
      if (_connectionState != RedisConnectionState.connected) {
        _updateConnectionState(RedisConnectionState.connected);
      }

      return result;
    } on TimeoutException catch (e) {
      // Only log if we're currently connected (unexpected timeout)
      if (_connectionState == RedisConnectionState.connected) {
        print('RedisMDBRepository: Operation timed out: $e');
      }
      _handleConnectionFailure();
      rethrow;
    } catch (e) {
      // Only log if we're currently connected (unexpected error)
      if (_connectionState == RedisConnectionState.connected) {
        print('RedisMDBRepository: Operation failed: $e');
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
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('RedisMDBRepository: Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    _updateConnectionState(RedisConnectionState.reconnecting);

    // Exponential backoff: 1s, 2s, 5s, 10s, 10s, ...
    final delays = [1, 2, 5, 10];
    final delayIndex = _reconnectAttempts - 1;
    final delaySeconds = delayIndex < delays.length ? delays[delayIndex] : 10;

    print('RedisMDBRepository: Reconnection attempt $_reconnectAttempts in ${delaySeconds}s');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      try {
        // Try to recreate connection pool
        await _pool.dispose();

        // Test connection with a simple PING
        await _withConnection((cmd) => cmd.send_object(['PING']), timeout: const Duration(seconds: 5));

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
      print('RedisMDBRepository: Publishing button event: $event');
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
