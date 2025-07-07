import 'package:uuid/uuid.dart';

class ProjectModel {
  final String id;
  String title;
  String? description;
  String? projectLink;
  String? goal;
  bool isCompleted;

  ProjectModel({
    String? id,
    required this.title,
    this.description,
    this.projectLink,
    this.goal,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectLink': projectLink,
      'goal': goal,
      'isCompleted': isCompleted,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      projectLink: json['projectLink'],
      goal: json['goal'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? projectLink,
    String? goal,
    bool? isCompleted,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectLink: projectLink ?? this.projectLink,
      goal: goal ?? this.goal,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}