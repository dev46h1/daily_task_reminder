import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/alarm_manager_service.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all services
  final notificationService = NotificationService();
  final alarmManagerService = AlarmManagerService();

  await notificationService.initialize();
  await alarmManagerService.initialize();

  // Register background tasks
  await alarmManagerService.registerPeriodicCheck();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Task Reminder - Testing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ComprehensiveTestScreen(),
    );
  }
}

class ComprehensiveTestScreen extends StatefulWidget {
  const ComprehensiveTestScreen({super.key});

  @override
  State<ComprehensiveTestScreen> createState() =>
      _ComprehensiveTestScreenState();
}

class _ComprehensiveTestScreenState extends State<ComprehensiveTestScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  final AlarmManagerService _alarmManager = AlarmManagerService();
  final DatabaseService _databaseService = DatabaseService();

  List<String> _logs = [];
  Map<String, dynamic> _statistics = {};
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _updateStatistics();
    _addLog('✅ All services initialized');
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = TimeOfDay.now().format(context);
      _logs.insert(0, '$timestamp: $message');
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  Future<void> _updateStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _alarmManager.getAlarmStatistics();
      setState(() => _statistics = stats);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === Notification Tests ===

  Future<void> _testImmediateNotification() async {
    final success = await _notificationService.showImmediateNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Test Notification',
      body: 'Immediate test notification',
    );
    _addLog(success ? '✅ Immediate notification sent' : '❌ Failed');
    await _updateStatistics();
  }

  Future<void> _testSchedule10Seconds() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(seconds: 10));

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Test Alarm (10s)',
      description: 'This alarm was scheduled 10 seconds ago',
      reminderTime: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
      isActive: true,
    );

    final success = await _alarmManager.scheduleExactAlarm(task);
    _addLog(success ? '✅ Alarm scheduled for 10 seconds' : '❌ Failed');
    await _updateStatistics();
  }

  Future<void> _testSchedule1Minute() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 1));

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Test Alarm (1min)',
      description: 'This alarm was scheduled 1 minute ago',
      reminderTime: TimeOfDay(hour: testTime.hour, minute: testTime.minute),
      isActive: true,
    );

    final success = await _alarmManager.scheduleExactAlarm(task);
    _addLog(success ? '✅ Alarm scheduled for 1 minute' : '❌ Failed');
    await _updateStatistics();
  }

  Future<void> _testDailyTask() async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Daily Morning Exercise',
      description: 'Time for your workout!',
      reminderTime: const TimeOfDay(hour: 7, minute: 0),
      isActive: true,
    );

    final success = await _alarmManager.scheduleExactAlarm(task);
    _addLog(success ? '✅ Daily task scheduled for 7:00 AM' : '❌ Failed');
    await _updateStatistics();
  }

  // === Alarm Manager Tests ===

  Future<void> _testRescheduleAll() async {
    final success = await _alarmManager.rescheduleAllNow();
    _addLog(success ? '✅ All alarms rescheduled' : '❌ Reschedule failed');
    await _updateStatistics();
  }

  Future<void> _testPeriodicCheck() async {
    final success = await _alarmManager.registerPeriodicCheck();
    _addLog(success ? '✅ Periodic check registered (6 hours)' : '❌ Failed');
  }

  Future<void> _testBootTask() async {
    final success = await _alarmManager.scheduleBootTask();
    _addLog(success ? '✅ Boot reschedule task registered' : '❌ Failed');
  }

  Future<void> _testTimezoneChange() async {
    final success = await _alarmManager.handleTimezoneChange();
    _addLog(success ? '✅ Timezone change handled' : '❌ Failed');
    await _updateStatistics();
  }

  Future<void> _testAlarmReliability() async {
    _addLog('🧪 Running alarm reliability test...');
    await _alarmManager.testAlarmReliability();
    _addLog('✅ Reliability test complete (check console)');
    await _updateStatistics();
  }

  // === View/Cancel Operations ===

  Future<void> _viewPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    _addLog('📋 Pending notifications: ${pending.length}');
    for (final notification in pending.take(5)) {
      _addLog('  - ${notification.title} (ID: ${notification.id})');
    }
    if (pending.length > 5) {
      _addLog('  ... and ${pending.length - 5} more');
    }
  }

  Future<void> _cancelAllNotifications() async {
    final success = await _notificationService.cancelAllNotifications();
    _addLog(success ? '🗑️ All notifications cancelled' : '❌ Failed');
    await _updateStatistics();
  }

  Future<void> _cancelBackgroundTasks() async {
    final success = await _alarmManager.cancelAllBackgroundTasks();
    _addLog(success ? '🗑️ Background tasks cancelled' : '❌ Failed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Manager Test Suite'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.science), text: 'Tests'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
            Tab(icon: Icon(Icons.list), text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTestTab(),
          _buildStatisticsTab(),
          _buildLogsTab(),
        ],
      ),
    );
  }

  Widget _buildTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            'Quick Notification Tests',
            Icons.notifications_active,
            Colors.blue,
            [
              _buildTestButton(
                'Immediate',
                Icons.flash_on,
                _testImmediateNotification,
              ),
              _buildTestButton(
                '10 Seconds',
                Icons.timer,
                _testSchedule10Seconds,
              ),
              _buildTestButton(
                '1 Minute',
                Icons.schedule,
                _testSchedule1Minute,
              ),
              _buildTestButton(
                'Daily 7AM',
                Icons.wb_sunny,
                _testDailyTask,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Alarm Manager Tests',
            Icons.alarm,
            Colors.orange,
            [
              _buildTestButton(
                'Reschedule All',
                Icons.refresh,
                _testRescheduleAll,
              ),
              _buildTestButton(
                'Register Periodic Check',
                Icons.loop,
                _testPeriodicCheck,
              ),
              _buildTestButton(
                'Register Boot Task',
                Icons.restart_alt,
                _testBootTask,
              ),
              _buildTestButton(
                'Test Timezone Change',
                Icons.language,
                _testTimezoneChange,
              ),
              _buildTestButton(
                'Alarm Reliability Test',
                Icons.verified,
                _testAlarmReliability,
                isPrimary: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'View & Cancel',
            Icons.manage_search,
            Colors.green,
            [
              _buildTestButton(
                'View Pending',
                Icons.list,
                _viewPendingNotifications,
              ),
              _buildTestButton(
                'Cancel All Notifications',
                Icons.delete_sweep,
                _cancelAllNotifications,
                isDanger: true,
              ),
              _buildTestButton(
                'Cancel Background Tasks',
                Icons.block,
                _cancelBackgroundTasks,
                isDanger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger
              ? Colors.red.shade100
              : isPrimary
                  ? Colors.purple.shade100
                  : null,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return RefreshIndicator(
      onRefresh: _updateStatistics,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'System Statistics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (_statistics.containsKey('error'))
                          Text(
                            'Error: ${_statistics['error']}',
                            style: const TextStyle(color: Colors.red),
                          )
                        else
                          ..._buildStatItems(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'How It Works',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• flutter_local_notifications schedules exact alarms\n'
                          '• WorkManager checks every 6 hours for reliability\n'
                          '• Boot receiver reschedules after device restart\n'
                          '• All alarms survive app closure and device restart',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildStatItems() {
    return [
      _buildStatItem(
        'Total Tasks',
        _statistics['totalTasks']?.toString() ?? '0',
        Icons.task,
        Colors.blue,
      ),
      _buildStatItem(
        'Active Tasks',
        _statistics['activeTasks']?.toString() ?? '0',
        Icons.check_circle,
        Colors.green,
      ),
      _buildStatItem(
        'Pending Notifications',
        _statistics['pendingNotifications']?.toString() ?? '0',
        Icons.notifications,
        Colors.orange,
      ),
      _buildStatItem(
        'Alarm Accuracy',
        _statistics['alarmAccuracy'] ?? '0%',
        Icons.verified,
        Colors.purple,
      ),
      _buildStatItem(
        'Last Check',
        _statistics['lastCheckDate'] ?? 'Never',
        Icons.history,
        Colors.grey,
        isLarge: true,
      ),
    ];
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 14 : 18,
                    fontWeight: isLarge ? FontWeight.normal : FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity Log',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_logs.length} entries',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _logs.clear());
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No activity yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Run tests to see logs here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final isError = log.contains('❌');
                    final isSuccess = log.contains('✅');
                    final isWarning = log.contains('⚠️');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isError
                          ? Colors.red.shade50
                          : isSuccess
                              ? Colors.green.shade50
                              : isWarning
                                  ? Colors.orange.shade50
                                  : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: isError
                                ? Colors.red.shade900
                                : isSuccess
                                    ? Colors.green.shade900
                                    : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
