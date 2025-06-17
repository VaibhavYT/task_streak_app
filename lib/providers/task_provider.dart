import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_streak_app/models/task.dart';
import 'package:task_streak_app/models/daily_completion.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Task> _tasks = [];
  Map<DateTime, int> _dailyCompletionsCount = {};
  bool _isLoading = false;

  // Getters
  List<Task> get tasks => _tasks;
  Map<DateTime, int> get dailyCompletionsCount => _dailyCompletionsCount;
  bool get isLoading => _isLoading;
  int get currentStreak => calculateCurrentStreak();

  String? get _userId => _supabase.auth.currentUser?.id;

  // Fetch all tasks for the current user
  Future<void> fetchTasks() async {
    if (_userId == null) {
      debugPrint('No user logged in, cannot fetch tasks');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      _tasks = (response as List<dynamic>)
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Fetched ${_tasks.length} tasks for user: $_userId');
    } catch (error) {
      debugPrint('Error fetching tasks: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    if (_userId == null) {
      debugPrint('No user logged in, cannot add task');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final taskData = task.toJson();
      taskData.remove('id'); // Let Supabase generate the ID

      final response =
          await _supabase.from('tasks').insert(taskData).select().single();

      final newTask = Task.fromJson(response);
      _tasks.insert(0, newTask); // Add to beginning of list

      debugPrint('Added new task: ${newTask.title}');
    } catch (error) {
      debugPrint('Error adding task: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    if (_userId == null) {
      debugPrint('No user logged in, cannot update task');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id)
          .eq('user_id', _userId!);

      // Update local list
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }

      debugPrint('Updated task: ${task.title}');
    } catch (error) {
      debugPrint('Error updating task: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) {
      debugPrint('No user logged in, cannot delete task');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', _userId!);

      // Remove from local list
      _tasks.removeWhere((task) => task.id == taskId);

      debugPrint('Deleted task: $taskId');
    } catch (error) {
      debugPrint('Error deleting task: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark a task as complete for today
  Future<void> markTaskComplete(String taskId) async {
    if (_userId == null) {
      debugPrint('No user logged in, cannot mark task complete');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final completionData = {
        'user_id': _userId!,
        'task_id': taskId,
        'completion_date': _formatDateOnly(today),
        'completed_at': now.toIso8601String(),
      };

      await _supabase.from('daily_completions').insert(completionData);

      // Update local completions count
      _dailyCompletionsCount[today] = (_dailyCompletionsCount[today] ?? 0) + 1;

      debugPrint(
          'Marked task $taskId as complete for ${_formatDateOnly(today)}');
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        // Unique constraint violation
        debugPrint('Task already completed today');
        // Don't rethrow, this is an expected scenario
      } else {
        debugPrint('Error marking task complete: $error');
        rethrow;
      }
    } catch (error) {
      debugPrint('Unexpected error marking task complete: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch daily completion counts for streak visualization
  Future<void> fetchDailyCompletionCounts() async {
    if (_userId == null) {
      debugPrint('No user logged in, cannot fetch completion counts');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('daily_completions')
          .select('completion_date')
          .eq('user_id', _userId!);

      // Process completions into a map of date -> count
      final Map<DateTime, int> completionsMap = {};

      for (final completion in response) {
        final completionDate =
            DateTime.parse(completion['completion_date'] as String);
        final dateKey = DateTime(
            completionDate.year, completionDate.month, completionDate.day);
        completionsMap[dateKey] = (completionsMap[dateKey] ?? 0) + 1;
      }

      _dailyCompletionsCount = completionsMap;

      debugPrint('Fetched completion counts for ${completionsMap.length} days');
    } catch (error) {
      debugPrint('Error fetching daily completion counts: $error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if a task is completed today
  Future<bool> isTaskCompletedToday(String taskId) async {
    if (_userId == null) return false;

    try {
      final today = DateTime.now();
      final todayString = _formatDateOnly(today);

      final response = await _supabase
          .from('daily_completions')
          .select('id')
          .eq('user_id', _userId!)
          .eq('task_id', taskId)
          .eq('completion_date', todayString)
          .maybeSingle();

      return response != null;
    } catch (error) {
      debugPrint('Error checking task completion: $error');
      return false;
    }
  }

  // Get completion count for a specific date
  int getCompletionCountForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _dailyCompletionsCount[dateKey] ?? 0;
  }

  // Helper method to format date as YYYY-MM-DD
  String _formatDateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Clear all data (useful for logout)
  void clearData() {
    _tasks.clear();
    _dailyCompletionsCount.clear();
    _isLoading = false;
    notifyListeners();
  }

  // Calculate the current consecutive daily streak
  int calculateCurrentStreak() {
    if (_dailyCompletionsCount.isEmpty) {
      return 0;
    }

    // Get all dates with completions and sort in descending order
    final completedDates = _dailyCompletionsCount.keys
        .where((date) => _dailyCompletionsCount[date]! > 0)
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (most recent first)

    if (completedDates.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final yesterdayKey = todayKey.subtract(const Duration(days: 1));

    int streak = 0;
    DateTime checkDate;

    // Start checking from today if completed, otherwise from yesterday
    if (_dailyCompletionsCount[todayKey] != null &&
        _dailyCompletionsCount[todayKey]! > 0) {
      checkDate = todayKey;
    } else {
      checkDate = yesterdayKey;
    }

    // Count consecutive days backwards
    while (true) {
      final dateKey = DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (_dailyCompletionsCount[dateKey] != null &&
          _dailyCompletionsCount[dateKey]! > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break; // Break the streak
      }
    }

    return streak;
  }

  // Get the longest streak ever achieved
  int calculateLongestStreak() {
    if (_dailyCompletionsCount.isEmpty) {
      return 0;
    }

    final completedDates = _dailyCompletionsCount.keys
        .where((date) => _dailyCompletionsCount[date]! > 0)
        .toList()
      ..sort(); // Sort ascending

    if (completedDates.isEmpty) {
      return 0;
    }

    int longestStreak = 0;
    int currentStreakLength = 1;
    DateTime previousDate = completedDates.first;

    for (int i = 1; i < completedDates.length; i++) {
      final currentDate = completedDates[i];
      final expectedNextDate = previousDate.add(const Duration(days: 1));

      if (_isSameDay(currentDate, expectedNextDate)) {
        // Consecutive day
        currentStreakLength++;
      } else {
        // Gap in streak
        longestStreak = currentStreakLength > longestStreak
            ? currentStreakLength
            : longestStreak;
        currentStreakLength = 1;
      }

      previousDate = currentDate;
    }

    // Check if the last streak is the longest
    longestStreak = currentStreakLength > longestStreak
        ? currentStreakLength
        : longestStreak;

    return longestStreak;
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get streak status for UI display
  Map<String, dynamic> getStreakInfo() {
    final current = currentStreak;
    final longest = calculateLongestStreak();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final todayCompleted = _dailyCompletionsCount[todayKey] != null &&
        _dailyCompletionsCount[todayKey]! > 0;

    return {
      'currentStreak': current,
      'longestStreak': longest,
      'todayCompleted': todayCompleted,
      'streakMessage': _getStreakMessage(current, todayCompleted),
    };
  }

  // Get encouraging message based on streak status
  String _getStreakMessage(int streak, bool todayCompleted) {
    if (streak == 0) {
      return todayCompleted
          ? "Great start! Keep it up!"
          : "Start your streak today!";
    } else if (streak == 1) {
      return todayCompleted
          ? "Day 1 complete! Build momentum!"
          : "Keep the momentum going!";
    } else if (streak < 7) {
      return todayCompleted
          ? "Building a habit! $streak days strong!"
          : "Don't break the streak!";
    } else if (streak < 30) {
      return todayCompleted
          ? "Amazing streak! $streak days!"
          : "Incredible streak at risk!";
    } else {
      return todayCompleted
          ? "Legendary streak! $streak days!"
          : "Legendary streak needs you!";
    }
  }
}
