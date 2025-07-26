import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scooter_cluster/services/task_service.dart';

class TaskProgressIndicator extends StatelessWidget {
  const TaskProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<(Task, TaskStatus)>>(
      stream: context.read<TaskService>().stream,
      initialData: context.read<TaskService>().tasks,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        // Find the first running task (which should be the only one now)
        final runningTask = tasks
            .where((task) => task.$2 is TaskRunning)
            .map((task) => (task.$1, task.$2 as TaskRunning))
            .firstOrNull;

        if (runningTask == null) {
          // If no running task, check if there are pending tasks
          final hasPendingTasks = tasks.any((task) => task.$2 is TaskPending);
          if (!hasPendingTasks) {
            return const SizedBox.shrink();
          }
        }

        final progress = runningTask?.$2.progress ?? 0.0;

        return SizedBox(
          width: 40,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: runningTask != null ? progress : null,
                  strokeWidth: 3.0,
                  backgroundColor: Colors.grey.withOpacity(0.5),
                ),
                Center(
                  child: Text(
                    '${tasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
