import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../builders/sync/annotations.dart';
import '../builders/sync/settings.dart';
import '../repositories/mdb_repository.dart';

abstract class SyncableCubit<T extends Syncable<T>> extends Cubit<T> {
  final MDBRepository redisRepository;

  bool _isClosing = false;
  bool _isPaused = false;
  bool _hasLoggedError = false; // Track if we've already logged connection errors
  final Map<String, Timer> _timers = {};
  final Map<String, SyncFieldSettings> _fields = {};
  final Map<String, SyncSetFieldSettings> _setFields = {};
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _pubsubSubscription;

  void _doRefresh(String variable) {
    if (_isPaused || _isClosing) return;

    // print("SyncableCubit (${state.syncSettings.channel}): _doRefresh called for variable: $variable");
    redisRepository.get(state.syncSettings.channel, variable).then((value) {
      if (_isPaused || _isClosing) return;

      // Log recovery if we were in error state
      if (_hasLoggedError) {
        print("SyncableCubit (${state.syncSettings.channel}): Connection recovered");
        _hasLoggedError = false;
      }

      // print("SyncableCubit (${state.syncSettings.channel}): Got value for $variable: $value");
      if (value == null && variable != "destination") {
        // Allow 'destination' to be cleared (become null effectively)
        // print("SyncableCubit (${state.syncSettings.channel}): Value is null for $variable and it's not 'destination', returning.");
        return;
      }
      // If variable is 'destination' and value is null, it means it was cleared.
      // We should emit an update with an empty string or handle as cleared.
      // The `update` method in `NavigationData` should handle `null` appropriately for `destination`.
      emit(state.update(
          variable,
          value ??
              "")); // Pass empty string if null, or let `update` handle null
      _refresh(variable);
    }).catchError((e) {
      // Only log the first error to avoid spam
      if (!_hasLoggedError) {
        print(
            "SyncableCubit (${state.syncSettings.channel}): Redis connection error: $e");
        _hasLoggedError = true;
      }
      // Don't schedule next refresh on error - connection recovery will restart polling
    });
  }

  void _doRefreshSet(String name, SyncSetFieldSettings field) {
    if (_isPaused || _isClosing) return;

    // Interpolate discriminator if needed
    String interpolateKey(String key) {
      if (field.setKey.contains('\$')) {
        // Simple string interpolation for discriminator
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

      // Log recovery if we were in error state
      if (_hasLoggedError) {
        print("SyncableCubit (${state.syncSettings.channel}): Connection recovered");
        _hasLoggedError = false;
      }

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
      _refreshSet(name, field);
    }).catchError((e) {
      // Only log the first error to avoid spam
      if (!_hasLoggedError) {
        print(
            "SyncableCubit (${state.syncSettings.channel}): Redis connection error: $e");
        _hasLoggedError = true;
      }
      // Don't schedule next refresh on error - connection recovery will restart polling
    });
  }

  void refreshAllFields() {
    for (final field in state.syncSettings.fields) {
      _doRefresh(field.variable);
    }
    for (final field in state.syncSettings.setFields) {
      _doRefreshSet(field.name, field);
    }
  }

  void _refresh(String variable) {
    // print("SyncableCubit (${state.syncSettings.channel}): _refresh called for variable: $variable");
    if (_isClosing || _isPaused) return;

    Timer getTimer() {
      final newInterval =
          _fields[variable]?.interval ?? state.syncSettings.interval;

      return Timer(newInterval, () => _doRefresh(variable));
    }

    _timers.update(variable, (activeTimer) {
      activeTimer.cancel();
      return getTimer();
    }, ifAbsent: getTimer);
  }

  void _refreshSet(String name, SyncSetFieldSettings field) {
    if (_isClosing || _isPaused) return;

    Timer getTimer() {
      final newInterval = field.interval ?? state.syncSettings.interval;
      return Timer(newInterval, () => _doRefreshSet(name, field));
    }

    final timerKey = "set:$name";
    _timers.update(timerKey, (activeTimer) {
      activeTimer.cancel();
      return getTimer();
    }, ifAbsent: getTimer);
  }

