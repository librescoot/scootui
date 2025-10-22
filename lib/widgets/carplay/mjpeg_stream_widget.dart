import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Widget that displays an MJPEG stream
class MjpegStreamWidget extends StatefulWidget {
  final String streamUrl;

  const MjpegStreamWidget({
    super.key,
    required this.streamUrl,
  });

  @override
  State<MjpegStreamWidget> createState() => _MjpegStreamWidgetState();
}

class _MjpegStreamWidgetState extends State<MjpegStreamWidget> {
  Uint8List? _currentFrame;
  StreamSubscription? _streamSubscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startStream() async {
    try {
      final request = http.Request('GET', Uri.parse(widget.streamUrl));
      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode != 200) {
        setState(() {
          _error = 'HTTP ${streamedResponse.statusCode}';
          _isLoading = false;
        });
        return;
      }

      // Parse MJPEG stream
      _streamSubscription = _parseMjpegStream(streamedResponse.stream).listen(
        (frame) {
          if (mounted) {
            setState(() {
              _currentFrame = frame;
              _isLoading = false;
              _error = null;
            });
          }
        },
        onError: (error) {
          debugPrint('MJPEG stream error: $error');
          if (mounted) {
            setState(() {
              _error = 'Stream error: $error';
              _isLoading = false;
            });
          }
        },
        onDone: () {
          debugPrint('MJPEG stream closed');
          if (mounted) {
            setState(() {
              _error = 'Stream closed';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to start MJPEG stream: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to connect: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Parse MJPEG stream into individual frames
  Stream<Uint8List> _parseMjpegStream(Stream<List<int>> byteStream) async* {
    final boundary = '--frame';
    final boundaryBytes = boundary.codeUnits;
    final buffer = <int>[];
    bool inFrame = false;
    int contentLength = 0;
    List<int>? frameData;

    await for (final chunk in byteStream) {
      buffer.addAll(chunk);

      while (buffer.isNotEmpty) {
        if (!inFrame) {
          // Look for boundary
          final boundaryIndex = _indexOf(buffer, boundaryBytes);
          if (boundaryIndex == -1) {
            // Keep last few bytes in case boundary is split across chunks
            if (buffer.length > boundaryBytes.length) {
              buffer.removeRange(0, buffer.length - boundaryBytes.length);
            }
            break;
          }

          // Remove everything before and including boundary
          buffer.removeRange(0, boundaryIndex + boundaryBytes.length);

          // Parse headers
          final headerEnd = _indexOf(buffer, [13, 10, 13, 10]); // \r\n\r\n
          if (headerEnd == -1) break;

          final headers = String.fromCharCodes(buffer.sublist(0, headerEnd));
          final contentLengthMatch =
              RegExp(r'Content-Length:\s*(\d+)', caseSensitive: false)
                  .firstMatch(headers);

          if (contentLengthMatch != null) {
            contentLength = int.parse(contentLengthMatch.group(1)!);
            buffer.removeRange(0, headerEnd + 4); // Remove headers + \r\n\r\n
            frameData = [];
            inFrame = true;
          } else {
            // No Content-Length, skip this boundary
            continue;
          }
        }

        if (inFrame && frameData != null) {
          // Read frame data
          final remainingBytes = contentLength - frameData.length;
          if (buffer.length >= remainingBytes) {
            // We have the complete frame
            frameData.addAll(buffer.sublist(0, remainingBytes));
            buffer.removeRange(0, remainingBytes);

            yield Uint8List.fromList(frameData);

            // Reset for next frame
            inFrame = false;
            contentLength = 0;
            frameData = null;
          } else {
            // Need more data
            frameData.addAll(buffer);
            buffer.clear();
            break;
          }
        }
      }
    }
  }

  /// Find the index of a subsequence in a list
  int _indexOf(List<int> list, List<int> pattern) {
    for (int i = 0; i <= list.length - pattern.length; i++) {
      bool found = true;
      for (int j = 0; j < pattern.length; j++) {
        if (list[i + j] != pattern[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_currentFrame == null) {
      return const Center(
        child: Text('Waiting for video...'),
      );
    }

    return Image.memory(
      _currentFrame!,
      fit: BoxFit.contain,
      gaplessPlayback: true, // Smooth frame transitions
    );
  }
}
