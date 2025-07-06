import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart'; // Ensure this path is correct

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.primary, // Consistent app bar color
        foregroundColor: colorScheme.onPrimary, // Consistent text color
        elevation: 4, // Add a subtle shadow
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Overall padding for the list
        children: [
          // Appearance Section
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent corner radius
            elevation: 2,
            color: colorScheme.surface, // Use surface color for card background
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero, // Remove default ListTile padding
                    title: Text(
                      'Theme Mode',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                    ),
                    // Replaced DropdownButton with SegmentedButton
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const <ButtonSegment<ThemeMode>>[
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.settings_brightness),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: <ThemeMode>{themeMode}, // Set of currently selected values
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        // Only one item can be selected in this case
                        if (newSelection.isNotEmpty) {
                          ref.read(themeProvider.notifier).setTheme(newSelection.first);
                        }
                      },
                      style: SegmentedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant, // Inactive text/icon color
                        selectedForegroundColor: colorScheme.onPrimary, // Active text/icon color
                        selectedBackgroundColor: colorScheme.primary, // Active background color
                        side: BorderSide(color: colorScheme.outline, width: 1), // Border color
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners for segments
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notifications Section
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Daily Reminders',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                    ),
                    subtitle: Text(
                      'Get daily updates on your tasks and habits', // More descriptive subtitle
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    value: true, // Placeholder value
                    onChanged: (value) {
                      // Implement notification toggle logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Daily Reminders Toggled: $value')),
                      );
                    },
                    activeColor: colorScheme.primary, // Use primary color for active state
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Completion Alerts',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                    ),
                    subtitle: Text(
                      'Notify when a task or habit is completed', // More descriptive subtitle
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    value: true, // Placeholder value
                    onChanged: (value) {
                      // Implement notification toggle logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Completion Alerts Toggled: $value')),
                      );
                    },
                    activeColor: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // About Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Version',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                    ),
                    onTap: () {
                      // Implement navigation to Privacy Policy page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigating to Privacy Policy... (Not implemented)')),
                      );
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}