import 'package:uuid/uuid.dart';
import 'project_model.dart'; // Import ProjectModel

class ChallengeModel {
  final String id;
  String title;
  DateTime startDate;
  int durationInDays; // Total number of days for the challenge
  Map<String, List<ProjectModel>> projectsByDay; // Key: 'day_1', 'day_2', etc.

  ChallengeModel({
    String? id,
    required this.title,
    required this.startDate,
    required this.durationInDays,
    Map<String, List<ProjectModel>>? projectsByDay,
  })  : id = id ?? const Uuid().v4(),
        projectsByDay = projectsByDay ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'durationInDays': durationInDays,
      'projectsByDay': projectsByDay.map((key, value) =>
          MapEntry(key, value.map((p) => p.toJson()).toList())),
    };
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<ProjectModel>> parsedProjectsByDay = {};
    if (json['projectsByDay'] != null) {
      (json['projectsByDay'] as Map<String, dynamic>).forEach((key, value) {
        parsedProjectsByDay[key] = (value as List<dynamic>)
            .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }

    return ChallengeModel(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      durationInDays: json['durationInDays'],
      projectsByDay: parsedProjectsByDay,
    );
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    int? durationInDays,
    Map<String, List<ProjectModel>>? projectsByDay,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      durationInDays: durationInDays ?? this.durationInDays,
      projectsByDay: projectsByDay ?? Map.from(this.projectsByDay),
    );
  }

  // Helper to get day string, e.g., 'Day 1'
  String getDayString(int dayNumber) {
    if (dayNumber == 1) return 'Day One';
    if (dayNumber == 2) return 'Day Two';
    if (dayNumber == 3) return 'Day Three';
    // Add more as needed, or use a general format
    return 'Day $dayNumber';
  }

  // Calculate overall challenge progress
  double get overallProgress {
    int totalProjects = 0;
    int completedProjects = 0;

    projectsByDay.forEach((dayKey, projects) {
      totalProjects += projects.length;
      completedProjects += projects.where((p) => p.isCompleted).length;
    });

    return totalProjects > 0 ? completedProjects / totalProjects : 0.0;
  }
}