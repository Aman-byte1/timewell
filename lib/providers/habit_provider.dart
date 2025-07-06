import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timewell/models/habit_model.dart'; // Ensure this path is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting for notes key

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]) {
    loadHabits();
  }

  static const _key = 'habits';

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> json = jsonDecode(data);
        state = json.map((e) => Habit.fromJson(e)).toList();
      } catch (e) {
        // Handle decoding errors, e.g., if the stored data format changes
        print("Error loading habits: $e");
        state = [];
      }
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  void addHabit(Habit habit) {
    state = [...state, habit];
    _saveHabits();
  }

  void updateHabit(String id, Habit updatedHabit) {
    state = state.map((habit) => habit.id == id ? updatedHabit : habit).toList();
    _saveHabits();
  }

  void deleteHabit(String id) {
    state = state.where((habit) => habit.id != id).toList();
    _saveHabits();
  }

  void markHabitCompleted(String id, DateTime date) {
    state = state.map((habit) {
      if (habit.id == id) {
        // Ensure the date is normalized to avoid time-based comparison issues
        final normalizedDate = DateTime(date.year, date.month, date.day);
        // Add only if not already completed for this date
        if (!habit.completionDates.any((d) => d.year == normalizedDate.year && d.month == normalizedDate.month && d.day == normalizedDate.day)) {
          return habit.copyWith(
            completionDates: [...habit.completionDates, normalizedDate],
            missedDates: habit.missedDates.where((d) => d.year != normalizedDate.year || d.month != normalizedDate.month || d.day != normalizedDate.day).toList(), // Remove from missed if completed
          );
        }
      }
      return habit;
    }).toList();
    _saveHabits();
  }

  void markHabitMissed(String id, DateTime date) {
    state = state.map((habit) {
      if (habit.id == id) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        // Add only if not already missed for this date
        if (!habit.missedDates.any((d) => d.year == normalizedDate.year && d.month == normalizedDate.month && d.day == normalizedDate.day)) {
          return habit.copyWith(
            missedDates: [...habit.missedDates, normalizedDate],
            completionDates: habit.completionDates.where((d) => d.year != normalizedDate.year || d.month != normalizedDate.month || d.day != normalizedDate.day).toList(), // Remove from completed if missed
          );
        }
      }
      return habit;
    }).toList();
    _saveHabits();
  }

  // New: Snooze a habit for a specified duration (e.g., 1 hour from now)
  void snoozeHabit(String id, {Duration duration = const Duration(hours: 1)}) {
    state = state.map((habit) {
      if (habit.id == id) {
        return habit.copyWith(snoozeUntil: DateTime.now().add(duration));
      }
      return habit;
    }).toList();
    _saveHabits();
  }

  // New: Add or update a daily note for a habit on a specific date
  void addDailyNote(String habitId, DateTime date, String note) {
    state = state.map((habit) {
      if (habit.id == habitId) {
        final String dateKey = DateFormat('yyyy-MM-dd').format(date);
        final Map<String, String> updatedNotes = Map.from(habit.dailyNotes);
        updatedNotes[dateKey] = note;
        return habit.copyWith(dailyNotes: updatedNotes);
      }
      return habit;
    }).toList();
    _saveHabits();
  }

  // New: Get a daily note for a habit on a specific date
  String? getDailyNote(String habitId, DateTime date) {
    final habit = state.firstWhere((h) => h.id == habitId);
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    return habit.dailyNotes[dateKey];
  }

  // New: Calculate the current streak for a habit
  int calculateCurrentStreak(Habit habit, DateTime today) {
    int streak = 0;
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    // If the habit is not supposed to be done today, the streak doesn't break.
    // We look at the most recent past days.
    while (true) {
      // Check if the habit is scheduled for currentDate
      if (habit.repeatDays.contains(currentDate.weekday)) {
        final bool completedToday = habit.completionDates.any((d) =>
            d.year == currentDate.year &&
            d.month == currentDate.month &&
            d.day == currentDate.day);

        if (completedToday) {
          streak++;
        } else {
          // If it was scheduled but not completed, streak breaks.
          break;
        }
      }
      // Move to the previous day
      currentDate = currentDate.subtract(const Duration(days: 1));
      // Stop if we go before the habit's start date
      if (currentDate.isBefore(habit.startDate.subtract(const Duration(days: 1)))) {
        break;
      }
    }
    return streak;
  }

  // New: Calculate monthly completion rate for a habit
  double calculateMonthlyCompletionRate(Habit habit, DateTime month) {
    final DateTime startOfMonth = DateTime(month.year, month.month, 1);
    final DateTime endOfMonth = DateTime(month.year, month.month + 1, 0); // Last day of the month

    int scheduledDays = 0;
    int completedDays = 0;

    for (DateTime d = startOfMonth; d.isBefore(endOfMonth.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      if (habit.repeatDays.contains(d.weekday) && !d.isAfter(DateTime.now())) { // Only count up to today
        scheduledDays++;
        if (habit.completionDates.any((cd) => cd.year == d.year && cd.month == d.month && cd.day == d.day)) {
          completedDays++;
        }
      }
    }

    return scheduledDays == 0 ? 0.0 : (completedDays / scheduledDays) * 100.0;
  }

  // New: Reschedule a missed habit (basic implementation: move to next scheduled day)
  void rescheduleMissedHabit(String id, DateTime missedDate) {
    state = state.map((habit) {
      if (habit.id == id) {
        final normalizedMissedDate = DateTime(missedDate.year, missedDate.month, missedDate.day);

        // Remove the missed date from the missedDates list
        final updatedMissedDates = habit.missedDates.where((d) =>
            d.year != normalizedMissedDate.year ||
            d.month != normalizedMissedDate.month ||
            d.day != normalizedMissedDate.day
        ).toList();

        // Find the next scheduled day for this habit
        DateTime nextScheduledDay = normalizedMissedDate.add(const Duration(days: 1));
        while (!habit.repeatDays.contains(nextScheduledDay.weekday)) {
          nextScheduledDay = nextScheduledDay.add(const Duration(days: 1));
        }

        // For simplicity, we'll just remove the missed status.
        // A more advanced "auto-schedule" might add a new "pending" entry for nextScheduledDay
        // or create a duplicate task/habit for that day.
        // For now, removing from missedDates implies it's no longer considered missed for that day.
        return habit.copyWith(missedDates: updatedMissedDates);
      }
      return habit;
    }).toList();
    _saveHabits();
  }
}
