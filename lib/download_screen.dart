import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scooter_cluster/map/download/download_task.dart';
import 'package:scooter_cluster/repositories/tiles_update_repository.dart';
import 'package:scooter_cluster/services/task_service.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late TaskService _taskService;
  final TilesUpdateRepository _tilesUpdateRepository = TilesUpdateRepository();
  late Future<List<DownloadableRelease>> _releasesFuture;

  @override
  void initState() {
    super.initState();
    _taskService = context.read<TaskService>();
    _releasesFuture = _tilesUpdateRepository.getReleases();
  }

  void _addDownloadTask(String url) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final uri = Uri.parse(url);
      final fileName = uri.pathSegments.last;
      final destinationPath = '${documentsDir.path}/maps/$fileName';

      final dir = Directory('${documentsDir.path}/maps');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final task = MapDownloadTask(
        url: url,
        destination: destinationPath,
      );
      _taskService.addTask(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error preparing download: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<DownloadableRelease>>(
              future: _releasesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final releases = snapshot.data!;
                  if (releases.isEmpty) {
                    return const Center(child: Text('No releases found.'));
                  }
                  return ListView.builder(
                    itemCount: releases.length,
                    itemBuilder: (context, index) {
                      final release = releases[index];
                      return ListTile(
                        title: Text(release.name),
                        onTap: () {
                          for (final tile in release.tiles) {
                            _addDownloadTask(tile.url);
                          }
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No releases found.'));
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<(Task, TaskStatus)>>(
              stream: _taskService.stream, // Use the stream from TaskService
              initialData: _taskService.tasks, // Get initial state correctly
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No active tasks.'));
                }

                final taskStatuses = snapshot.data!; // This is List<TaskStatus>
                return ListView.builder(
                  itemCount: taskStatuses.length,
                  itemBuilder: (context, index) {
                    final (task, taskStatus) =
                        taskStatuses[index]; // Current TaskStatus
                    String title = 'Unknown Task';
                    String subtitle = '';
                    double? progressValue;
                    Duration? eta; // Add eta variable

                    switch (taskStatus) {
// Switch on taskStatus directly
                      case TaskPending(): // Use the public type from freezed
                        title = 'Task Pending';
                        subtitle = 'Waiting to start...';
                      case TaskRunning(
                          step: final step,
                          progress: final p,
                          eta: final taskEta
                        ): // Extract eta
                        title = task
                            .name; // This will be "Map Download" from user's task
                        subtitle = step ?? 'Running...';
                        progressValue = p;
                        eta = taskEta; // Assign to local variable
                      case TaskCompleted(
                          result: _
                        ): // Result is void for user's task
                        title = '${task.name}: Completed';
                        subtitle = 'Download finished.';
                        break;
                      case TaskError(message: final message):
                        title = 'Error: ${task.name}';
                        subtitle = message;
                    }

                    eta = null;

                    return Card(
                      key: Key(task.name + task.id),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: Theme.of(context).textTheme.titleMedium),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(subtitle,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                            if (progressValue != null) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (eta != null)
                                    Text('ETA: ${_formatDuration(eta)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)
                                  else
                                    Container(), // Keep space if ETA is not yet available
                                  Text(
                                      '${(progressValue * 100).toStringAsFixed(0)}%'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
// Helper function to format duration
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 0) {
    return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  } else if (duration.inMinutes > 0) {
    return "${twoDigitMinutes}m ${twoDigitSeconds}s";
  } else {
    return "${twoDigitSeconds}s";
  }
}
