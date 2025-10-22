import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

part 'carplay_state.dart';
part 'carplay_cubit.freezed.dart';

class CarPlayCubit extends Cubit<CarPlayState> {
  static const String backendUrl = 'http://localhost:8001';
  static const String streamEndpoint = '/stream';
  static const String touchEndpoint = '/touch';
  static const String statusEndpoint = '/status';

  VideoPlayerController? _controller;
  final http.Client _httpClient = http.Client();

  CarPlayCubit() : super(const CarPlayState.disconnected());

  /// Connect to the CarPlay backend and initialize video player
  Future<void> connect() async {
    try {
      emit(const CarPlayState.connecting());

      // Step 1: Check backend status with retry logic
      bool serverReady = false;
      int retryCount = 0;
      const maxRetries = 10;

      while (!serverReady && retryCount < maxRetries) {
        try {
          debugPrint('Checking server status (attempt ${retryCount + 1}/$maxRetries)...');
          final statusResponse = await _httpClient
              .get(Uri.parse('$backendUrl$statusEndpoint'))
              .timeout(const Duration(seconds: 5));

          if (statusResponse.statusCode == 200) {
            final status = jsonDecode(statusResponse.body);
            if (status['status'] == 'ready') {
              serverReady = true;
              debugPrint(
                  'Server ready: ${status['width']}x${status['height']}@${status['fps']}fps');
            } else {
              debugPrint('Server status: ${status['status']}');
            }
          }
        } catch (e) {
          debugPrint('Server not reachable: $e');
        }

        if (!serverReady) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }

      if (!serverReady) {
        throw Exception(
            'Server not ready after $maxRetries attempts. Is the backend running?');
      }

      // Step 2: Initialize video player with H.264 stream
      debugPrint('Initializing video player...');
      _controller = VideoPlayerController.network(
        '$backendUrl$streamEndpoint',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _controller!.initialize();
      await _controller!.play();

      debugPrint('Video player initialized and playing');

      // Monitor player errors
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          debugPrint('Video player error: ${_controller!.value.errorDescription}');
          emit(CarPlayState.error(
            message: 'Video playback error: ${_controller!.value.errorDescription}',
          ));
        }
      });

      emit(CarPlayState.connected(controller: _controller!));
    } catch (e, stackTrace) {
      debugPrint('CarPlay connection error: $e');
      debugPrint('Stack trace: $stackTrace');

      await _cleanup();

      String errorMessage = 'Failed to connect to CarPlay backend';
      if (e is TimeoutException) {
        errorMessage = 'Connection timeout. Is the backend running at $backendUrl?';
      } else if (e is http.ClientException) {
        errorMessage = 'Cannot reach backend at $backendUrl. Is it running?';
      } else {
        errorMessage = 'Connection error: $e';
      }

      emit(CarPlayState.error(message: errorMessage));
    }
  }

  /// Send a touch event to the CarPlay backend via HTTP POST
  ///
  /// Actions:
  /// - 14 = Touch down
  /// - 15 = Touch move
  /// - 16 = Touch up
  Future<void> sendTouchEvent(double x, double y, int action) async {
    try {
      await _httpClient.post(
        Uri.parse('$backendUrl$touchEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'x': x,
          'y': y,
          'action': action,
        }),
      );
    } catch (e) {
      debugPrint('Touch error: $e');
      // Don't throw - touch errors shouldn't break the connection
    }
  }

  /// Disconnect from the CarPlay backend
  Future<void> disconnect() async {
    await _cleanup();
    emit(const CarPlayState.disconnected());
  }

  /// Retry connection after an error
  Future<void> retry() async {
    await _cleanup();
    await connect();
  }

  Future<void> _cleanup() async {
    try {
      await _controller?.pause();
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  @override
  Future<void> close() async {
    await _cleanup();
    _httpClient.close();
    return super.close();
  }
}
