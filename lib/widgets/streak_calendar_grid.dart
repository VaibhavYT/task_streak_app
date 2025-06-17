import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_streak_app/theme/app_theme.dart';

class StreakCalendarGrid extends StatefulWidget {
  final Map<DateTime, int> dailyCompletionsCount;
  final DateTime? focusedDay;

  const StreakCalendarGrid({
    super.key,
    required this.dailyCompletionsCount,
    this.focusedDay,
  });

  @override
  State<StreakCalendarGrid> createState() => _StreakCalendarGridState();
}

class _StreakCalendarGridState extends State<StreakCalendarGrid> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _selectedDay = DateTime.now();
  }

  Color _getStreakColor(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    final completionCount = widget.dailyCompletionsCount[dayKey] ?? 0;

    if (completionCount == 0) {
      return Colors.transparent;
    } else if (completionCount <= 2) {
      return AppTheme.lightGreenStreak.withOpacity(0.7);
    } else if (completionCount <= 4) {
      return AppTheme.mediumDarkGreenStreak.withOpacity(0.7);
    } else {
      return AppTheme.veryDarkGreenStreak.withOpacity(0.8);
    }
  }

  Widget _buildCalendarCell(
      BuildContext context, DateTime day, DateTime focusedDay) {
    final isToday = isSameDay(day, DateTime.now());
    final isSelected = isSameDay(day, _selectedDay);
    final streakColor = _getStreakColor(day);
    final completionCount =
        widget.dailyCompletionsCount[DateTime(day.year, day.month, day.day)] ??
            0;

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: streakColor,
        borderRadius: BorderRadius.circular(8.0),
        border: isToday
            ? Border.all(color: AppTheme.mediumDarkGreenStreak, width: 2)
            : isSelected
                ? Border.all(color: AppTheme.veryDarkGreenStreak, width: 1.5)
                : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: streakColor == Colors.transparent
                    ? AppTheme.primaryTextColor
                    : Colors.white,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (completionCount > 0)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      borderRadius: BorderRadius.circular(16.0),
      blurStrengthX: 8.0,
      blurStrengthY: 8.0,
      color: Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar title
            Text(
              'Streak Calendar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.veryDarkGreenStreak,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Calendar widget
            TableCalendar<dynamic>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

              // Calendar styling
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: AppTheme.primaryTextColor,
                ),
                defaultTextStyle: TextStyle(
                  color: AppTheme.primaryTextColor,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                // Remove default decorations since we're using custom builders
                todayDecoration: const BoxDecoration(),
                selectedDecoration: const BoxDecoration(),
                defaultDecoration: const BoxDecoration(),
                weekendDecoration: const BoxDecoration(),
                outsideDecoration: const BoxDecoration(),
                disabledDecoration: const BoxDecoration(),
                holidayDecoration: const BoxDecoration(),
                rangeStartDecoration: const BoxDecoration(),
                rangeEndDecoration: const BoxDecoration(),
                rangeHighlightDecoration: const BoxDecoration(),
                withinRangeDecoration: const BoxDecoration(),
              ),

              // Header styling
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.veryDarkGreenStreak,
                              fontWeight: FontWeight.w600,
                            ) ??
                        const TextStyle(),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppTheme.mediumDarkGreenStreak,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.mediumDarkGreenStreak,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),

              // Days of week styling
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Custom cell builders
              calendarBuilders: CalendarBuilders(
                defaultBuilder: _buildCalendarCell,
                todayBuilder: _buildCalendarCell,
                selectedBuilder: _buildCalendarCell,
                outsideBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Event handling
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('0 tasks', Colors.grey.withOpacity(0.3)),
                _buildLegendItem('1-2 tasks', AppTheme.lightGreenStreak),
                _buildLegendItem('3-4 tasks', AppTheme.mediumDarkGreenStreak),
                _buildLegendItem('5+ tasks', AppTheme.veryDarkGreenStreak),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTextColor,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
