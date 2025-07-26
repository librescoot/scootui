import 'dart:async';

import 'package:flutter/material.dart';

import 'poc_map_renderer.dart';

class PocScreen extends StatefulWidget {
  const PocScreen({super.key});

  @override
  State<PocScreen> createState() => _PocScreenState();
}

class _PocScreenState extends State<PocScreen> {
  bool _isDarkTheme = true;
  double _fps = 0.0;
  int _frameCount = 0;
  Timer? _fpsTimer;
  Duration? _lastFrameTimestamp;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to measure frame times.
    WidgetsBinding.instance.addPostFrameCallback(_onPostFrame);
    // Start a timer to update the FPS counter every second.
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _fps = _frameCount.toDouble();
        _frameCount = 0;
      });
    });
  }

  void _onPostFrame(Duration timeStamp) {
    if (_lastFrameTimestamp != null) {
      _frameCount++;
    }
    _lastFrameTimestamp = timeStamp;
    // Schedule the next frame callback.
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(_onPostFrame);
    }
  }

  @override
  void dispose() {
    _fpsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map Renderer POC'),
          actions: [
            // FPS Counter
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_fps.toStringAsFixed(1)} FPS',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          // Constraining the map renderer to a square aspect ratio.
          child: AspectRatio(
            aspectRatio: 1.0,
            child: PocMapRenderer(isDarkTheme: _isDarkTheme),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _isDarkTheme = !_isDarkTheme;
            });
          },
          label: const Text('Toggle Theme'),
          icon: const Icon(Icons.brightness_6),
        ),
      ),
    );
  }
}
