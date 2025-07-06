import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
// Removed TableCalendar import as it is no longer used

import '../widgets/task_item.dart';
import '../widgets/habit_item.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../models/task_model.dart';
import '../models/habit_model.dart';
import '../widgets/add_task_sheet.dart'; // Make sure to import AddTaskSheet
import 'habit_statistics_screen.dart'; // Import the HabitStatisticsScreen

// For simple celebration animation
import 'package:confetti/confetti.dart'; // Add this to pubspec.yaml: confetti: ^0.7.0

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with SingleTickerProviderStateMixin {
  // _selectedDay will hold the currently selected date in the horizontal list.
  DateTime _selectedDay = DateTime.now(); 

  // ScrollController for the horizontal day list to enable programmatic scrolling.
  final ScrollController _dayListScrollController = ScrollController();

  // Confetti controller for celebration animation
  late ConfettiController _confettiController;

  // Animation controllers for FAB pulse animation
  late AnimationController _fabPulseController;
  late Animation<double> _fabPulseAnimation;

  // State to track if the AddTaskSheet is currently open
  bool _isAddTaskSheetOpen = false;

  @override
  void initState() {
    super.initState();
    // Schedule a callback to scroll to the selected day (today initially)
    // after the widget has been built and rendered. This ensures the list
    // has a layout to scroll within.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Initialize FAB pulse animation
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Repeat the animation back and forth

    _fabPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _fabPulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks.
    _dayListScrollController.dispose();
    _confettiController.dispose();
    _fabPulseController.dispose(); // Dispose FAB pulse controller
    super.dispose();
  }

  /// Scrolls the horizontal day list to center the currently selected day.
  void _scrollToSelectedDay() {
    // Define the total number of days displayed in the horizontal list.
    // This range is centered around the current date.
    const int totalDaysToShow = 120; // e.g., 60 days before and 60 days after today

    // Calculate the start date of our displayed range.
    final DateTime startDate = DateTime.now().subtract(const Duration(days: totalDaysToShow ~/ 2));

    // Determine the index of the _selectedDay within this range.
    final int selectedDayIndex = _selectedDay.difference(startDate).inDays;

    // Only attempt to scroll if the selected day is within the generated range.
    if (selectedDayIndex >= 0 && selectedDayIndex < totalDaysToShow) {
      // Approximate width of each day item. Adjust this value if the actual
      // width of your _DayItem widget changes significantly.
      const double itemWidth = 68.0; // Based on _DayItem's width (60) + margin (4*2)
      final double screenWidth = MediaQuery.of(context).size.width;

      // Calculate the target scroll offset to center the selected day.
      // It moves the start of the item to 'offset' pixels from the left,
      // then adjusts to center it on the screen.
      final double offset = (selectedDayIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      // Animate the scroll controller to the calculated offset.
      _dayListScrollController.animateTo(
        // Clamp the offset to ensure it stays within the valid scroll range.
        offset.clamp(0.0, _dayListScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Plays a celebration animation (e.g., confetti).
  void _playCelebrationAnimation() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    // Watch task and habit providers for state changes.
    final tasks = ref.watch(taskProvider);
    final habits = ref.watch(habitProvider); // Get all habits for statistics screen
    final selectedDate = _selectedDay; // Use the current selected day

    // Filter tasks for the selected day.
    final dayTasks = tasks.where((task) {
      return task.date.year == selectedDate.year &&
          task.date.month == selectedDate.month &&
          task.date.day == selectedDate.day;
    }).toList();

    // Filter habits for the selected day based on their repeat days.
    final dayHabits = habits.where((habit) {
      return habit.repeatDays.contains(selectedDate.weekday);
    }).toList();

    // Generate a list of DateTime objects for the horizontal calendar.
    // This creates a range of days (e.g., 60 days before and 60 days after today).
    final List<DateTime> days = List.generate(120, (index) {
      return DateTime.now().subtract(const Duration(days: 60)).add(Duration(days: index));
    });

    return Scaffold(
      // Floating Action Button to add new tasks/habits.
      floatingActionButton: ScaleTransition( // Apply scale animation for pulse effect
        scale: _fabPulseAnimation,
        child: FloatingActionButton(
          onPressed: () => _showAddTaskSheet(context, selectedDate),
          // Apply theme colors for better visual consistency.
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          // Context-aware icon: changes based on if the sheet is open
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              _isAddTaskSheetOpen ? Icons.edit_note : Icons.add, // Changes icon when pressed/sheet open
              key: ValueKey<bool>(_isAddTaskSheetOpen), // Key for animation
            ),
          ),
        ),
      ),
      body: Stack( // Use Stack to overlay confetti
        children: [
          CustomScrollView(
            slivers: [
              // Main AppBar for the screen, pinned at the top.
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false, // No back button by default
                title: Text(
                  // Display the month and year of the currently selected day.
                  DateFormat.yMMMM().format(_selectedDay),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0, // Remove default shadow for a flatter look.
                actions: [
                  // Button to navigate to Habit Statistics Screen
                  IconButton(
                    icon: Icon(Icons.bar_chart, // Changed icon to a filled one for clarity
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {
                      // Navigate to the HabitStatisticsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitStatisticsScreen(habits: habits), // Pass all habits
                        ),
                      );
                    },
                  ),
                ],
                // The horizontal day list is placed in the bottom section of the AppBar,
                // making it sticky below the main title.
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80.0), // Height allocated for the day list
                  child: Container(
                    color: Theme.of(context).colorScheme.surface, // Background color for the day list area
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      height: 70.0, // Fixed height for individual day items
                      child: ListView.builder(
                        controller: _dayListScrollController, // Attach the scroll controller
                        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                        itemCount: days.length, // Number of days to display
                        itemBuilder: (context, index) {
                          final day = days[index];
                          // Check if the current day in the list is the selected day.
                          final isSelected = day.year == _selectedDay.year &&
                              day.month == _selectedDay.month &&
                              day.day == _selectedDay.day;
                          return _DayItem(
                            date: day,
                            isSelected: isSelected,
                            onTap: (selectedDay) {
                              // When a day is tapped, update the selected day state.
                              setState(() {
                                _selectedDay = selectedDay;
                              });
                              // Optional: Re-scroll to center the newly selected day if needed.
                              // _scrollToSelectedDay(); // Uncomment if you want it to always re-center on tap
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // SliverAppBar for the selected date and task/habit list header.
              // This will stick below the horizontal day list and stats section.
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.background, // Match screen background
                title: Text(
                  DateFormat.yMMMMd().format(selectedDate), // Display full date of selected day
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),

              // SliverList to display tasks and habits for the selected day.
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // If there are no tasks or habits for the day, show a message.
                    if (dayTasks.isEmpty && dayHabits.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            "No tasks or habits for this day. Tap '+' to add one!",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // Render TaskItem widgets.
                    if (index < dayTasks.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card( // Wrap TaskItem in a Card for improved visuals.
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: TaskItem(
                            task: dayTasks[index],
                            onStart: () => ref.read(taskProvider.notifier).startTask(dayTasks[index].id),
                            onComplete: () {
                              ref.read(taskProvider.notifier).completeTask(dayTasks[index].id);
                              // Trigger celebration when a task is completed
                              _playCelebrationAnimation();
                            },
                            onDelete: () => ref.read(taskProvider.notifier).deleteTask(dayTasks[index].id),
                          ),
                        ),
                      );
                    }

                    // Render HabitItem widgets after all tasks.
                    final habitIndex = index - dayTasks.length;
                    if (habitIndex < dayHabits.length) {
                      final habit = dayHabits[habitIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card( // Wrap HabitItem in a Card for improved visuals.
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: HabitItem(
                            habit: habit,
                            date: selectedDate,
                            onComplete: () {
                              ref.read(habitProvider.notifier).markHabitCompleted(habit.id, selectedDate);
                              // Trigger celebration when a habit is completed
                              _playCelebrationAnimation();
                            },
                            onMissed: () => ref.read(habitProvider.notifier).markHabitMissed(habit.id, selectedDate),
                          ),
                        ),
                      );
                    }

                    return null;
                  },
                  // Adjust childCount based on whether there are tasks/habits or just the empty message.
                  childCount: (dayTasks.isEmpty && dayHabits.isEmpty) ? 1 : dayTasks.length + dayHabits.length,
                ),
              ),
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
              shouldLoop: false, // don't loop the animation
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ], // manually specify the colors to be used
              createParticlePath: (size) => Path() // Simple square particles
                ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the AddTaskSheet modal bottom sheet.
  void _showAddTaskSheet(BuildContext context, DateTime selectedDate) async {
    setState(() {
      _isAddTaskSheetOpen = true; // Set state to indicate sheet is open
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more screen height
      builder: (context) => AddTaskSheet(initialDate: selectedDate),
    );

    setState(() {
      _isAddTaskSheetOpen = false; // Reset state when sheet is closed
    });
  }
}

/// A custom widget to display a single day in the horizontal calendar list.
class _DayItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;

  const _DayItem({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Determine if the current day is today for special styling.
    final bool isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return GestureDetector(
      onTap: () => onTap(date), // Call the onTap callback when the day is tapped.
      child: Container(
        width: 60.0, // Fixed width for each day item for consistent layout.
        margin: const EdgeInsets.symmetric(horizontal: 4.0), // Spacing between day items.
        decoration: BoxDecoration(
          // Background color changes based on selection and whether it's today.
          color: isSelected
              ? colorScheme.primary // Primary color if selected
              : isToday
                  ? colorScheme.primary.withOpacity(0.1) // Light primary if today but not selected
                  : colorScheme.surfaceVariant.withOpacity(0.3), // Subtle background for others
          borderRadius: BorderRadius.circular(12.0), // Rounded corners for a modern look.
          border: isSelected
              ? Border.all(color: colorScheme.primaryContainer, width: 2) // Stronger border if selected
              : Border.all(color: Colors.transparent), // No border otherwise
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically.
          children: [
            Text(
              DateFormat.E().format(date), // Display short weekday name (e.g., "Mon").
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4.0), // Small space between weekday and day number.
            Text(
              date.day.toString(), // Display day number (e.g., "15").
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
