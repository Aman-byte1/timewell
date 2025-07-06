import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timewell/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    loadTasks();
  }

  static const _key = 'tasks';

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> json = jsonDecode(data);
        state = json.map((e) => Task.fromJson(e)).toList();
      } catch (e) {
        state = [];
      }
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  void addTask(Task task) {
    state = [...state, task];
    _saveTasks();
  }

  void updateTask(String id, Task updatedTask) {
    state = state.map((task) => task.id == id ? updatedTask : task).toList();
    _saveTasks();
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
    _saveTasks();
  }

  void startTask(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return Task(
          id: task.id,
          title: task.title,
          description: task.description,
          type: task.type,
          date: task.date,
          startTime: task.startTime,
          duration: task.duration,
          recurrenceDays: task.recurrenceDays,
          themeColor: task.themeColor,
          status: TaskStatus.inProgress,
        );
      }
      return task;
    }).toList();
    _saveTasks();
  }

  void completeTask(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return Task(
          id: task.id,
          title: task.title,
          description: task.description,
          type: task.type,
          date: task.date,
          startTime: task.startTime,
          duration: task.duration,
          recurrenceDays: task.recurrenceDays,
          themeColor: task.themeColor,
          status: TaskStatus.completed,
        );
      }
      return task;
    }).toList();
    _saveTasks();
  }
}