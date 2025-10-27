import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

abstract class MDBRepository {
  Future<String?> get(String channel, String variable);

  Future<List<(String, String)>> getAll(String channel);

  Future<void> set(String channel, String variable, String value,
      {bool publish = true});

  Future<void> publish(String channel, String message);

  Stream<(String, String)> subscribe(String channel);

  Future<void> push(String channel, String command);

  Future<void> dashboardReady();

  // For direct button events via PUBSUB
  Future<void> publishButtonEvent(String event);

  // For Redis sets
  Future<List<String>> getSetMembers(String setKey);
  Future<void> addToSet(String setKey, String member);
  Future<void> removeFromSet(String setKey, String member);

  Future<void> hdel(String key, String field);
}

class InMemoryMDBRepository implements MDBRepository {
  static MDBRepository create(BuildContext context) {
    return InMemoryMDBRepository();
  }

  final Map<String, Map<String, String>> _storage = {};
  final Map<String, List<StreamController<(String, String)>>> _subscribers = {};
  Timer? _brightnessSimulationTimer;

  InMemoryMDBRepository() {
    _startIlluminationSimulation();
  }

  /// Start simulating brightness sensor data for testing auto theme
  void _startIlluminationSimulation() {
    // Set initial brightness value
    set('dashboard', 'brightness', '20.0', publish: false);

    // Simulate changing brightness every 10 seconds for testing
    _brightnessSimulationTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) {
      final random = Random();
      // Simulate brightness values between 5 and 50 lux
      final brightness = 5.0 + random.nextDouble() * 45.0;
      set('dashboard', 'brightness', brightness.toStringAsFixed(1));
      print(
          'InMemoryMDBRepository: Simulated brightness: ${brightness.toStringAsFixed(1)} lux');
    });
  }

  @override
  Future<void> publishButtonEvent(String event) async {
    // For simulator, create a message on the 'buttons' channel
    final controller = StreamController<(String, String)>();

    _subscribers.putIfAbsent('buttons', () => []).add(controller);
    controller.add(('buttons', event));

    // Cleanup after simulating the event
    await Future.delayed(Duration.zero);
    _subscribers['buttons']?.remove(controller);
    await controller.close();

    print('InMemoryMDBRepository: Published button event: $event');
  }

  @override
  Future<String?> get(String channel, String variable) async {
    return _storage[channel]?[variable];
  }

  @override
  Future<List<(String, String)>> getAll(String channel) async {
    final channelData = _storage[channel] ?? {};
    return channelData.entries.map((e) => (e.key, e.value)).toList();
  }

  @override
  Future<void> set(String channel, String variable, String value,
      {bool publish = true}) async {
    _storage.putIfAbsent(channel, () => {});
    _storage[channel]![variable] = value;

    if (publish) {
      // Notify subscribers
      if (_subscribers.containsKey(channel)) {
        for (var controller in _subscribers[channel]!) {
          controller.add((channel, variable));
        }
      }
    }
  }

  @override
  Future<void> publish(String channel, String message) async {
    // Notify subscribers with the message
    if (_subscribers.containsKey(channel)) {
      for (var controller in _subscribers[channel]!) {
        controller.add((channel, message));
      }
    }
  }

  @override
  Stream<(String, String)> subscribe(String channel) {
    final controller = StreamController<(String, String)>();

    _subscribers.putIfAbsent(channel, () => []);
    _subscribers[channel]!.add(controller);

    controller.onCancel = () {
      _subscribers[channel]?.remove(controller);
      if (_subscribers[channel]?.isEmpty ?? false) {
        _subscribers.remove(channel);
      }
    };

    return controller.stream;
  }

  Future<void> dispose() async {
    _brightnessSimulationTimer?.cancel();
    for (var controllers in _subscribers.values) {
      for (var controller in controllers) {
        await controller.close();
      }
    }
    _subscribers.clear();
  }

  @override
  Future<void> push(String channel, String command) async {
    // scooter:state lock/unlock/lock-hibernate
    // scooter:seatbox open
    // scooter:horn on/off
    // scooter:blinker left/right/both/off
    // scooter:power reboot/hibernate-manual

    // simulate the mdb handling our commands
    switch (channel) {
      case 'scooter:blinker':
        await set("vehicle", "blinker:state", command);
    }
  }

  @override
  Future<void> dashboardReady() async {
    await set("dashboard", "ready", "true");
  }

  // Separate storage for Sets to avoid confusion with hashes
  final Map<String, Set<String>> _setStorage = {};

  @override
  Future<List<String>> getSetMembers(String setKey) async {
    // For in-memory implementation, we maintain a separate storage for Sets
    final setData = _setStorage[setKey] ?? {};
    return setData.toList();
  }

  @override
  Future<void> addToSet(String setKey, String member) async {
    _setStorage.putIfAbsent(setKey, () => {});
    _setStorage[setKey]!.add(member);
  }

  @override
  Future<void> removeFromSet(String setKey, String member) async {
    _setStorage[setKey]?.remove(member);
    if (_setStorage[setKey]?.isEmpty ?? false) {
      _setStorage.remove(setKey);
    }
  }

  @override
  Future<void> hdel(String key, String field) async {
    final channelData = _storage[key];
    if (channelData != null) {
      if (channelData.containsKey(field)) {
        channelData.remove(field);
        print('InMemoryMDBRepository: HDEL $key $field');

        // Notify subscribers that the field effectively changed (to non-existent/empty)
        // This helps SyncableCubit to refresh if it's listening.
        // SyncableCubit's _doRefresh fetches the value; if null, it might not update.
        // A common pattern after HDEL is to then HSET to "" if PUBSUB is desired for "empty".
        // Or, the PUBSUB message could be special for deletions.
        // For now, we can simulate what HSET field "" would do for PUBSUB.
        if (_subscribers.containsKey(key)) {
          for (var controller in _subscribers[key]!) {
            // Sending the variable name implies it changed. SyncableCubit's get() will return null.
            controller.add((key, field));
          }
        }
      }
    }
  }
}
