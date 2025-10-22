import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';

/// Test helper class for NotificationService
class NotificationServiceTest {
  final NotificationService _notificationService = NotificationService();
  final DatabaseService _databaseService = DatabaseService();

  /// Run all notification tests
  Future<void> runAllTests() async {
    debugPrint('\n🧪 ========================================');
    debugPrint('🧪 Starting Notification Service Tests');
    debugPrint('🧪 ========================================\n');

    await _testInitialization();
    await _testPermissions();
    await _testImmediateNotification();
    await _testScheduleNotification();
    await _testCancelNotification();
    await _testGetPendingNotifications();
    await _testRescheduleAllNotifications();

    debugPrint('\n✅ ========================================');
    debugPrint('✅ All Notification Tests Completed');
    debugPrint('✅ ========================================\n');
  }

  /// Test 1: Initialization
  Future<void> _testInitialization() async {
    debugPrint('Test 1: Initialization');
    final success = await _notificationService.initialize();
    debugPrint(
        success ? '✅ Initialization successful' : '❌ Initialization failed');
    debugPrint('---\n');
  }

  /// Test 2: Request Permissions
  Future<void> _testPermissions() async {
    debugPrint('Test 2: Request Permissions');
    final granted = await _notificationService.requestPermissions();
    debugPrint(granted
        ? '✅ Permissions granted'
        : '⚠️ Permissions denied (may need manual approval)');
    debugPrint('---\n');
  }

  /// Test 3: Show Immediate Notification
  Future<void> _testImmediateNotification() async {
    debugPrint('Test 3: Show Immediate Notification');
    final success = await _notificationService.showImmediateNotification(
      id: 999,
      title: '🧪 Test Notification',
      body: 'This is a test notification. It should appear immediately!',
    );
    debugPrint(success
        ? '✅ Immediate notification sent'
        : '❌ Failed to send immediate notification');
    debugPrint('---\n');
  }

  /// Test 4: Schedule a Notification
  Future<void> _testScheduleNotification() async {
    debugPrint('Test 4: Schedule a Notification');

    // Create a test task scheduled for 1 minute from now
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 1));

    final testTask = Task(
      id: 1,
      title: '🧪 Test Task - 1 Min',
      description: 'This notification should appear in 1 minute',
      reminderTime: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
      isActive: true,
      createdAt: now,
    );

    final success = await _notificationService.scheduleNotification(testTask);
    debugPrint(success
        ? '✅ Notification scheduled for ${testTask.getFormattedTime()}'
        : '❌ Failed to schedule notification');
    debugPrint('---\n');
  }

  /// Test 5: Cancel a Notification
  Future<void> _testCancelNotification() async {
    debugPrint('Test 5: Cancel a Notification');

    // Schedule first
    final testTask = Task(
      id: 2,
      title: '🧪 Test Task - To Cancel',
      description: 'This will be cancelled',
      reminderTime: const TimeOfDay(hour: 10, minute: 0),
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _notificationService.scheduleNotification(testTask);
    debugPrint('   Scheduled notification for Task #${testTask.id}');

    // Then cancel
    final success = await _notificationService.cancelNotification(testTask.id!);
    debugPrint(success
        ? '✅ Notification cancelled successfully'
        : '❌ Failed to cancel notification');
    debugPrint('---\n');
  }

  /// Test 6: Get Pending Notifications
  Future<void> _testGetPendingNotifications() async {
    debugPrint('Test 6: Get Pending Notifications');

    final pending = await _notificationService.getPendingNotifications();
    debugPrint('✅ Found ${pending.length} pending notifications');

    for (final notification in pending) {
      debugPrint('   - ID: ${notification.id}, Title: ${notification.title}');
    }
    debugPrint('---\n');
  }

  /// Test 7: Reschedule All Notifications
  Future<void> _testRescheduleAllNotifications() async {
    debugPrint('Test 7: Reschedule All Notifications');

    // Create some test tasks in the database
    final tasks = [
      Task(
        title: 'Morning Exercise',
        description: 'Start your day with a workout',
        reminderTime: const TimeOfDay(hour: 7, minute: 0),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Task(
        title: 'Lunch Break',
        description: 'Time to eat!',
        reminderTime: const TimeOfDay(hour: 12, minute: 30),
        isActive: true,
        createdAt: DateTime.now(),
      ),
      Task(
        title: 'Evening Reading',
        description: 'Read for 30 minutes',
        reminderTime: const TimeOfDay(hour: 20, minute: 0),
        isActive: false, // This one is inactive
        createdAt: DateTime.now(),
      ),
    ];

    // Insert tasks into database
    final insertedTasks = <Task>[];
    for (final task in tasks) {
      final id = await _databaseService.insertTask(task);
      if (id != null) {
        insertedTasks.add(task.copyWith(id: id));
      }
    }

    // Reschedule all
    final success =
        await _notificationService.rescheduleAllNotifications(insertedTasks);
    debugPrint(success
        ? '✅ All active tasks rescheduled'
        : '❌ Failed to reschedule tasks');

    // Check pending notifications
    final pending = await _notificationService.getPendingNotifications();
    debugPrint('   Total pending notifications: ${pending.length}');
    debugPrint('   Expected: 2 (only active tasks)');
    debugPrint('---\n');
  }

  /// Quick test: Show notification in 10 seconds
  Future<void> quickTest10Seconds() async {
    debugPrint('\n⚡ Quick Test: Notification in 10 seconds');

    await _notificationService.initialize();
    await _notificationService.requestPermissions();

    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 10));

    final testTask = Task(
      id: 100,
      title: '⚡ Quick Test',
      description: 'This should appear in 10 seconds!',
      reminderTime: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
      isActive: true,
      createdAt: now,
    );

    await _notificationService.scheduleNotification(testTask);
    debugPrint('✅ Notification scheduled for 10 seconds from now');
    debugPrint('   Wait and watch for the notification...\n');
  }
}
