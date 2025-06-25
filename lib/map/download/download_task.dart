import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/task_service.dart';

part 'download_task.freezed.dart';

@freezed
abstract class MapDownloadTask extends Task<void> with _$MapDownloadTask {
  factory MapDownloadTask({
    required String url,
    required String destination,
  }) = _MapDownloadTask;

  MapDownloadTask._();

  @override
  String get name => "Map Download";

  Future<void> _download() async {
    final file = File(destination);

    if(await file.exists()) {

    }

    await file.parent.create(recursive: true);
    final raf = await file.open(mode: FileMode.write);
    final dio = Dio();

    step("Requesting map from $url");
    final response = await dio
        .get(url, options: Options(responseType: ResponseType.stream),
            onReceiveProgress: (received, total) {
      if (total > 0) {
        progress(received.toDouble() / total.toDouble());
      }
    });

    try {
      if (response.statusCode == 200) {
        step(url);
        final stream = response.data as ResponseBody;
        await for (var chunk in stream.stream) {
          await raf.writeFrom(chunk);
        }
      } else {
        throw Exception("Failed to download map: ${response.statusMessage}");
      }
    } finally {
      await raf.close();
    }
  }

  @override
  Future<void> run() async {
    await _download();
  }
}