  void _pausePolling() {
    if (_isPaused) return;
    _isPaused = true;

    // Cancel all active timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    // Cancel PUBSUB subscription
    _pubsubSubscription?.cancel();
    _pubsubSubscription = null;

    print("SyncableCubit (${state.syncSettings.channel}): Polling paused");
  }

  void _resumePolling() {
    if (!_isPaused) return;
    _isPaused = false;
    _hasLoggedError = false; // Reset error state on connection recovery

    print("SyncableCubit (${state.syncSettings.channel}): Polling resumed, fetching current values");

    // Immediately fetch all current values
    for (final field in state.syncSettings.fields) {
      _doRefresh(field.variable);
    }

    // Immediately fetch all set field values
    for (final field in state.syncSettings.setFields) {
      _doRefreshSet(field.name, field);
    }

    // Restart PUBSUB subscription
    _setupPubsubSubscription();
  }

  void _setupPubsubSubscription() {
    final settings = state.syncSettings;

    // Cancel existing subscription if any
    _pubsubSubscription?.cancel();

    print("SyncableCubit (${state.syncSettings.channel}): Setting up PUBSUB subscription");

    try {
      _pubsubSubscription = redisRepository.subscribe(settings.channel).listen(
        (rec) {
          if (_isPaused || _isClosing) return;

          final (channel, pubSubVar) = rec;
          // print("SyncableCubit (${state.syncSettings.channel}): Received PUBSUB message on channel '$channel': $pubSubVar");

          if (channel == settings.channel) {
            // Check if this is a set field update
            final setField = _setFields[pubSubVar];
            if (setField != null) {
              _doRefreshSet(pubSubVar, setField);
            } else {
              _doRefresh(pubSubVar);
            }
          }
        },
        onError: (e) {
          print("SyncableCubit (${state.syncSettings.channel}): Error in PUBSUB subscription: $e");
          // Don't restart here - let connection recovery handle it
        },
        onDone: () {
          print("SyncableCubit (${state.syncSettings.channel}): PUBSUB subscription closed");
        },
        cancelOnError: false,
      );
    } catch (e) {
      print("SyncableCubit (${state.syncSettings.channel}): Error setting up PUBSUB subscription: $e");
      // Will retry when connection is restored
    }
  }

  void _setupConnectionStateListener() {
    // Check if repository supports connection state monitoring
    try {
      final dynamic repo = redisRepository;
      final hasStream = repo.connectionStateStream != null;

      if (hasStream) {
        print("SyncableCubit (${state.syncSettings.channel}): Setting up connection state listener");
        _connectionStateSubscription = (repo.connectionStateStream as Stream).listen((connectionState) {
          final stateStr = connectionState.toString().split('.').last;
          print("SyncableCubit (${state.syncSettings.channel}): Connection state changed to $stateStr");

          if (stateStr == 'connected') {
            _resumePolling();
          } else if (stateStr == 'disconnected' || stateStr == 'reconnecting') {
            _pausePolling();
          }
        });
      } else {
        print("SyncableCubit (${state.syncSettings.channel}): Repository does not support connection state monitoring");
      }
    } catch (e) {
      print("SyncableCubit (${state.syncSettings.channel}): Error setting up connection state listener: $e");
    }
  }

  void start() {
    final settings = state.syncSettings;

    // Set up connection state monitoring
    _setupConnectionStateListener();

    redisRepository.getAll(settings.channel).then((values) {
      if (values.isEmpty) return;

      T newState = state;
      for (final (variable, value) in values) {
        newState = newState.update(variable, value);
      }

      emit(newState);
    }).catchError((e) {
      print("SyncableCubit (${state.syncSettings.channel}): Error in initial getAll: $e");
      // Don't crash - polling will fetch values when connection recovers
    });

    // set up all field timers
    for (final field in settings.fields) {
      _fields[field.variable] = field;
      _refresh(field.variable);
    }

    // set up all set field timers
    for (final field in settings.setFields) {
      _setFields[field.name] = field;
      _doRefreshSet(field.name, field);
    }

    // Set up PUBSUB subscription
    _setupPubsubSubscription();
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    _timers.forEach((_, timer) => timer.cancel());
    await _connectionStateSubscription?.cancel();
    await _pubsubSubscription?.cancel();

    return super.close();
  }

  SyncableCubit({
    required this.redisRepository,
    required T initialState,
  }) : super(initialState);
}
