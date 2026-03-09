import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';
import '../repositories/mdb_repository.dart';

/// Syncs cubit state from Redis using periodic HGETALL + pubsub notifications.
///
/// Each cubit polls its Redis hash at the interval defined by its @StateClass
/// annotation. Pubsub messages trigger an immediate HGETALL and reset the
/// timer, so updates arrive promptly without per-field GET calls.
abstract class SyncableCubit<T extends Syncable<T>> extends Cubit<T> {
  final MDBRepository redisRepository;

  bool _isClosing = false;
  bool _isPaused = false;
  bool _hasLoggedError = false;

  Timer? _pollTimer;
  Timer? _pubsubDebounce;
  final Map<String, Timer> _setTimers = {};
  final Map<String, SyncSetFieldSettings> _setFields = {};

  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _pubsubSubscription;

  /// Fields where null/empty from HGETALL means "cleared" rather than "absent".
  static const _nullableClearableFields = {'destination'};

  void _doHgetall() {
    if (_isPaused || _isClosing) return;

    redisRepository.getAll(state.syncSettings.channel).then((values) {
      if (_isPaused || _isClosing) return;

      if (_hasLoggedError) {
        print("SyncableCubit (${state.syncSettings.channel}): Connection recovered");
        _hasLoggedError = false;
      }

      _applyHgetallResult(values);
    }).catchError((e) {
      if (!_hasLoggedError) {
        print("SyncableCubit (${state.syncSettings.channel}): Redis error: $e");
        _hasLoggedError = true;
      }
    });
  }

  void _applyHgetallResult(List<(String, String)> values) {
    final received = <String, String>{};
    for (final (key, value) in values) {
      received[key] = value;
    }

    T newState = state;
    bool changed = false;

    for (final field in state.syncSettings.fields) {
      final value = received[field.variable];
      if (value != null) {
        final updated = newState.update(field.variable, value);
        if (updated != newState) {
          newState = updated;
          changed = true;
        }
      } else if (_nullableClearableFields.contains(field.variable)) {
        final updated = newState.update(field.variable, "");
        if (updated != newState) {
          newState = updated;
          changed = true;
        }
      }
    }

    if (changed) {
      emit(newState);
    }
  }

  void _startPollTimer() {
    _pollTimer?.cancel();
    final interval = state.syncSettings.interval;
    _pollTimer = Timer.periodic(interval, (_) => _doHgetall());
  }

  void _onPubsubMessage(String variable) {
    if (_isPaused || _isClosing) return;

    // Check if this is a set field
    final setField = _setFields[variable];
    if (setField != null) {
      _doRefreshSet(variable, setField);
      return;
    }

    // Debounce: coalesce rapid pubsub messages into a single HGETALL
    _pubsubDebounce?.cancel();
    _pubsubDebounce = Timer(const Duration(milliseconds: 50), () {
      _doHgetall();
      _startPollTimer(); // Reset periodic timer after pubsub-triggered fetch
    });
  }

  void _doRefreshSet(String name, SyncSetFieldSettings field) {
    if (_isPaused || _isClosing) return;

    String interpolateKey(String key) {
      if (field.setKey.contains('\$')) {
        final discriminator = state.syncSettings.discriminator;
        if (discriminator != null) {
          final discriminatorValue = (state as dynamic).id ?? '';
          return key.replaceAll('\$$discriminator', discriminatorValue);
        }
      }
      return key;
    }

    final setKey = interpolateKey(field.setKey);

    redisRepository.getSetMembers(setKey).then((members) {
      if (_isPaused || _isClosing) return;

      Set<dynamic> parsedSet;
      switch (field.elementType) {
        case SyncFieldType.set_int:
          parsedSet = members.map((m) => int.tryParse(m) ?? 0).toSet();
          break;
        case SyncFieldType.set_string:
          parsedSet = members.toSet();
          break;
        default:
          parsedSet = members.toSet();
      }

      emit(state.updateSet(name, parsedSet));
    }).catchError((e) {
      if (!_hasLoggedError) {
        print("SyncableCubit (${state.syncSettings.channel}): Redis error (set): $e");
        _hasLoggedError = true;
      }
    });
  }

