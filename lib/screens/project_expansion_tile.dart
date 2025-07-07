import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/challenge_model.dart'; // Import ChallengeModel to access getDayString
import '../models/project_model.dart';
import '../providers/challenge_provider.dart';

class ProjectExpansionTile extends ConsumerWidget {
  final String challengeId;
  final int dayNumber;
  final String projectId; // This is the parameter that was missing or mismatched

  const ProjectExpansionTile({
    super.key,
    required this.challengeId,
    required this.dayNumber,
    required this.projectId, // Ensure this is present in the constructor
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the specific project from the provider
    final ProjectModel? project = ref.watch(challengeProvider.select((challenges) {
      final challenge = challenges.firstWhere((c) => c.id == challengeId, orElse: () => ChallengeModel(id: '', title: '', startDate: DateTime.now(), durationInDays: 0));
      final dayKey = 'day_$dayNumber';
      return challenge.projectsByDay[dayKey]?.firstWhere((p) => p.id == projectId, orElse: () => ProjectModel(title: 'Error: Project Not Found'));
    }));

    if (project == null) {
      return const SizedBox.shrink(); // Or a loading indicator/error message
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: project.isCompleted ? colorScheme.tertiaryContainer.withOpacity(0.5) : colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        title: Row(
          children: [
            Checkbox(
              value: project.isCompleted,
              onChanged: (bool? newValue) {
                ref.read(challengeProvider.notifier).toggleProjectCompletion(
                      challengeId,
                      dayNumber,
                      project.id,
                    );
              },
              activeColor: colorScheme.primary,
            ),
            Expanded(
              child: Text(
                project.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: project.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      color: project.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.description != null && project.description!.isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                ],
                if (project.goal != null && project.goal!.isNotEmpty) ...[
                  Text(
                    'Goal:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.goal!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                ],
                if (project.projectLink != null && project.projectLink!.isNotEmpty) ...[
                  Text(
                    'Project Link:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse(project.projectLink!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        // Handle error: could not launch URL
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open link: ${project.projectLink}')),
                        );
                      }
                    },
                    child: Text(
                      project.projectLink!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.tertiary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Project?'),
                          content: Text('Are you sure you want to delete "${project.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(challengeProvider.notifier).deleteProject(
                                      challengeId,
                                      dayNumber,
                                      project.id,
                                    );
                                Navigator.of(ctx).pop();
                              },
                              child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                    },
                    tooltip: 'Delete Project',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}