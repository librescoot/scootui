import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dio/dio.dart';

part 'carplay_state.dart';
part 'carplay_cubit.freezed.dart';

class CarPlayCubit extends Cubit<CarPlayState> {
  static const String backendUrl = 'http://localhost:8001';
  static const String connectEndpoint = '/connect';
  static const String statusEndpoint = '/status';

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _touchChannel;
  RTCVideoRenderer? _renderer;
  final Dio _dio = Dio();

  CarPlayCubit() : super(const CarPlayState.disconnected());

  /// Connect to the CarPlay backend
  Future<void> connect() async {
    try {
      emit(const CarPlayState.connecting());

      // Step 1: Check backend status (optional but good for debugging)
      try {
        final statusResponse = await _dio.get('$backendUrl$statusEndpoint');
        if (statusResponse.statusCode == 200) {
          final status = statusResponse.data;
          debugPrint('CarPlay backend status: ${status['status']}');
          debugPrint('Resolution: ${status['width']}x${status['height']}@${status['fps']}fps');
        }
      } catch (e) {
        debugPrint('Could not check backend status: $e');
        // Continue anyway - status check is optional
      }

      // Step 2: Create peer connection (no ICE servers for localhost)
      final configuration = <String, dynamic>{};
      _peerConnection = await createPeerConnection(configuration);

      // Step 3: Initialize video renderer
      _renderer = RTCVideoRenderer();
      await _renderer!.initialize();

      // Step 4: Set up video track reception
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        debugPrint('Received track: ${event.track.kind}');
        if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          _renderer!.srcObject = event.streams[0];
          debugPrint('Video track connected to renderer');
        }
      };

      // Step 5: Create touch data channel
      _touchChannel = await _peerConnection!.createDataChannel(
        'touch',
        RTCDataChannelInit(),
      );

      _touchChannel!.onDataChannelState = (state) {
        debugPrint('Touch channel state: $state');
      };

      // Step 6: Handle audio channel (we'll ignore it for now)
      _peerConnection!.onDataChannel = (RTCDataChannel channel) {
        debugPrint('Received data channel: ${channel.label}');
        if (channel.label == 'audio') {
          // Skip audio for now as per user request
          debugPrint('Ignoring audio channel (not implemented yet)');
        }
      };

      // Step 7: Add video transceiver
      await _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      // Step 8: Create and send offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      debugPrint('Waiting for ICE gathering to complete...');

      // Wait for ICE gathering to complete (should be fast on localhost)
      await _waitForIceGatheringComplete();

      debugPrint('Sending offer to backend...');

      // Get local description
      final localDesc = await _peerConnection!.getLocalDescription();
      if (localDesc == null) {
        throw Exception('Failed to get local description');
      }

      // Send offer to backend
      final response = await _dio.post(
        '$backendUrl$connectEndpoint',
        data: localDesc.toMap(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend returned status ${response.statusCode}');
      }

      debugPrint('Received answer from backend');

      // Set remote answer
      final answer = response.data;
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );

      debugPrint('CarPlay connection established');

      // Monitor connection state
      _peerConnection!.onConnectionState = (state) {
        debugPrint('Connection state: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          emit(const CarPlayState.error(
            message: 'Connection lost. Please check the CarPlay backend.',
          ));
        }
      };

      emit(CarPlayState.connected(renderer: _renderer!));
    } catch (e, stackTrace) {
      debugPrint('CarPlay connection error: $e');
      debugPrint('Stack trace: $stackTrace');

      await _cleanup();

      String errorMessage = 'Failed to connect to CarPlay backend';
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Connection timeout. Is the backend running?';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Cannot reach backend at $backendUrl. Is it running?';
        } else {
          errorMessage = 'Network error: ${e.message}';
        }
      } else {
        errorMessage = 'Connection error: $e';
      }

      emit(CarPlayState.error(message: errorMessage));
    }
  }

  /// Wait for ICE gathering to complete
  Future<void> _waitForIceGatheringComplete() async {
    final completer = Completer<void>();

    // Set up a listener for ICE gathering state changes
    _peerConnection!.onIceGatheringState = (state) {
      debugPrint('ICE gathering state: $state');
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    };

    // Also check current state in case it's already complete
    final currentState = await _peerConnection!.getIceGatheringState();
    if (currentState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    // Add a timeout to prevent hanging
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('ICE gathering timeout - continuing anyway');
      },
    );
  }

  /// Send a touch event to the CarPlay backend
  ///
  /// Actions:
  /// - 14 = Touch down
  /// - 15 = Touch move
  /// - 16 = Touch up
  void sendTouchEvent(double x, double y, int action) {
    if (_touchChannel == null) {
      debugPrint('Touch channel not available');
      return;
    }

    if (_touchChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
      debugPrint('Touch channel not open: ${_touchChannel!.state}');
      return;
    }

    final touchData = jsonEncode({
      'x': x,
      'y': y,
      'action': action,
    });

    try {
      _touchChannel!.send(RTCDataChannelMessage(touchData));
    } catch (e) {
      debugPrint('Error sending touch event: $e');
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
      await _touchChannel?.close();
      _touchChannel = null;

      await _peerConnection?.close();
      _peerConnection = null;

      await _renderer?.dispose();
      _renderer = null;
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}
