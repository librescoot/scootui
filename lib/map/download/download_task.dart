import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/task_service.dart';

part 'download_task.freezed.dart';

@freezed
abstract class DownloadTask extends Task<void> with _$DownloadTask {
  factory DownloadTask({
    required String url,
    required String destination,
    String? description,
  }) = _DownloadTask;

  DownloadTask._();

  @override
  String get name => description ?? "Download";

  Future<void> _download() async {
    // download to a temporary file in the same directory
    final tempFile = File('$destination.tmp');

    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      await tempFile.parent.create(recursive: true);

      final raf = await tempFile.open(mode: FileMode.write);
      final dio = Dio();

      step("Downloading $url");
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
          throw Exception("Failed to download: ${response.statusMessage}");
        }
      } finally {
        await raf.close();
      }
      await tempFile.rename(destination);
    } catch (e) {
      // on error, delete the temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      rethrow;
    }
  }

  @override
  Future<void> run() async {
    await _download();
  }
}
