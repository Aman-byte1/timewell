import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timewell/widgets/bottom_navigation.dart';
import 'challenges_screen.dart'; // Import the new ChallengesScreen
import 'timeline_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../widgets/add_timer_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    ChallengesScreen(), // Replaced StopwatchScreen with ChallengesScreen
    TimelineScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeWell'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: _currentIndex == 1 // This FAB is for TimelineScreen
          ? FloatingActionButton(
              onPressed: () => _showAddTimerDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTimerDialog(),
    );
  }
}
