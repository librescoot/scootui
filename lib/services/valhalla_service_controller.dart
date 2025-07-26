import 'dart:io';

class ValhallaServiceController {
  static const String _serviceName = 'valhalla.service';

  Future<void> stop() async {
    // final result = await Process.run('systemctl', ['stop', _serviceName]);
    // if (result.exitCode != 0) {
    //   throw Exception('Failed to stop valhalla service: ${result.stderr}');
    // }
  }

  Future<void> start() async {
    // final result = await Process.run('systemctl', ['start', _serviceName]);
    // if (result.exitCode != 0) {
    //   throw Exception('Failed to start valhalla service: ${result.stderr}');
    // }
  }

  Future<bool> isRunning() async {
    return true;
    // final result = await Process.run('systemctl', ['is-active', _serviceName]);
    // // is-active returns exit code 0 if it is active, and non-zero otherwise.
    // // The output will be "active" or "inactive".
    // return result.exitCode == 0 && result.stdout.toString().trim() == 'active';
  }
}
