import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timewell/models/habit_model.dart'; // Ensure this path is correct
import 'package:intl/intl.dart';

class HabitStatisticsScreen extends StatelessWidget {
  final List<Habit> habits;

  const HabitStatisticsScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: habits.isEmpty
          ? Center(
              child: Text(
                "No habits to display statistics for.",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _buildHabitCard(context, habit);
              },
            ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final completed = habit.completionDates.length;
    final missed = habit.missedDates.length;
    final total = completed + missed;
    final successRate = total > 0 ? (completed / total * 100) : 0;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            if (habit.description != null && habit.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  habit.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(context, "Completed", completed.toString(), Colors.green),
                _buildStatCard(context, "Missed", missed.toString(), Colors.orange),
                _buildStatCard(context, "Success", "${successRate.toStringAsFixed(1)}%", Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            // Only show chart if there's data to display
            if (total > 0)
              SizedBox(
                height: 200, // Fixed height for the chart
                child: SfCircularChart(
                  title: ChartTitle(
                    text: "Completion Rate",
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                  legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  series: <CircularSeries>[
                    PieSeries<MapEntry<String, int>, String>(
                      dataSource: [
                        MapEntry("Completed", completed),
                        MapEntry("Missed", missed),
                      ],
                      xValueMapper: (data, _) => data.key,
                      yValueMapper: (data, _) => data.value,
                      pointColorMapper: (data, _) =>
                          data.key == "Completed" ? Colors.green.shade400 : Colors.orange.shade400,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                        connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.curve,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Add animation for better UX
                      animationDuration: 800,
                    )
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No completion or missed data yet for this habit.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              "Schedule: ${_formatDays(habit.repeatDays)}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            // Corrected line: Safely handle null endDate
            Text(
              "Active: ${DateFormat.yMd().format(habit.startDate)} to ${habit.endDate != null ? DateFormat.yMd().format(habit.endDate!) : 'No end date'}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return "Daily";
    // Using DateFormat to get localized day names
    final List<String> dayNames = [];
    for (int i = 1; i <= 7; i++) {
      // Create a dummy date for each weekday to get its name
      dayNames.add(DateFormat.E().format(DateTime(2023, 1, i + 1))); // Jan 2, 2023 was a Monday (weekday 1)
    }
    
    return days.map((day) => dayNames[day - 1]).join(", ");
  }
}