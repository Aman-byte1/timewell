import 'dart:ui';

enum TimerStatus { active, completed, locked }
enum RepeatType { none, daily, weekly, monthly }

class TimerModel {
  final String id;
  final String title;
  final String? notes;
  final DateTime targetDate;
  final DateTime startDate;
  final RepeatType repeatType;
  final bool isLocked;
  TimerStatus status;
  final Color? themeColor;
  String? motivationalMessage;

  TimerModel({
    required this.id,
    required this.title,
    this.notes,
    required this.targetDate,
    required this.startDate,
    this.repeatType = RepeatType.none,
    this.isLocked = false,
    this.status = TimerStatus.active,
    this.themeColor,
    this.motivationalMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'targetDate': targetDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'repeatType': repeatType.index,
      'isLocked': isLocked,
      'status': status.index,
      'themeColor': themeColor?.value,
      'motivationalMessage': motivationalMessage,
    };
  }

  factory TimerModel.fromJson(Map<String, dynamic> json) {
    return TimerModel(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      targetDate: DateTime.parse(json['targetDate']),
      startDate: DateTime.parse(json['startDate']),
      repeatType: RepeatType.values[json['repeatType']],
      isLocked: json['isLocked'],
      status: TimerStatus.values[json['status']],
      themeColor: json['themeColor'] != null ? Color(json['themeColor']) : null,
      motivationalMessage: json['motivationalMessage'],
    );
  }

  String get timeRemaining {
    final now = DateTime.now();
    if (status == TimerStatus.completed) return "Completed";
    
    final difference = targetDate.difference(now);
    if (difference.isNegative) return "Overdue";
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    return "${days}d ${hours}h ${minutes}m ${seconds}s";
  }

  double get progress {
    if (status == TimerStatus.completed) return 1.0;
    
    final totalDuration = targetDate.difference(startDate).inSeconds;
    final elapsedDuration = DateTime.now().difference(startDate).inSeconds;
    
    if (elapsedDuration <= 0) return 0.0;
    if (elapsedDuration >= totalDuration) {
      status = TimerStatus.completed;
      return 1.0;
    }
    
    return elapsedDuration / totalDuration;
  }

  void updateStatus() {
    if (status == TimerStatus.locked) return;
    
    if (DateTime.now().isAfter(targetDate)) {
      status = TimerStatus.completed;
    } else {
      status = TimerStatus.active;
    }
  }
}
