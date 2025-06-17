import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:task_streak_app/theme/app_theme.dart';
import 'package:task_streak_app/models/task.dart';
import 'package:task_streak_app/widgets/task_card.dart';
import 'package:task_streak_app/providers/task_provider.dart';
import 'package:task_streak_app/widgets/streak_calendar_grid.dart';
import 'package:task_streak_app/screens/add_task_screen.dart';
import 'package:task_streak_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.fetchTasks();
      taskProvider.fetchDailyCompletionCounts();
    });
  }

  Future<void> _refreshTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.fetchTasks();
    await taskProvider.fetchDailyCompletionCounts();
  }

  List<Task> _getTasksByCategory(List<Task> tasks, String? category) {
    if (category == null) {
      return tasks.where((task) => task.category == null).toList();
    }
    return tasks.where((task) => task.category == category).toList();
  }

  int _getTodayCompletedCount() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    return taskProvider.getCompletionCountForDate(todayKey);
  }

  Widget _buildEmptyTasksState(String title, String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LiquidGlass(
        blur: 8.0,
        glassContainsChild: true,
        settings: LiquidGlassSettings(
          thickness: 40,
          lightIntensity: 0.1,
          ambientStrength: 0,
          glassColor: Colors.white.withOpacity(0.1),
        ),
        shape: LiquidRoundedSuperellipse(
            borderRadius:
                Radius.circular(16.0)), // Changed from LiquidGlassSquircle
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 64,
                color: AppTheme.secondaryTextColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.mediumDarkGreenStreak),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your tasks...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightGreenStreak.withOpacity(0.2),
              AppTheme.backgroundColorLight,
              AppTheme.mediumDarkGreenStreak.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final todayCompletedCount = _getTodayCompletedCount();
              final categories = ['Fitness', 'Health', 'Learning', 'Work'];
              final streakInfo = taskProvider.getStreakInfo();

              return RefreshIndicator(
                onRefresh: _refreshTasks,
                child: CustomScrollView(
                  slivers: [
                    // App bar with completed tasks count
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      flexibleSpace: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Today\'s Tasks',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color:
                                                  AppTheme.veryDarkGreenStreak,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Streak badge
                                      LiquidGlass(
                                        blur: 8.0,
                                        glassContainsChild: true,
                                        settings: LiquidGlassSettings(
                                          thickness: 40,
                                          lightIntensity: 0.1,
                                          ambientStrength: 0,
                                          glassColor:
                                              Colors.white.withOpacity(0.1),
                                        ),
                                        shape: LiquidRoundedSuperellipse(
                                            // Changed from LiquidGlassSquircle
                                            borderRadius: Radius.circular(
                                                12)), // Changed from BorderRadius
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.local_fire_department,
                                                size: 16,
                                                color: streakInfo[
                                                            'currentStreak'] >
                                                        0
                                                    ? Colors.white
                                                    : AppTheme
                                                        .secondaryTextColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${streakInfo['currentStreak']}',
                                                style: TextStyle(
                                                  color: streakInfo[
                                                              'currentStreak'] >
                                                          0
                                                      ? Colors.white
                                                      : AppTheme
                                                          .secondaryTextColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$todayCompletedCount completed today',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.mediumDarkGreenStreak,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: AppTheme.veryDarkGreenStreak,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Streak counter with enhanced information
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LiquidGlass(
                          blur: 10.0,
                          glassContainsChild: true,
                          settings: LiquidGlassSettings(
                            thickness: 40,
                            lightIntensity: 0.1,
                            ambientStrength: 0,
                            glassColor: Colors.white.withOpacity(0.1),
                          ),
                          shape: LiquidRoundedSuperellipse(
                            // Changed from LiquidGlassSquircle
                            borderRadius: Radius.circular(
                                16.0), // Changed from BorderRadius
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Current Streak',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.veryDarkGreenStreak,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${streakInfo['currentStreak']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                            color:
                                                AppTheme.mediumDarkGreenStreak,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 48,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.local_fire_department,
                                      color: streakInfo['currentStreak'] > 0
                                          ? AppTheme.mediumDarkGreenStreak
                                          : AppTheme.secondaryTextColor,
                                      size: 32,
                                    ),
                                  ],
                                ),
                                Text(
                                  streakInfo['currentStreak'] == 1
                                      ? 'day'
                                      : 'days',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  streakInfo['streakMessage'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.mediumDarkGreenStreak,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                if (streakInfo['longestStreak'] >
                                    streakInfo['currentStreak']) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Personal best: ${streakInfo['longestStreak']} days',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.secondaryTextColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Streak Calendar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: taskProvider.dailyCompletionsCount.isEmpty
                            ? LiquidGlass(
                                blur: 8.0,
                                glassContainsChild: true,
                                settings: LiquidGlassSettings(
                                  thickness: 40,
                                  lightIntensity: 0.1,
                                  ambientStrength: 0,
                                  glassColor: Colors.white.withOpacity(0.1),
                                ),
                                shape: LiquidRoundedSuperellipse(
                                    // Changed from LiquidGlassSquircle
                                    borderRadius: Radius.circular(
                                        16.0)), // Changed from BorderRadius
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Streak Calendar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color:
                                                  AppTheme.veryDarkGreenStreak,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 48,
                                        color: AppTheme.secondaryTextColor
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No completions yet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: AppTheme.primaryTextColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Complete tasks to see your streak calendar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  AppTheme.secondaryTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : StreakCalendarGrid(
                                dailyCompletionsCount:
                                    taskProvider.dailyCompletionsCount,
                              ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Loading indicator
                    if (taskProvider.isLoading) _buildLoadingState(),

                    // Tasks by category
                    if (!taskProvider.isLoading) ...[
                      // Check if no tasks at all
                      if (taskProvider.tasks.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildEmptyTasksState(
                            'No tasks added yet!',
                            'Tap the + button to add your first task and start building your streak.',
                            Icons.task_outlined,
                          ),
                        ),
                      ] else ...[
                        // Daily tasks section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Daily Tasks',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.veryDarkGreenStreak,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // Daily tasks list
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final dailyTasks = taskProvider.tasks
                                  .where((task) => task.isDaily)
                                  .toList();

                              if (dailyTasks.isEmpty) {
                                return _buildEmptyTasksState(
                                  'No daily tasks yet',
                                  'Add daily tasks to build consistent habits and maintain your streak.',
                                  Icons.repeat,
                                );
                              }

                              final task = dailyTasks[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 4.0,
                                ),
                                child: FutureBuilder<bool>(
                                  future: taskProvider
                                      .isTaskCompletedToday(task.id),
                                  builder: (context, snapshot) {
                                    final isCompleted = snapshot.data ?? false;

                                    return TaskCard(
                                      task: task,
                                      isCompleted: isCompleted,
                                      onMarkComplete: () async {
                                        try {
                                          await taskProvider
                                              .markTaskComplete(task.id);
                                          setState(
                                              () {}); // Refresh to update counts
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Task already completed today'),
                                                backgroundColor: AppTheme
                                                    .mediumDarkGreenStreak,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: taskProvider.tasks
                                    .where((task) => task.isDaily)
                                    .isEmpty
                                ? 1
                                : taskProvider.tasks
                                    .where((task) => task.isDaily)
                                    .length,
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),

                        // Category sections
                        ...categories.map((category) {
                          final categoryTasks = _getTasksByCategory(
                            taskProvider.tasks
                                .where((task) => !task.isDaily)
                                .toList(),
                            category,
                          );

                          if (categoryTasks.isEmpty)
                            return const SliverToBoxAdapter();

                          return SliverList(
                            delegate: SliverChildListDelegate([
                              // Category header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.veryDarkGreenStreak,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Category tasks
                              ...categoryTasks.map((task) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 4.0,
                                    ),
                                    child: FutureBuilder<bool>(
                                      future: taskProvider
                                          .isTaskCompletedToday(task.id),
                                      builder: (context, snapshot) {
                                        final isCompleted =
                                            snapshot.data ?? false;

                                        return TaskCard(
                                          task: task,
                                          isCompleted: isCompleted,
                                          onMarkComplete: () async {
                                            try {
                                              await taskProvider
                                                  .markTaskComplete(task.id);
                                              setState(
                                                  () {}); // Refresh to update counts
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Failed to mark task complete'),
                                                    backgroundColor:
                                                        Colors.red.shade600,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  )),
                              const SizedBox(height: 16),
                            ]),
                          );
                        }),

                        // Other tasks (no category)
                        SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 8),
                            ..._getTasksByCategory(
                              taskProvider.tasks
                                  .where((task) => !task.isDaily)
                                  .toList(),
                              null,
                            ).map((task) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                  child: FutureBuilder<bool>(
                                    future: taskProvider
                                        .isTaskCompletedToday(task.id),
                                    builder: (context, snapshot) {
                                      final isCompleted =
                                          snapshot.data ?? false;

                                      return TaskCard(
                                        task: task,
                                        isCompleted: isCompleted,
                                        onMarkComplete: () async {
                                          try {
                                            await taskProvider
                                                .markTaskComplete(task.id);
                                            setState(
                                                () {}); // Refresh to update counts
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Task already completed today'),
                                                  backgroundColor: AppTheme
                                                      .mediumDarkGreenStreak,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                )),
                          ]),
                        ),
                      ],
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.mediumDarkGreenStreak,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
