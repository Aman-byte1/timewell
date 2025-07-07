import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/challenge_model.dart';
import '../models/project_model.dart';
import '../providers/challenge_provider.dart';
import 'project_expansion_tile.dart'; // Ensure this import is present

class ChallengeDetailScreen extends ConsumerWidget {
  final ChallengeModel challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the challenge provider to get the latest state of this specific challenge
    final currentChallenge = ref.watch(challengeProvider.select((challenges) =>
        challenges.firstWhere((c) => c.id == challenge.id, orElse: () => challenge)));

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentChallenge.title),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: currentChallenge.durationInDays,
        itemBuilder: (context, index) {
          final dayNumber = index + 1;
          final dayKey = 'day_$dayNumber';
          final projectsForDay = currentChallenge.projectsByDay[dayKey] ?? [];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentChallenge.getDayString(dayNumber),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: colorScheme.secondary),
                        onPressed: () {
                          _showAddProjectDialog(context, ref, currentChallenge.id, dayNumber);
                        },
                        tooltip: 'Add Project to Day ${dayNumber}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (projectsForDay.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No projects for this day yet. Click the + button to add one!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  else
                    ...projectsForDay.map((project) {
                      return ProjectExpansionTile(
                        challengeId: currentChallenge.id,
                        dayNumber: dayNumber,
                        projectId: project.id, // Pass projectId instead of the full object
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref, String challengeId, int dayNumber) {
    final _formKey = GlobalKey<FormState>();
    String _title = '';
    String? _description;
    String? _projectLink;
    String? _goal;

    showDialog(
      context: context,
      builder: (ctx) {
        final ColorScheme colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text('Add Project to ${challenge.getDayString(dayNumber)}'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Project Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project title';
                      }
                      return null;
                    },
                    onSaved: (value) => _title = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _description = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Project Link (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.url,
                    onSaved: (value) => _projectLink = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Goal (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                    onSaved: (value) => _goal = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newProject = ProjectModel(
                    title: _title,
                    description: _description,
                    projectLink: _projectLink,
                    goal: _goal,
                  );
                  ref.read(challengeProvider.notifier).addProjectToDay(challengeId, dayNumber, newProject);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Add Project'),
            ),
          ],
        );
      },
    );
  }
}
