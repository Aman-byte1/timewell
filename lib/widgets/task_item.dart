import 'package:flutter/material.dart';
import 'package:timewell/models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onStart,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _getStatusIcon(),
        title: Text(task.title),
        subtitle: task.description != null ? Text(task.description!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.status == TaskStatus.pending)
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.green),
                onPressed: onStart,
              ),
            if (task.status == TaskStatus.inProgress)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.blue),
                onPressed: onComplete,
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaskStatus.inProgress:
        return const Icon(Icons.access_time, color: Colors.blue);
      case TaskStatus.missed:
        return const Icon(Icons.warning, color: Colors.orange);
      default:
        return const Icon(Icons.radio_button_unchecked);
    }
  }
}