import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // New charting library
import 'package:timewell/models/habit_model.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Helper class for Pie Chart data (for Syncfusion)
class _PieData {
  final String category;
  final num value;
  final Color color;

  _PieData(this.category, this.value, this.color);
}

// Helper class for Line Chart data (for Syncfusion)
class _LineData {
  final DateTime date;
  final double percentage;

  _LineData(this.date, this.percentage);
}

class HabitStatisticsScreen extends StatelessWidget {
  final List<Habit> habits;

  const HabitStatisticsScreen({super.key, required this.habits});

  // List of motivational quotes that change daily
  static const List<String> _motivationQuotes = [
    "Consistency is more important than perfection.",
    "Every day is a new beginning. Take a deep breath and start again.",
    "The journey of a thousand miles begins with a single step.",
    "Small daily improvements are the key to staggering long-term results.",
    "You don't have to be great to start, but you have to start to be great.",
    "Discipline is choosing between what you want now and what you want most.",
    "Success is the sum of small efforts repeated day in and day out.",
    "The best way to predict the future is to create it.",
    "Believe you can and you're halfway there.",
    "The only way to do great work is to love what you do.",
    "Your habits define your future.",
    "One step at a time, one day at a time.",
    "Keep going. Everything you need will come to you at the perfect time.",
    "The secret of your future is hidden in your daily routine.",
    "Don't watch the clock; do what it does. Keep going.",
  ];

  // Get a daily changing motivation quote
  String _getDailyMotivationQuote() {
    final int dayOfYear = int.parse(DateFormat('D').format(DateTime.now()));
    return _motivationQuotes[dayOfYear % _motivationQuotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Statistics'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),
      body: habits.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 60, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                    const SizedBox(height: 16),
                    Text(
                      "No habits to display statistics for. Add some habits to see your progress!",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: habits.length + 1, // +1 for the motivation quote
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Motivation Quote Section
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Card(
                      color: colorScheme.surfaceVariant,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daily Motivation:",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getDailyMotivationQuote(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onSurface,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final habit = habits[index - 1]; // Adjust index for habits list
                return _buildHabitCard(context, habit);
              },
            ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final completed = habit.completionDates.length;
    final missed = habit.missedDates.length;
    final total = completed + missed;
    final successRate = total > 0 ? (completed / total * 100) : 0.0;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Data for Syncfusion Pie Chart
    final List<_PieData> pieData = [];
    if (completed > 0) {
      pieData.add(_PieData('Completed', completed, Colors.green.shade400));
    }
    if (missed > 0) {
      pieData.add(_PieData('Missed', missed, Colors.orange.shade400));
    }

    // Prepare data for the Line Chart (last 30 days trend)
    final List<_LineData> lineData = [];
    final now = DateTime.now();
    double maxY = 0;

    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      int completionsOnDay = 0;
      int scheduledOnDay = 0;

      if (habit.repeatDays.contains(date.weekday) && !date.isAfter(DateTime(now.year, now.month, now.day))) {
        scheduledOnDay = 1;
        if (habit.completionDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day)) {
          completionsOnDay = 1;
        }
      }

      double dailyPercentage = scheduledOnDay == 0 ? 0.0 : (completionsOnDay / scheduledOnDay) * 100;
      lineData.add(_LineData(date, dailyPercentage));
      if (dailyPercentage > maxY) maxY = dailyPercentage;
    }
    if (maxY < 100 && lineData.isNotEmpty) maxY = 100;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    habit.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: colorScheme.primary),
                  onPressed: () async {
                    try {
                      final shareText = _generateShareText(habit, completed, missed, successRate);
                      await Share.share(shareText);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to share: $e')),
                      );
                    }
                  },
                  tooltip: 'Share Statistics',
                ),
              ],
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
            if (total > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      Text(
                        "Completion Rate",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                      ),
                      Expanded(
                        child: SfCircularChart(
                          series: <CircularSeries>[
                            DoughnutSeries<_PieData, String>(
                              dataSource: pieData,
                              xValueMapper: (_PieData data, _) => data.category,
                              yValueMapper: (_PieData data, _) => data.value,
                              pointColorMapper: (_PieData data, _) => data.color,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                                textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Labels on the slices
                                ),
                                connectorLineSettings: const ConnectorLineSettings(type: ConnectorType.curve, length: '15%'),
                                // Customize labels to show only value
                                builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                                  return Text('${data.value.toInt()}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              innerRadius: '60%', // Corresponds to centerSpaceRadius
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(context, Colors.green.shade400, "Completed"),
                            const SizedBox(width: 16),
                            _buildLegendItem(context, Colors.orange.shade400, "Missed"),
                          ],
                        ),
                      ),
                    ],
                  ),
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
            const SizedBox(height: 24),
            Text(
              "Daily Trend (Last 30 Days)",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat.MMMd(),
                  intervalType: DateTimeIntervalType.days,
                  interval: 5, // Show a label every 5 days
                  axisLine: AxisLine(color: colorScheme.outline),
                  majorGridLines: MajorGridLines(color: colorScheme.outlineVariant.withOpacity(0.5), width: 0.5),
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: maxY,
                  interval: 50, // Show 0%, 50%, 100%
                  axisLine: AxisLine(color: colorScheme.outline),
                  majorGridLines: MajorGridLines(color: colorScheme.outlineVariant.withOpacity(0.5), width: 0.5),
                  labelFormat: '{value}%',
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                series: <CartesianSeries>[
                  SplineAreaSeries<_LineData, DateTime>( // SplineAreaSeries for curved line with area
                    dataSource: lineData,
                    xValueMapper: (_LineData data, _) => data.date,
                    yValueMapper: (_LineData data, _) => data.percentage,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.2),
                        colorScheme.tertiary.withOpacity(0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    color: colorScheme.primary.withOpacity(0.8), // Line color
                    borderWidth: 3,
                    borderColor: colorScheme.primary.withOpacity(0.8),
                    borderDrawMode: BorderDrawMode.top,
                    splineType: SplineType.natural, // For curved line
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                "Daily Notes Review",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: habit.dailyNotes.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No daily notes recorded for this habit yet.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]
                  : habit.dailyNotes.entries.map((entry) {
                      final date = DateFormat('yyyy-MM-dd').parse(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(date),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                            Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
                          ],
                        ),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              "Schedule: ${_formatDays(habit.repeatDays)}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
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

  Widget _buildLegendItem(BuildContext context, Color color, String text) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return "Daily";
    final List<String> dayNames = [];
    for (int i = 1; i <= 7; i++) {
      dayNames.add(DateFormat.E().format(DateTime(2023, 1, i + 1)));
    }
    return days.map((day) => dayNames[day - 1]).join(", ");
  }

  String _generateShareText(Habit habit, int completed, int missed, double successRate) {
    String schedule = _formatDays(habit.repeatDays);
    String activePeriod = "${DateFormat.yMd().format(habit.startDate)} to ${habit.endDate != null ? DateFormat.yMd().format(habit.endDate!) : 'No end date'}";
    
    return """Habit Statistics for "${habit.title}":
Completed: $completed
Missed: $missed
Success Rate: ${successRate.toStringAsFixed(1)}%
Schedule: $schedule
Active Period: $activePeriod

Track your habits with TimeWell!""";
  }
}
