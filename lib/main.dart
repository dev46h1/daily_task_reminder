import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Task Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationTestScreen(),
    );
  }
}

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  final DatabaseService _databaseService = DatabaseService();
  List<String> _logs = [];
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();
    await _updatePendingCount();
    _addLog('✅ Notification service initialized');
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${TimeOfDay.now().format(context)}: $message');
      if (_logs.length > 20) _logs.removeLast();
    });
  }

  Future<void> _updatePendingCount() async {
    final pending = await _notificationService.getPendingNotifications();
    setState(() {
      _pendingCount = pending.length;
    });
  }

  Future<void> _requestPermissions() async {
    final granted = await _notificationService.requestPermissions();
    _addLog(granted ? '✅ Permissions granted' : '❌ Permissions denied');
  }

  Future<void> _showImmediateNotification() async {
    final success = await _notificationService.showImmediateNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Test Notification',
      body: 'This is an immediate test notification',
    );
    _addLog(success
        ? '✅ Immediate notification sent'
        : '❌ Failed to send notification');
  }

  Future<void> _scheduleIn10Seconds() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 10));

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Test Reminder (10s)',
      description: 'This notification was scheduled 10 seconds ago',
      reminderTime: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
      isActive: true,
      createdAt: now,
    );

    final success = await _notificationService.scheduleNotification(task);
    _addLog(success
        ? '✅ Notification scheduled for 10 seconds'
        : '❌ Failed to schedule');
    await _updatePendingCount();
  }

  Future<void> _scheduleIn1Minute() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 1));

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Test Reminder (1min)',
      description: 'This notification was scheduled 1 minute ago',
      reminderTime: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
      isActive: true,
      createdAt: now,
    );

    final success = await _notificationService.scheduleNotification(task);
    _addLog(success
        ? '✅ Notification scheduled for 1 minute'
        : '❌ Failed to schedule');
    await _updatePendingCount();
  }

  Future<void> _scheduleDailyTask() async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Daily Morning Exercise',
      description: 'Time for your morning workout!',
      reminderTime: const TimeOfDay(hour: 7, minute: 0),
      isActive: true,
      createdAt: DateTime.now(),
    );

    final success = await _notificationService.scheduleNotification(task);
    _addLog(success
        ? '✅ Daily task scheduled for 7:00 AM'
        : '❌ Failed to schedule');
    await _updatePendingCount();
  }

  Future<void> _viewPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();

    if (pending.isEmpty) {
      _addLog('📋 No pending notifications');
      return;
    }

    _addLog('📋 Pending notifications: ${pending.length}');
    for (final notification in pending) {
      _addLog('  - ${notification.title} (ID: ${notification.id})');
    }
    await _updatePendingCount();
  }

  Future<void> _cancelAllNotifications() async {
    final success = await _notificationService.cancelAllNotifications();
    _addLog(success ? '🗑️ All notifications cancelled' : '❌ Failed to cancel');
    await _updatePendingCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Service Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('Pending: $_pendingCount'),
                backgroundColor: Colors.orange.shade100,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Request Permissions'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showImmediateNotification,
                        child: const Text('Immediate'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _scheduleIn10Seconds,
                        child: const Text('10 Seconds'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _scheduleIn1Minute,
                        child: const Text('1 Minute'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _scheduleDailyTask,
                        child: const Text('Daily 7AM'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _viewPendingNotifications,
                        icon: const Icon(Icons.list),
                        label: const Text('View Pending'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _cancelAllNotifications,
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Cancel All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Logs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          // Log List
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      'No activity yet.\nTap a button above to test notifications.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
