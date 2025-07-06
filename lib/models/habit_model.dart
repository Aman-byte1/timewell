import 'package:flutter/material.dart'; // For IconData, Color

class Habit {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final List<int> repeatDays; // Weekday integers (1-7)
  final List<DateTime> completionDates;
  final List<DateTime> missedDates;
  final Color? themeColor; // Optional color for the habit
  final DateTime? snoozeUntil; // Date until which the habit is snoozed
  final Map<String, String> dailyNotes; // Notes for specific dates (formatted as 'YYYY-MM-DD')
  final Map<String, List<String>> dailyNoteImageUrls; // NEW: Image URLs for daily notes
  final int? iconCodePoint; // For custom icons

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.repeatDays,
    this.completionDates = const [],
    this.missedDates = const [],
    this.themeColor,
    this.snoozeUntil,
    this.dailyNotes = const {},
    this.dailyNoteImageUrls = const {}, // Initialize new field
    this.iconCodePoint,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? repeatDays,
    List<DateTime>? completionDates,
    List<DateTime>? missedDates,
    Color? themeColor,
    DateTime? snoozeUntil,
    Map<String, String>? dailyNotes,
    Map<String, List<String>>? dailyNoteImageUrls, // Update copyWith
    int? iconCodePoint,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatDays: repeatDays ?? this.repeatDays,
      completionDates: completionDates ?? this.completionDates,
      missedDates: missedDates ?? this.missedDates,
      themeColor: themeColor ?? this.themeColor,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      dailyNotes: dailyNotes ?? this.dailyNotes,
      dailyNoteImageUrls: dailyNoteImageUrls ?? this.dailyNoteImageUrls, // Copy new field
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  // Convert Habit object to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'repeatDays': repeatDays,
      'completionDates': completionDates.map((d) => d.toIso8601String()).toList(),
      'missedDates': missedDates.map((d) => d.toIso8601String()).toList(),
      'themeColor': themeColor?.value, // Store color as int
      'snoozeUntil': snoozeUntil?.toIso8601String(),
      'dailyNotes': dailyNotes,
      'dailyNoteImageUrls': dailyNoteImageUrls, // Store new field
      'iconCodePoint': iconCodePoint,
    };
  }

  // Create Habit object from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      repeatDays: List<int>.from(json['repeatDays']),
      completionDates: (json['completionDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
      missedDates: (json['missedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
      themeColor: json['themeColor'] != null ? Color(json['themeColor']) : null,
      snoozeUntil: json['snoozeUntil'] != null ? DateTime.parse(json['snoozeUntil']) : null,
      dailyNotes: Map<String, String>.from(json['dailyNotes'] ?? {}),
      // Parse dailyNoteImageUrls: ensure it's a Map<String, List<String>>
      dailyNoteImageUrls: (json['dailyNoteImageUrls'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, List<String>.from(value))) ??
          {},
      iconCodePoint: json['iconCodePoint'],
    );
  }
}
