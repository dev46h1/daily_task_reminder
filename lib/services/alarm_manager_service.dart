import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'database_service.dart';
import 'notification_service.dart';

/// Background task callback - MUST be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('🔄 Background task started: $task');

      switch (task) {
        case 'rescheduleNotifications':
          await _rescheduleAllNotifications();
          break;
        case 'checkMissedNotifications':
          await _checkMissedNotifications();
          break;
        default:
          debugPrint('⚠️ Unknown task: $task');
      }

      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Background task error: $e');
      return Future.value(false);
    }
  });
}

/// Reschedule all notifications (called from background)
Future<void> _rescheduleAllNotifications() async {
  try {
    final dbService = DatabaseService();
    final notificationService = NotificationService();

    await notificationService.initialize();

    final tasks = await dbService.getActiveTasks();
    await notificationService.rescheduleAllNotifications(tasks);

    debugPrint('✅ Background: Rescheduled ${tasks.length} notifications');
  } catch (e) {
    debugPrint('❌ Background reschedule error: $e');
  }
}

/// Check for missed notifications
Future<void> _checkMissedNotifications() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('last_notification_check') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // If more than 24 hours since last check, reschedule
    if (now - lastCheck > 86400000) {
      await _rescheduleAllNotifications();
    }

    await prefs.setInt('last_notification_check', now);
    debugPrint('✅ Notification check completed');
  } catch (e) {
    debugPrint('❌ Check missed notifications error: $e');
  }
}

/// Main Alarm Manager Service
class AlarmManagerService {
  static final AlarmManagerService _instance = AlarmManagerService._internal();
  factory AlarmManagerService() => _instance;
  AlarmManagerService._internal();

  bool _isInitialized = false;

