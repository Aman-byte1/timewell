import 'package:flutter/material.dart';
import '../models/timer_model.dart';

class TimerTile extends StatelessWidget {
  final TimerModel timer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLock;

  const TimerTile({
    super.key,
    required this.timer,
    required this.onEdit,
    required this.onDelete,
    required this.onLock,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = timer.themeColor ?? Theme.of(context).colorScheme.primary;
    final statusColor = timer.status == TimerStatus.completed
        ? Colors.green
        : timer.status == TimerStatus.locked
            ? Colors.orange
            : themeColor;
    
    final progress = timer.progress.clamp(0.0, 1.0);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      timer.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      timer.isLocked ? Icons.lock : Icons.lock_open,
                      color: timer.isLocked ? Colors.orange : Colors.grey,
                    ),
                    onPressed: onLock,
                  ),
                ],
              ),
              if (timer.notes != null && timer.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    timer.notes!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timer.timeRemaining,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (timer.motivationalMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '"${timer.motivationalMessage!}"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: themeColor.withOpacity(0.8),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!timer.isLocked)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: onEdit,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: onDelete,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    color: Colors.green,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}