import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/task.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set local timezone (you can make this dynamic if needed)
      // For now using UTC, but you should set it to device timezone
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      // Initialize plugin
      final bool? result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result == true) {
        // Create notification channel for Android 8.0+
        await _createNotificationChannel();
        _isInitialized = true;
        debugPrint('✅ Notification service initialized successfully');
        return true;
      }

      debugPrint('❌ Notification initialization returned false');
      return false;
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
      return false;
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_tasks_channel', // Channel ID
      'Daily Task Reminders', // Channel name
      description: 'Notifications for daily task reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('✅ Notification channel created');
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        debugPrint(
            '📱 Notification permission: ${granted == true ? "Granted" : "Denied"}');
        return granted ?? false;
      }

      return true; // For older Android versions
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Schedule a daily notification for a task
  Future<bool> scheduleNotification(Task task) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Notification service not initialized');
      await initialize();
    }

    try {
      // Cancel any existing notification for this task
      await cancelNotification(task.id!);

      // Calculate the scheduled time for today
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        task.reminderTime.hour,
        task.reminderTime.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      final scheduledTime = scheduledDate.isBefore(now)
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;

      // Convert to TZDateTime
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Configure notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_tasks_channel',
        'Daily Task Reminders',
        channelDescription: 'Notifications for daily task reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Schedule the notification to repeat daily
      await _notifications.zonedSchedule(
        task.id!, // Notification ID
        task.title, // Notification title
        task.description.isEmpty
            ? 'Daily reminder for your task'
            : task.description, // Notification body
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Repeat daily at same time
      );

      debugPrint(
          '✅ Notification scheduled for Task #${task.id}: ${task.title}');
      debugPrint('   Time: ${task.getFormattedTime()}');
      debugPrint('   Next trigger: $tzScheduledTime');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling notification for Task #${task.id}: $e');
      return false;
    }
  }

  /// Cancel a scheduled notification
  Future<bool> cancelNotification(int taskId) async {
    try {
      await _notifications.cancel(taskId);
      debugPrint('🗑️ Notification cancelled for Task #$taskId');
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling notification for Task #$taskId: $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🗑️ All notifications cancelled');
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
      return false;
    }
  }

  /// Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _notifications.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pendingNotifications.length}');
      return pendingNotifications;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;
    debugPrint('🔔 Notification tapped: $payload');

    // TODO: Navigate to specific task or home screen
    // This will be implemented when we create the UI
    // You can add navigation logic here using a GlobalKey<NavigatorState>
  }

  /// Show an immediate notification (for testing)
  Future<bool> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_tasks_channel',
        'Daily Task Reminders',
        channelDescription: 'Notifications for daily task reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
      );

      debugPrint('✅ Immediate notification shown');
      return true;
    } catch (e) {
      debugPrint('❌ Error showing immediate notification: $e');
      return false;
    }
  }

  /// Reschedule all notifications (useful after device restart)
  Future<bool> rescheduleAllNotifications(List<Task> tasks) async {
    try {
      // Cancel all existing notifications first
      await cancelAllNotifications();

      // Schedule notifications for all active tasks
      int successCount = 0;
      for (final task in tasks) {
        if (task.isActive) {
          final success = await scheduleNotification(task);
          if (success) successCount++;
        }
      }

      debugPrint('✅ Rescheduled $successCount/${tasks.length} notifications');
      return true;
    } catch (e) {
      debugPrint('❌ Error rescheduling notifications: $e');
      return false;
    }
  }
}