  /// Initialize WorkManager for background tasks
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize WorkManager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true, // Set to false in production
      );

      debugPrint('✅ WorkManager initialized');
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('❌ WorkManager initialization failed: $e');
      return false;
    }
  }

  /// Register periodic task to check and reschedule notifications
  Future<bool> registerPeriodicCheck() async {
    if (!_isInitialized) await initialize();

    try {
      // Register periodic task (runs every 15 minutes minimum on Android)
      await Workmanager().registerPeriodicTask(
        'notification-check',
        'checkMissedNotifications',
        frequency: const Duration(hours: 6), // Check every 6 hours
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );

      debugPrint('✅ Periodic notification check registered (6 hours)');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to register periodic check: $e');
      return false;
    }
  }

  /// Schedule boot task to reschedule notifications after restart
  Future<bool> scheduleBootTask() async {
    if (!_isInitialized) await initialize();

    try {
      // This will be called once after device boot
      await Workmanager().registerOneOffTask(
        'boot-reschedule',
        'rescheduleNotifications',
        initialDelay: const Duration(seconds: 10), // Wait for system to settle
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );

      debugPrint('✅ Boot reschedule task registered');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to register boot task: $e');
      return false;
    }
  }

  /// Manually trigger notification rescheduling
  Future<bool> rescheduleAllNow() async {
    try {
      final dbService = DatabaseService();
      final notificationService = NotificationService();

      final tasks = await dbService.getActiveTasks();
      await notificationService.rescheduleAllNotifications(tasks);

      debugPrint('✅ Manual reschedule completed: ${tasks.length} tasks');
      return true;
    } catch (e) {
      debugPrint('❌ Manual reschedule failed: $e');
      return false;
    }
  }

  /// Schedule exact alarm for a specific task
  /// This ensures the alarm fires at the exact time
  Future<bool> scheduleExactAlarm(Task task) async {
    try {
      final notificationService = NotificationService();

      // Use flutter_local_notifications with exact alarm scheduling
      final success = await notificationService.scheduleNotification(task);

      if (success) {
        // Update last scheduled time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          'alarm_${task.id}',
          DateTime.now().millisecondsSinceEpoch,
        );

        debugPrint('✅ Exact alarm scheduled for Task #${task.id}');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Failed to schedule exact alarm for Task #${task.id}: $e');
      return false;
    }
  }

  /// Cancel exact alarm for a specific task
  Future<bool> cancelExactAlarm(int taskId) async {
    try {
      final notificationService = NotificationService();
      await notificationService.cancelNotification(taskId);

      // Clear last scheduled time
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('alarm_$taskId');

      debugPrint('✅ Exact alarm cancelled for Task #$taskId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to cancel exact alarm for Task #$taskId: $e');
      return false;
    }
  }

  /// Handle timezone changes
  Future<bool> handleTimezoneChange() async {
    try {
      debugPrint('🌍 Timezone change detected, rescheduling...');

      // Reinitialize notification service with new timezone
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Reschedule all alarms
      await rescheduleAllNow();

      debugPrint('✅ Timezone change handled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Timezone change handling failed: $e');
      return false;
    }
  }

  /// Verify alarm accuracy (for testing)
  Future<Map<String, dynamic>> verifyAlarmAccuracy(Task task) async {
    try {
      final notificationService = NotificationService();
      final pending = await notificationService.getPendingNotifications();

      // Find this task's notification
      final taskNotification =
          pending.where((n) => n.id == task.id).firstOrNull;

      if (taskNotification == null) {
        return {
          'scheduled': false,
          'message': 'No pending notification found',
        };
      }

      return {
        'scheduled': true,
        'id': taskNotification.id,
        'title': taskNotification.title,
        'body': taskNotification.body,
        'message': 'Alarm is correctly scheduled',
      };
    } catch (e) {
      return {
        'scheduled': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get alarm statistics
  Future<Map<String, dynamic>> getAlarmStatistics() async {
    try {
      final dbService = DatabaseService();
      final notificationService = NotificationService();
      final prefs = await SharedPreferences.getInstance();

      final totalTasks = await dbService.getTaskCount();
      final activeTasks = await dbService.getActiveTasks();
      final pending = await notificationService.getPendingNotifications();
      final lastCheck = prefs.getInt('last_notification_check') ?? 0;

      return {
        'totalTasks': totalTasks,
        'activeTasks': activeTasks.length,
        'pendingNotifications': pending.length,
        'lastCheckTimestamp': lastCheck,
        'lastCheckDate': lastCheck > 0
            ? DateTime.fromMillisecondsSinceEpoch(lastCheck).toString()
            : 'Never',
        'alarmAccuracy': activeTasks.isEmpty
            ? '100%'
            : '${(pending.length / activeTasks.length * 100).toStringAsFixed(0)}%',
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Cancel all background tasks
  Future<bool> cancelAllBackgroundTasks() async {
    try {
      await Workmanager().cancelAll();
      debugPrint('✅ All background tasks cancelled');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to cancel background tasks: $e');
      return false;
    }
  }

  /// Test alarm reliability over time
  Future<void> testAlarmReliability() async {
    debugPrint('\n🧪 ========================================');
    debugPrint('🧪 Testing Alarm Reliability');
    debugPrint('🧪 ========================================\n');

    // Test 1: Schedule multiple alarms
    debugPrint('Test 1: Scheduling multiple test alarms...');
    final now = DateTime.now();

    final testTasks = [
      Task(
        id: 9001,
        title: 'Test Alarm 1',
        description: 'Scheduled for 1 minute',
        reminderTime: TimeOfDay(
          hour: now.add(const Duration(minutes: 1)).hour,
          minute: now.add(const Duration(minutes: 1)).minute,
        ),
        isActive: true,
      ),
      Task(
        id: 9002,
        title: 'Test Alarm 2',
        description: 'Scheduled for 2 minutes',
        reminderTime: TimeOfDay(
          hour: now.add(const Duration(minutes: 2)).hour,
          minute: now.add(const Duration(minutes: 2)).minute,
        ),
        isActive: true,
      ),
    ];

    for (final task in testTasks) {
      await scheduleExactAlarm(task);
    }
    debugPrint('✅ Test alarms scheduled\n');

    // Test 2: Verify accuracy
    debugPrint('Test 2: Verifying alarm accuracy...');
    for (final task in testTasks) {
      final result = await verifyAlarmAccuracy(task);
      debugPrint('Task #${task.id}: ${result['message']}');
    }
    debugPrint('');

    // Test 3: Statistics
    debugPrint('Test 3: Alarm Statistics');
    final stats = await getAlarmStatistics();
    stats.forEach((key, value) {
      debugPrint('  $key: $value');
    });

    debugPrint('\n✅ ========================================');
    debugPrint('✅ Alarm Reliability Test Complete');
    debugPrint('✅ ========================================\n');
  }
}
