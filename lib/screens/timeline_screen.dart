import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/timer_tile.dart';
import '../widgets/add_timer_dialog.dart';
import '../providers/timer_provider.dart';
import '../models/timer_model.dart'; // Add this at the top

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(timerProvider);
    return Scaffold(
      body: timers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No timers yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a new timer to get started',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final timer = timers[index];
                timer.updateStatus();
                return TimerTile(
                  timer: timer,
                  onEdit: () => _showEditTimerDialog(context, timer, ref),
                  onDelete: () => ref.read(timerProvider.notifier).deleteTimer(timer.id),
                  onLock: () => ref.read(timerProvider.notifier).toggleLock(timer.id),
                );
              },
            ),
    );
  }

  void _showEditTimerDialog(BuildContext context, TimerModel timer, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTimerDialog(editingTimer: timer),
    );
  }
}