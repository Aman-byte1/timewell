import 'package:flutter/material.dart'; // For TimeOfDay and Color
import 'dart:convert'; // For JSON serialization/deserialization

// Define TaskType enum globally here
enum TaskType { todo, habit, recurring }

// Added 'missed' to TaskStatus
enum TaskStatus { pending, completed, inProgress, missed } 

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskType type;
  final DateTime date;
  final TimeOfDay? startTime;
  final Duration? duration; // New: Duration for the task
  final List<DateTime>? recurrenceDays; // New: For recurring tasks
  final Color? themeColor; // New: Theme color for the task
  final TaskStatus status; // Kept as final for immutability, updated via copyWith

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.date,
    this.startTime,
    this.duration,
    this.recurrenceDays,
    this.themeColor,
    this.status = TaskStatus.pending, // Default status
  });

  // Getter for notification time, combines date and startTime
  DateTime? get notificationTime {
    if (startTime == null) return null;
    return DateTime(date.year, date.month, date.day, startTime!.hour, startTime!.minute);
  }

  // CopyWith method for creating new instances with updated properties
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    DateTime? date,
    TimeOfDay? startTime,
    Duration? duration,
    List<DateTime>? recurrenceDays,
    Color? themeColor,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      themeColor: themeColor ?? this.themeColor,
      status: status ?? this.status,
    );
  }

  // Convert Task object to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last, // Store enum as string (e.g., "todo")
      'date': date.toIso8601String(),
      'startTime': startTime != null
          ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}' // Store as "HH:MM" string
          : null,
      'duration': duration?.inMicroseconds, // Store duration as microseconds
      'recurrenceDays': recurrenceDays?.map((e) => e.toIso8601String()).toList(), // List of ISO strings
      'themeColor': themeColor?.value, // Store color as int value
      'status': status.toString().split('.').last, // Store enum as string (e.g., "pending")
    };
  }

  // Create Task object from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedStartTime;
    if (json['startTime'] != null) {
      final parts = (json['startTime'] as String).split(':');
      parsedStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TaskType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TaskType.todo, // Default to todo if type not found
      ),
      date: DateTime.parse(json['date']),
      startTime: parsedStartTime,
      duration: json['duration'] != null
          ? Duration(microseconds: json['duration'])
          : null,
      recurrenceDays: (json['recurrenceDays'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e))
              .toList(),
      themeColor: json['themeColor'] != null ? Color(json['themeColor']) : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.pending, // Default to pending if status not found
      ),
    );
  }
}