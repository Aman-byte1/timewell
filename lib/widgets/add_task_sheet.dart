import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timewell/providers/task_provider.dart';
import 'package:timewell/providers/habit_provider.dart';
import 'package:timewell/models/task_model.dart'; // TaskType should ONLY be imported from here
import 'package:timewell/models/habit_model.dart';
import 'package:intl/intl.dart';

// IMPORTANT: Removed the duplicate 'enum TaskType { todo, habit, recurring }' definition from here.
// It must only be defined in task_model.dart to avoid type conflicts.

class AddTaskSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const AddTaskSheet({super.key, required this.initialDate});

  @override
  _AddTaskSheetState createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  TaskType _selectedType = TaskType.todo;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate; // For To-Do & Recurring
  TimeOfDay? _selectedTime; // For To-Do
  List<int> _selectedDays = []; // For Habit
  DateTime? _startDate; // For Habit
  DateTime? _endDate; // For Habit

  // FocusNode for the title field
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    // Set initial start date for habits to today
    _startDate = DateTime.now();
    // Set initial end date for habits to 30 days from now
    _endDate = DateTime.now().add(const Duration(days: 30));

    // Auto-focus title field after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView( // Enables keyboard-aware scrolling
      padding: EdgeInsets.only(
        bottom: keyboardHeight + 16, // Add padding for keyboard
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time validation
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Item",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 24),

            // Task type selector (Card-style tabs)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTypeCard(
                  TaskType.habit,
                  "Habit",
                  Icons.repeat,
                  "For actions you want to do regularly.",
                ),
                _buildTypeCard(
                  TaskType.todo,
                  "To-Do",
                  Icons.checklist,
                  "A one-time task with a specific due date.",
                ),
                _buildTypeCard(
                  TaskType.recurring,
                  "Recurring",
                  Icons.loop,
                  "Tasks that repeat on specific dates/intervals.",
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              focusNode: _titleFocusNode, // Attach focus node
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title *', // Required field indicator
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Consistent corner radii
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title cannot be empty'; // Real-time error hint
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Dynamic Fields based on TaskType
            AnimatedSize( // Animate height transitions
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: [
                  if (_selectedType == TaskType.todo || _selectedType == TaskType.recurring)
                    _buildDateAndTimeSelectors(context, colorScheme),
                  if (_selectedType == TaskType.habit)
                    _buildHabitDateRangeAndRepeatDays(context, colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Consistent corner radii
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16), // Larger tap target
                  elevation: 3,
                ),
                child: Text(
                  'Save',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(TaskType type, String label, IconData icon, String description) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
          // Request focus on the title field after type selection
          _titleFocusNode.requestFocus();
        },
        child: Tooltip( // Quick preview tooltips
          message: description,
          child: Card(
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surface,
            child: InkWell( // Ripple effect on tap
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
                _titleFocusNode.requestFocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          ),
                    ),
                    if (isSelected) // Show description only for active tab
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateAndTimeSelectors(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDatePickerButton(
                context,
                _selectedDate,
                (pickedDate) {
                  setState(() => _selectedDate = pickedDate);
                },
                "Select Date *",
                DateFormat.yMd().format(_selectedDate),
              ),
            ),
            if (_selectedType == TaskType.todo) // Only show time picker for To-Do
              Expanded(
                child: _buildTimePickerButton(
                  context,
                  _selectedTime,
                  (pickedTime) {
                    setState(() => _selectedTime = pickedTime);
                  },
                  "Select Time",
                  _selectedTime != null ? _selectedTime!.format(context) : "Select Time",
                ),
              ),
          ],
        ),
        if (_selectedType == TaskType.todo) // Validation hint for time
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(
                _selectedTime == null ? 'Time is recommended for To-Do' : '',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHabitDateRangeAndRepeatDays(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDatePickerButton(
                context,
                _startDate,
                (pickedDate) {
                  setState(() => _startDate = pickedDate);
                },
                "Start Date *",
                _startDate != null ? "Start: ${DateFormat.yMd().format(_startDate!)}" : "Select Start Date *",
              ),
            ),
            Expanded(
              child: _buildDatePickerButton(
                context,
                _endDate,
                (pickedDate) {
                  setState(() => _endDate = pickedDate);
                },
                "End Date",
                _endDate != null ? "End: ${DateFormat.yMd().format(_endDate!)}" : "Select End Date (Optional)",
                firstDate: _startDate ?? DateTime.now(), // End date must be after start date
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Repeat Days *", // Required field indicator
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final day = index + 1; // Monday is 1, Sunday is 7
            final isSelected = _selectedDays.contains(day);
            return ChoiceChip(
              label: Text(_getDayAbbreviation(day)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                });
              },
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
            );
          }),
        ),
        if (_selectedDays.isEmpty && _formKey.currentState?.validate() == false) // Show error if no days selected and form is validating
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Text(
              'Please select at least one day',
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickerButton(
      BuildContext context,
      DateTime? currentValue,
      ValueChanged<DateTime> onPicked,
      String label,
      String displayValue, {
      DateTime? firstDate,
      DateTime? lastDate,
      }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell( // Ripple effect
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: currentValue ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: colorScheme, // Use app's color scheme for date picker
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != currentValue) {
          onPicked(picked);
        }
      },
      child: InputDecorator( // Mimic TextFormField appearance
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        child: Text(
          displayValue,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: displayValue.contains("Select") ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
              ),
        ),
      ),
    );
  }

  Widget _buildTimePickerButton(
      BuildContext context,
      TimeOfDay? currentValue,
      ValueChanged<TimeOfDay> onPicked,
      String label,
      String displayValue) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell( // Ripple effect
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: currentValue ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: colorScheme, // Use app's color scheme for time picker
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != currentValue) {
          onPicked(picked);
        }
      },
      child: InputDecorator( // Mimic TextFormField appearance
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        child: Text(
          displayValue,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: displayValue.contains("Select") ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
              ),
        ),
      ),
    );
  }

  String _getDayAbbreviation(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  void _saveItem() {
    // Manually validate all fields before attempting to save
    if (!_formKey.currentState!.validate()) {
      // If validation fails, show a snackbar or scroll to the first error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all required fields correctly."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Additional validation for Habit type
    if (_selectedType == TaskType.habit) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select a start date for your habit."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select at least one repeat day for your habit."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final title = _titleController.text;
    final description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : null;

    if (_selectedType == TaskType.habit) {
      ref.read(habitProvider.notifier).addHabit(Habit(
            id: id,
            title: title,
            description: description,
            startDate: _startDate!,
            endDate: _endDate, // endDate can be null
            repeatDays: _selectedDays,
          ));
    } else if (_selectedType == TaskType.todo) {
      ref.read(taskProvider.notifier).addTask(Task(
            id: id,
            title: title,
            description: description,
            type: TaskType.todo, // Correctly using TaskType from task_model.dart
            date: _selectedDate,
            startTime: _selectedTime,
            status: TaskStatus.pending,
          ));
    } else if (_selectedType == TaskType.recurring) {
      // For recurring, we'll create a task for the selected date,
      // and assume the recurrence logic is handled elsewhere or is
      // a simpler single-day recurring entry.
      // If true recurring logic (e.g., repeating every week for a year) is needed,
      // the Task model and provider would need to be expanded.
      ref.read(taskProvider.notifier).addTask(Task(
            id: id,
            title: title,
            description: description,
            type: TaskType.recurring, // Correctly using TaskType from task_model.dart
            date: _selectedDate,
            startTime: _selectedTime, // Recurring tasks can also have a time
            status: TaskStatus.pending,
          ));
    }

    Navigator.pop(context);
  }
}
