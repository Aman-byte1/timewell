import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import for ConsumerWidget/ref
import 'package:timewell/models/habit_model.dart'; // Ensure this path is correct
import 'package:timewell/providers/habit_provider.dart'; // Import habit provider
import 'package:intl/intl.dart'; // For date formatting for notes key

class HabitItem extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  final Habit habit;
  final DateTime date;
  final VoidCallback onComplete;
  final VoidCallback onMissed;

  const HabitItem({
    super.key,
    required this.habit,
    required this.date,
    required this.onComplete,
    required this.onMissed,
  });

  @override
  _HabitItemState createState() => _HabitItemState();
}

class _HabitItemState extends ConsumerState<HabitItem> {
  late TextEditingController _noteController;
  bool _showNoteField = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing note if any
    _noteController = TextEditingController(
      text: ref.read(habitProvider.notifier).getDailyNote(widget.habit.id, widget.date),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Helper to determine progress bar color
  Color _getProgressBarColor(double completionRate, ColorScheme colorScheme) {
    if (completionRate < 50) {
      return Colors.red;
    } else if (completionRate >= 50 && completionRate <= 80) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Check if habit is completed or missed for the current date
    final isCompleted = widget.habit.completionDates.any((d) =>
        d.year == widget.date.year && d.month == widget.date.month && d.day == widget.date.day);
    final isMissed = widget.habit.missedDates.any((d) =>
        d.year == widget.date.year && d.month == widget.date.month && d.day == widget.date.day);

    // Check if the habit is snoozed past the current time
    final isSnoozed = widget.habit.snoozeUntil != null && widget.habit.snoozeUntil!.isAfter(DateTime.now());

    // Calculate streak and monthly completion rate
    final int currentStreak = ref.watch(habitProvider.notifier).calculateCurrentStreak(widget.habit, widget.date);
    final double monthlyCompletionRate = ref.watch(habitProvider.notifier).calculateMonthlyCompletionRate(widget.habit, widget.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              // Use custom icon if available, otherwise default
              leading: Icon(
                widget.habit.iconCodePoint != null
                    ? IconData(widget.habit.iconCodePoint!, fontFamily: 'MaterialIcons')
                    : (isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
                color: isCompleted
                    ? Colors.green
                    : isMissed
                        ? Colors.orange
                        : colorScheme.onSurfaceVariant,
                size: 30,
              ),
              title: Text(
                widget.habit.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      color: isCompleted ? colorScheme.onSurface.withOpacity(0.6) : colorScheme.onSurface,
                    ),
              ),
              subtitle: Text(
                isCompleted
                    ? "Completed"
                    : isMissed
                        ? "Missed"
                        : isSnoozed
                            ? "Snoozed until ${DateFormat.jm().format(widget.habit.snoozeUntil!)}"
                            : "Pending",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCompleted
                          ? Colors.green
                          : isMissed
                              ? Colors.orange
                              : isSnoozed
                                  ? colorScheme.tertiary
                                  : Colors.grey,
                    ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress for Monthly Completion Rate
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: monthlyCompletionRate / 100,
                          strokeWidth: 4,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressBarColor(monthlyCompletionRate, colorScheme),
                          ),
                        ),
                        Text(
                          '${monthlyCompletionRate.round()}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Progress for Current Streak
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: currentStreak > 0 ? 1.0 : 0.0, // Simple indicator for streak presence
                          strokeWidth: 4,
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            currentStreak > 0 ? Colors.blueAccent : Colors.grey,
                          ),
                        ),
                        Text(
                          '$currentStreak',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.habit.description != null && widget.habit.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  widget.habit.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            Divider(color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Action buttons
                  if (!isCompleted && !isMissed && !isSnoozed) ...[
                    ElevatedButton.icon(
                      onPressed: widget.onComplete,
                      icon: const Icon(Icons.check),
                      label: const Text("Complete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: Colors.green.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onMissed,
                      icon: const Icon(Icons.close),
                      label: const Text("Miss"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.orange.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(habitProvider.notifier).snoozeHabit(widget.habit.id);
                      },
                      icon: const Icon(Icons.snooze),
                      label: const Text("Snooze"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.tertiaryContainer,
                        foregroundColor: colorScheme.onTertiaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] else if (isMissed) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(habitProvider.notifier).rescheduleMissedHabit(widget.habit.id, widget.date);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Habit rescheduled to next available day!")),
                        );
                      },
                      icon: const Icon(Icons.redo),
                      label: const Text("Reschedule"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Daily Notes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Daily Notes:",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      IconButton(
                        icon: Icon(_showNoteField ? Icons.keyboard_arrow_up : Icons.edit_note),
                        onPressed: () {
                          setState(() {
                            _showNoteField = !_showNoteField;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_showNoteField)
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Add a note for this day...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (text) {
                        ref.read(habitProvider.notifier).addDailyNote(widget.habit.id, widget.date, text);
                      },
                    ),
                  if (!_showNoteField && _noteController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _noteController.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
