import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/timer_model.dart';
final timerProvider = StateNotifierProvider<TimerNotifier, List<TimerModel>>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<List<TimerModel>> {
  TimerNotifier() : super([]) {
    loadTimers();
  }

  static const _key = 'timers';

  Future<void> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> json = jsonDecode(data);
        state = json.map((e) => TimerModel.fromJson(e)).toList();
      } catch (e) {
        state = [];
      }
    }
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  void addTimer(TimerModel timer) {
    state = [...state, timer];
    _saveTimers();
  }

  void updateTimer(String id, TimerModel updatedTimer) {
    state = state.map((timer) => timer.id == id ? updatedTimer : timer).toList();
    _saveTimers();
  }

  void deleteTimer(String id) {
    state = state.where((timer) => timer.id != id).toList();
    _saveTimers();
  }

void toggleLock(String id) {
  state = state.map((timer) {
    if (timer.id == id) {
      // Create a new instance with updated lock status
      return TimerModel(
        id: timer.id,
        title: timer.title,
        notes: timer.notes,
        targetDate: timer.targetDate,
        startDate: timer.startDate,
        repeatType: timer.repeatType,
        isLocked: !timer.isLocked, // Toggle the lock status
        status: timer.status,
        themeColor: timer.themeColor,
        motivationalMessage: timer.motivationalMessage,
      );
    }
    return timer;
  }).toList();
  _saveTimers();
}
}