  void _scheduleSetTimer(String name, SyncSetFieldSettings field) {
    final interval = field.interval ?? state.syncSettings.interval;
    _setTimers[name]?.cancel();
    _setTimers[name] = Timer.periodic(interval, (_) => _doRefreshSet(name, field));
  }

  void refreshAllFields() {
    _doHgetall();
    for (final field in state.syncSettings.setFields) {
      _doRefreshSet(field.name, field);
    }
  }

  void _pausePolling() {
    if (_isPaused) return;
    _isPaused = true;

    _pollTimer?.cancel();
    _pollTimer = null;
    _pubsubDebounce?.cancel();
    _pubsubDebounce = null;

    for (final timer in _setTimers.values) {
      timer.cancel();
    }
    _setTimers.clear();

    _pubsubSubscription?.cancel();
    _pubsubSubscription = null;

    print("SyncableCubit (${state.syncSettings.channel}): Polling paused");
  }

  void _resumePolling() {
    if (!_isPaused) return;
    _isPaused = false;
    _hasLoggedError = false;

    print("SyncableCubit (${state.syncSettings.channel}): Polling resumed");

    _doHgetall();
    _startPollTimer();

    for (final field in state.syncSettings.setFields) {
      _doRefreshSet(field.name, field);
      _scheduleSetTimer(field.name, field);
    }

    _setupPubsubSubscription();
  }

  void _setupPubsubSubscription() {
    _pubsubSubscription?.cancel();

    try {
      _pubsubSubscription = redisRepository.subscribe(state.syncSettings.channel).listen(
        (rec) {
          if (_isPaused || _isClosing) return;
          final (channel, variable) = rec;
          if (channel == state.syncSettings.channel) {
            _onPubsubMessage(variable);
          }
        },
        onError: (e) {
          print("SyncableCubit (${state.syncSettings.channel}): PUBSUB error: $e");
        },
        onDone: () {
          print("SyncableCubit (${state.syncSettings.channel}): PUBSUB closed");
          if (!_isPaused && !_isClosing) {
            _setupPubsubSubscription();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      print("SyncableCubit (${state.syncSettings.channel}): PUBSUB setup error: $e");
    }
  }

  void _setupConnectionStateListener() {
    try {
      final dynamic repo = redisRepository;
      final hasStream = repo.connectionStateStream != null;

      if (hasStream) {
        _connectionStateSubscription = (repo.connectionStateStream as Stream).listen((connectionState) {
          final stateStr = connectionState.toString().split('.').last;

          if (stateStr == 'connected') {
            _resumePolling();
          } else if (stateStr == 'disconnected' || stateStr == 'reconnecting') {
            _pausePolling();
          }
        });
      }
    } catch (e) {
      // Repository doesn't support connection state monitoring
    }
  }

  void start() {
    final settings = state.syncSettings;

    _setupConnectionStateListener();

    // If already disconnected before we subscribed, pre-pause so
    // _resumePolling() will act when connection is restored.
    try {
      final dynamic repo = redisRepository;
      final connState = repo.connectionState?.toString().split('.').last;
      if (connState == 'disconnected' || connState == 'reconnecting') {
        _isPaused = true;
        print("SyncableCubit (${state.syncSettings.channel}): Starting paused (already disconnected)");
        return;
      }
    } catch (_) {}

    _doHgetall();
    _startPollTimer();

    for (final field in settings.setFields) {
      _setFields[field.name] = field;
      _doRefreshSet(field.name, field);
      _scheduleSetTimer(field.name, field);
    }

    _setupPubsubSubscription();
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    _pollTimer?.cancel();
    _pubsubDebounce?.cancel();
    for (final timer in _setTimers.values) {
      timer.cancel();
    }
    await _connectionStateSubscription?.cancel();
    await _pubsubSubscription?.cancel();

    return super.close();
  }

  SyncableCubit({
    required this.redisRepository,
    required T initialState,
  }) : super(initialState);
}
