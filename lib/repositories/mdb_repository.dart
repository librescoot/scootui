import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class MDBRepository {
  Future<String?> get(String channel, String variable);

  Future<List<(String, String)>> getAll(String channel);

  Future<void> set(String channel, String variable, String value, {bool publish = true});

  Stream<(String, String)> subscribe(String channel);

  Future<void> push(String channel, String command);

  Future<void> dashboardReady();

  // For direct button events via PUBSUB
  Future<void> publishButtonEvent(String event);

  // For Redis sets
  Future<List<String>> getSetMembers(String setKey);
}

class InMemoryMDBRepository implements MDBRepository {
  static MDBRepository create(BuildContext context) {
    return InMemoryMDBRepository();
  }

  final Map<String, Map<String, String>> _storage = {};
  final Map<String, List<StreamController<(String, String)>>> _subscribers = {};

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
  Future<void> set(String channel, String variable, String value, {bool publish = true}) async {
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
    // Get the current vehicle state
    final vehicleState = await get("vehicle", "state");

    // Only set dashboard as ready if the vehicle is not in updating state
    if (vehicleState != "updating") {
      await set("dashboard", "ready", "true");
    }
  }

  @override
  Future<List<String>> getSetMembers(String setKey) async {
    // For in-memory implementation, we'll simulate Redis sets using a special format
    // in our storage map: setKey -> {"member1": "1", "member2": "1", ...}
    final setData = _storage[setKey] ?? {};
    return setData.keys.toList();
  }
}
