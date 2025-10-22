import 'package:flutter/material.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Comprehensive test suite for TaskProvider
class TaskProviderTest {
  final TaskProvider _provider = TaskProvider();

  /// Run all tests
  Future<void> runAllTests() async {
    debugPrint('\n🧪 ========================================');
    debugPrint('🧪 Starting TaskProvider Tests');
    debugPrint('🧪 ========================================\n');

    await _testInitialization();
    await _testAddTask();
    await _testLoadTasks();
    await _testUpdateTask();
    await _testToggleTaskActive();
    await _testDeleteTask();
    await _testGetTaskById();
    await _testSortedTasks();
    await _testStatistics();
    await _testRefresh();

    debugPrint('\n✅ ========================================');
    debugPrint('✅ All TaskProvider Tests Completed');
    debugPrint('✅ ========================================\n');
  }

  /// Test 1: Initialization
  Future<void> _testInitialization() async {
    debugPrint('Test 1: Provider Initialization');

    final success = await _provider.initialize();

    debugPrint(success
        ? '✅ Provider initialized successfully'
        : '❌ Provider initialization failed');
    debugPrint('   Loading state: ${_provider.isLoading}');
    debugPrint('   Error: ${_provider.error ?? "None"}');
    debugPrint('---\n');
  }

  /// Test 2: Add Task
  Future<void> _testAddTask() async {
    debugPrint('Test 2: Add New Task');

    final testTask = Task(
      title: 'Morning Workout',
      description: 'Exercise for 30 minutes',
      reminderTime: const TimeOfDay(hour: 6, minute: 30),
      isActive: true,
    );

    final beforeCount = _provider.taskCount;
    final success = await _provider.addTask(testTask);

    debugPrint(success ? '✅ Task added successfully' : '❌ Failed to add task');
    debugPrint('   Tasks before: $beforeCount');
    debugPrint('   Tasks after: ${_provider.taskCount}');
    debugPrint('   Active tasks: ${_provider.activeTaskCount}');
    debugPrint('---\n');
  }

  /// Test 3: Load Tasks
  Future<void> _testLoadTasks() async {
    debugPrint('Test 3: Load Tasks');

    await _provider.loadTasks();

    debugPrint('✅ Tasks loaded');
    debugPrint('   Total tasks: ${_provider.taskCount}');
    debugPrint('   Active tasks: ${_provider.activeTaskCount}');

    if (_provider.tasks.isNotEmpty) {
      debugPrint('   First task: ${_provider.tasks.first.title}');
    }
    debugPrint('---\n');
  }

  /// Test 4: Update Task
  Future<void> _testUpdateTask() async {
    debugPrint('Test 4: Update Task');

    if (_provider.tasks.isEmpty) {
      debugPrint('⚠️ No tasks to update, skipping test');
      debugPrint('---\n');
      return;
    }

    final taskToUpdate = _provider.tasks.first;
    final updatedTask = taskToUpdate.copyWith(
      title: '${taskToUpdate.title} (Updated)',
      description: 'This task has been updated',
    );

    final success = await _provider.updateTask(updatedTask);

    debugPrint(
        success ? '✅ Task updated successfully' : '❌ Failed to update task');
    debugPrint('   Original title: ${taskToUpdate.title}');
    debugPrint('   Updated title: ${updatedTask.title}');
    debugPrint('---\n');
  }

  /// Test 5: Toggle Task Active State
  Future<void> _testToggleTaskActive() async {
    debugPrint('Test 5: Toggle Task Active State');

    if (_provider.tasks.isEmpty) {
      debugPrint('⚠️ No tasks to toggle, skipping test');
      debugPrint('---\n');
      return;
    }

    final task = _provider.tasks.first;
    final originalState = task.isActive;

    final success = await _provider.toggleTaskActive(task.id!);

    final updatedTask = _provider.getTaskById(task.id!);

    debugPrint(
        success ? '✅ Task active state toggled' : '❌ Failed to toggle task');
    debugPrint('   Original state: $originalState');
    debugPrint('   New state: ${updatedTask?.isActive}');
    debugPrint('---\n');
  }

