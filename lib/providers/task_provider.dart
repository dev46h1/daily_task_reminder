import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/alarm_manager_service.dart';

/// Provider for managing task state across the application
class TaskProvider with ChangeNotifier {
  // Services
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final AlarmManagerService _alarmManager = AlarmManagerService();

  // State
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get taskCount => _tasks.length;
  int get activeTaskCount => _tasks.where((t) => t.isActive).length;

  /// Get tasks sorted by reminder time
  List<Task> get sortedTasks {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) {
      final timeA = a.reminderTime.hour * 60 + a.reminderTime.minute;
      final timeB = b.reminderTime.hour * 60 + b.reminderTime.minute;
      return timeA.compareTo(timeB);
    });
    return sorted;
  }

  /// Get only active tasks
  List<Task> get activeTasks {
    return _tasks.where((task) => task.isActive).toList();
  }

  /// Initialize provider and load tasks
  Future<bool> initialize() async {
    try {
      debugPrint('🔄 Initializing TaskProvider...');

      // Initialize services
      await _notificationService.initialize();
      await _alarmManager.initialize();

      // Load tasks from database
      await loadTasks();

      debugPrint('✅ TaskProvider initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to initialize TaskProvider: $e');
      _error = 'Failed to initialize: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load all tasks from database
  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📥 Loading tasks from database...');
      _tasks = await _databaseService.getTasks();
      debugPrint('✅ Loaded ${_tasks.length} tasks');
    } catch (e) {
      debugPrint('❌ Error loading tasks: $e');
      _error = 'Failed to load tasks: $e';
      _tasks = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new task
  Future<bool> addTask(Task task) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('➕ Adding new task: ${task.title}');

      // Insert into database
      final id = await _databaseService.insertTask(task);
      final newTask = task.copyWith(id: id);

      // Schedule notification if task is active
      if (newTask.isActive) {
        await _alarmManager.scheduleExactAlarm(newTask);
      }

      // Update local state
      _tasks.add(newTask);
      debugPrint('✅ Task added successfully with ID: $id');

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Error adding task: $e');
      _error = 'Failed to add task: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing task
  Future<bool> updateTask(Task task) async {
    if (task.id == null) {
      _error = 'Cannot update task without ID';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      debugPrint('✏️ Updating task #${task.id}: ${task.title}');

      // Update in database
      await _databaseService.updateTask(task);

      // Reschedule or cancel notification based on active state
      if (task.isActive) {
        await _alarmManager.scheduleExactAlarm(task);
      } else {
        await _alarmManager.cancelExactAlarm(task.id!);
      }

      // Update local state
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }

      debugPrint('✅ Task updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating task: $e');
      _error = 'Failed to update task: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(int taskId) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🗑️ Deleting task #$taskId');

      // Delete from database
      await _databaseService.deleteTask(taskId);

      // Cancel notification
      await _alarmManager.cancelExactAlarm(taskId);

      // Update local state
      _tasks.removeWhere((task) => task.id == taskId);

      debugPrint('✅ Task deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting task: $e');
      _error = 'Failed to delete task: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Toggle task active state
  Future<bool> toggleTaskActive(int taskId) async {
    final task = _tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );

    final updatedTask = task.copyWith(isActive: !task.isActive);
    return await updateTask(updatedTask);
  }

  /// Get a specific task by ID
  Task? getTaskById(int taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh/reload tasks (useful for pull-to-refresh)
  Future<void> refresh() async {
    debugPrint('🔄 Refreshing tasks...');
    await loadTasks();
  }

  /// Delete all tasks (for testing/reset)
  Future<bool> deleteAllTasks() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🗑️ Deleting all tasks...');

      // Delete from database
      await _databaseService.deleteAllTasks();

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      // Clear local state
      _tasks.clear();

      debugPrint('✅ All tasks deleted');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting all tasks: $e');
      _error = 'Failed to delete all tasks: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Reschedule all notifications (useful after boot or timezone change)
  Future<bool> rescheduleAllNotifications() async {
    try {
      debugPrint('🔄 Rescheduling all notifications...');

      final activeTasks = _tasks.where((t) => t.isActive).toList();

      for (final task in activeTasks) {
        await _alarmManager.scheduleExactAlarm(task);
      }

      debugPrint('✅ Rescheduled ${activeTasks.length} notifications');
      return true;
    } catch (e) {
      debugPrint('❌ Error rescheduling notifications: $e');
      _error = 'Failed to reschedule notifications: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get statistics about tasks
  Map<String, dynamic> getStatistics() {
    return {
      'totalTasks': _tasks.length,
      'activeTasks': activeTasks.length,
      'inactiveTasks': _tasks.length - activeTasks.length,
      'upcomingToday': _getUpcomingTodayCount(),
    };
  }

  /// Count tasks scheduled for upcoming hours today
  int _getUpcomingTodayCount() {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    return activeTasks.where((task) {
      final taskMinutes =
          task.reminderTime.hour * 60 + task.reminderTime.minute;
      return taskMinutes > currentMinutes;
    }).length;
  }

  // Helper methods for state management
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Dispose resources
  @override
  void dispose() {
    debugPrint('🔄 Disposing TaskProvider...');
    super.dispose();
  }
}
