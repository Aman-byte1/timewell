import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/challenge_model.dart'; // Import ChallengeModel
import '../models/project_model.dart'; // Import ProjectModel

final challengeProvider = StateNotifierProvider<ChallengeNotifier, List<ChallengeModel>>((ref) {
  return ChallengeNotifier();
});

class ChallengeNotifier extends StateNotifier<List<ChallengeModel>> {
  ChallengeNotifier() : super([]) {
    _loadChallenges();
  }

  static const _key = 'challenges';

  Future<void> _loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> json = jsonDecode(data);
        state = json.map((e) => ChallengeModel.fromJson(e)).toList();
      } catch (e) {
        // Handle parsing errors gracefully
        print("Error loading challenges: $e");
        state = [];
      }
    }
  }

  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  void addChallenge(ChallengeModel challenge) {
    state = [...state, challenge];
    _saveChallenges();
  }

  void updateChallenge(String challengeId, ChallengeModel updatedChallenge) {
    state = state.map((challenge) =>
        challenge.id == challengeId ? updatedChallenge : challenge).toList();
    _saveChallenges();
  }

  void deleteChallenge(String challengeId) {
    state = state.where((challenge) => challenge.id != challengeId).toList();
    _saveChallenges();
  }

  void addProjectToDay(String challengeId, int dayNumber, ProjectModel project) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        final updatedProjectsByDay = Map<String, List<ProjectModel>>.from(challenge.projectsByDay);
        final dayKey = 'day_$dayNumber';
        updatedProjectsByDay.putIfAbsent(dayKey, () => []).add(project);
        return challenge.copyWith(projectsByDay: updatedProjectsByDay);
      }
      return challenge;
    }).toList();
    _saveChallenges();
  }

  void updateProject(String challengeId, int dayNumber, ProjectModel updatedProject) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        final updatedProjectsByDay = Map<String, List<ProjectModel>>.from(challenge.projectsByDay);
        final dayKey = 'day_$dayNumber';
        if (updatedProjectsByDay.containsKey(dayKey)) {
          final List<ProjectModel> projects = updatedProjectsByDay[dayKey]!;
          final updatedProjects = projects.map((p) =>
              p.id == updatedProject.id ? updatedProject : p).toList();
          updatedProjectsByDay[dayKey] = updatedProjects;
        }
        return challenge.copyWith(projectsByDay: updatedProjectsByDay);
      }
      return challenge;
    }).toList();
    _saveChallenges();
  }

  void toggleProjectCompletion(String challengeId, int dayNumber, String projectId) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        final updatedProjectsByDay = Map<String, List<ProjectModel>>.from(challenge.projectsByDay);
        final dayKey = 'day_$dayNumber';
        if (updatedProjectsByDay.containsKey(dayKey)) {
          final List<ProjectModel> projects = updatedProjectsByDay[dayKey]!;
          final updatedProjects = projects.map((p) {
            if (p.id == projectId) {
              return p.copyWith(isCompleted: !p.isCompleted);
            }
            return p;
          }).toList();
          updatedProjectsByDay[dayKey] = updatedProjects;
        }
        return challenge.copyWith(projectsByDay: updatedProjectsByDay);
      }
      return challenge;
    }).toList();
    _saveChallenges();
  }

  void deleteProject(String challengeId, int dayNumber, String projectId) {
    state = state.map((challenge) {
      if (challenge.id == challengeId) {
        final updatedProjectsByDay = Map<String, List<ProjectModel>>.from(challenge.projectsByDay);
        final dayKey = 'day_$dayNumber';
        if (updatedProjectsByDay.containsKey(dayKey)) {
          updatedProjectsByDay[dayKey] = updatedProjectsByDay[dayKey]!
              .where((p) => p.id != projectId)
              .toList();
        }
        return challenge.copyWith(projectsByDay: updatedProjectsByDay);
      }
      return challenge;
    }).toList();
    _saveChallenges();
  }
}