  /// Test 6: Delete Task
  Future<void> _testDeleteTask() async {
    debugPrint('Test 6: Delete Task');

    // Add a task to delete
    final testTask = Task(
      title: 'Task to Delete',
      description: 'This will be deleted',
      reminderTime: const TimeOfDay(hour: 12, minute: 0),
      isActive: true,
    );

    await _provider.addTask(testTask);
    final taskId = _provider.tasks.last.id!;
    final beforeCount = _provider.taskCount;

    final success = await _provider.deleteTask(taskId);

    debugPrint(
        success ? '✅ Task deleted successfully' : '❌ Failed to delete task');
    debugPrint('   Tasks before: $beforeCount');
    debugPrint('   Tasks after: ${_provider.taskCount}');
    debugPrint('---\n');
  }

  /// Test 7: Get Task By ID
  Future<void> _testGetTaskById() async {
    debugPrint('Test 7: Get Task By ID');

    if (_provider.tasks.isEmpty) {
      debugPrint('⚠️ No tasks available, skipping test');
      debugPrint('---\n');
      return;
    }

    final existingTask = _provider.tasks.first;
    final foundTask = _provider.getTaskById(existingTask.id!);

    debugPrint(foundTask != null ? '✅ Task found by ID' : '❌ Task not found');

    if (foundTask != null) {
      debugPrint('   Task ID: ${foundTask.id}');
      debugPrint('   Task title: ${foundTask.title}');
    }

    // Test with non-existent ID
    final nonExistent = _provider.getTaskById(99999);
    debugPrint(
        '   Non-existent task: ${nonExistent == null ? "Null (correct)" : "Found (error)"}');
    debugPrint('---\n');
  }

  /// Test 8: Sorted Tasks
  Future<void> _testSortedTasks() async {
    debugPrint('Test 8: Sorted Tasks');

    final sorted = _provider.sortedTasks;

    debugPrint('✅ Tasks sorted by time');
    debugPrint('   Total sorted tasks: ${sorted.length}');

    if (sorted.length >= 2) {
      final first = sorted.first;
      final last = sorted.last;
      debugPrint(
          '   First task: ${first.title} at ${first.getFormattedTime()}');
      debugPrint('   Last task: ${last.title} at ${last.getFormattedTime()}');
    }
    debugPrint('---\n');
  }

  /// Test 9: Statistics
  Future<void> _testStatistics() async {
    debugPrint('Test 9: Provider Statistics');

    final stats = _provider.getStatistics();

    debugPrint('✅ Statistics retrieved');
    stats.forEach((key, value) {
      debugPrint('   $key: $value');
    });
    debugPrint('---\n');
  }

  /// Test 10: Refresh
  Future<void> _testRefresh() async {
    debugPrint('Test 10: Refresh Tasks');

    await _provider.refresh();

    debugPrint('✅ Tasks refreshed');
    debugPrint('   Total tasks after refresh: ${_provider.taskCount}');
    debugPrint('---\n');
  }

  /// Quick Demo: Create Sample Tasks
  Future<void> createSampleTasks() async {
    debugPrint('\n📝 Creating Sample Tasks...\n');

    final sampleTasks = [
      Task(
        title: '🌅 Morning Meditation',
        description: 'Start the day with 10 minutes of meditation',
        reminderTime: const TimeOfDay(hour: 6, minute: 0),
        isActive: true,
      ),
      Task(
        title: '💊 Take Vitamins',
        description: 'Take daily vitamins with breakfast',
        reminderTime: const TimeOfDay(hour: 8, minute: 0),
        isActive: true,
      ),
      Task(
        title: '🥗 Lunch Break',
        description: 'Time for a healthy lunch',
        reminderTime: const TimeOfDay(hour: 12, minute: 30),
        isActive: true,
      ),
      Task(
        title: '🚶 Evening Walk',
        description: 'Walk for 20 minutes',
        reminderTime: const TimeOfDay(hour: 18, minute: 0),
        isActive: true,
      ),
      Task(
        title: '📚 Reading Time',
        description: 'Read for 30 minutes before bed',
        reminderTime: const TimeOfDay(hour: 21, minute: 0),
        isActive: true,
      ),
    ];

    for (final task in sampleTasks) {
      final success = await _provider.addTask(task);
      debugPrint(
          success ? '✅ Created: ${task.title}' : '❌ Failed: ${task.title}');
    }

    debugPrint('\n✅ Sample tasks created: ${_provider.taskCount} tasks\n');
  }
}
