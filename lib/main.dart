import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/alarm_manager_service.dart';
// Import for Task model
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final notificationService = NotificationService();
  final alarmManagerService = AlarmManagerService();

  await notificationService.initialize();
  await alarmManagerService.initialize();
  await alarmManagerService.registerPeriodicCheck();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..initialize(),
      child: MaterialApp(
        title: 'Daily Task Reminder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ProviderTestScreen(),
      ),
    );
  }
}

class ProviderTestScreen extends StatefulWidget {
  const ProviderTestScreen({super.key});

  @override
  State<ProviderTestScreen> createState() => _ProviderTestScreenState();
}

class _ProviderTestScreenState extends State<ProviderTestScreen> {
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      final timestamp = TimeOfDay.now().format(context);
      _logs.insert(0, '$timestamp: $message');
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskProvider Test Suite'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskProvider>().refresh();
              _addLog('🔄 Tasks refreshed');
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Statistics Card
              _buildStatisticsCard(provider),

              // Test Buttons
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSection(
                        'Quick Actions',
                        Icons.flash_on,
                        Colors.blue,
                        [
                          _buildTestButton(
                            'Create Sample Tasks',
                            Icons.add_circle,
                            () => _createSampleTasks(provider),
                          ),
                          _buildTestButton(
                            'Add Random Task',
                            Icons.add,
                            () => _addRandomTask(provider),
                          ),
                          _buildTestButton(
                            'Toggle First Task',
                            Icons.toggle_on,
                            () => _toggleFirstTask(provider),
                          ),
                          _buildTestButton(
                            'Delete Last Task',
                            Icons.delete,
                            () => _deleteLastTask(provider),
                            isDanger: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        'Task List',
                        Icons.list,
                        Colors.green,
                        [
                          _buildTaskList(provider),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        'Activity Logs',
                        Icons.history,
                        Colors.orange,
                        [
                          _buildLogsList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildStatisticsCard(TaskProvider provider) {
    final stats = provider.getStatistics();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  stats['totalTasks'].toString(),
                  Colors.blue,
                ),
                _buildStatItem(
                  'Active',
                  stats['activeTasks'].toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'Inactive',
                  stats['inactiveTasks'].toString(),
                  Colors.orange,
                ),
                _buildStatItem(
                  'Upcoming',
                  stats['upcomingToday'].toString(),
                  Colors.purple,
                ),
              ],
            ),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(),
              ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger ? Colors.red.shade100 : null,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    if (provider.tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No tasks yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: provider.sortedTasks.map((task) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: task.isActive ? null : Colors.grey.shade100,
          child: ListTile(
            leading: Icon(
              task.isActive ? Icons.check_circle : Icons.cancel,
              color: task.isActive ? Colors.green : Colors.grey,
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isActive ? null : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${task.getFormattedTime()} - ${task.description}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditTaskDialog(context, task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteTask(provider, task.id!),
                ),
              ],
            ),
            onTap: () {
              provider.toggleTaskActive(task.id!);
              _addLog(
                  '${task.isActive ? "Deactivated" : "Activated"}: ${task.title}');
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogsList() {
    if (_logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No activity yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              log,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          );
        },
      ),
    );
  }

  // Action Methods

  Future<void> _createSampleTasks(TaskProvider provider) async {
    _addLog('📝 Creating sample tasks...');

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
      await provider.addTask(task);
    }

    _addLog('✅ Created ${sampleTasks.length} sample tasks');
  }

  Future<void> _addRandomTask(TaskProvider provider) async {
    final random = DateTime.now().millisecondsSinceEpoch % 24;
    final task = Task(
      title: 'Random Task ${DateTime.now().millisecond}',
      description: 'This is a randomly generated task',
      reminderTime: TimeOfDay(hour: random, minute: 0),
      isActive: true,
    );

    final success = await provider.addTask(task);
    _addLog(success ? '✅ Random task added' : '❌ Failed to add task');
  }

  Future<void> _toggleFirstTask(TaskProvider provider) async {
    if (provider.tasks.isEmpty) {
      _addLog('⚠️ No tasks to toggle');
      return;
    }

    final task = provider.tasks.first;
    await provider.toggleTaskActive(task.id!);
    _addLog('🔄 Toggled: ${task.title}');
  }

  Future<void> _deleteLastTask(TaskProvider provider) async {
    if (provider.tasks.isEmpty) {
      _addLog('⚠️ No tasks to delete');
      return;
    }

    final task = provider.tasks.last;
    final success = await provider.deleteTask(task.id!);
    _addLog(success ? '🗑️ Deleted: ${task.title}' : '❌ Failed to delete');
  }

  Future<void> _deleteTask(TaskProvider provider, int taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final task = provider.getTaskById(taskId);
      final success = await provider.deleteTask(taskId);
      _addLog(success ? '🗑️ Deleted: ${task?.title}' : '❌ Failed to delete');
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                final task = Task(
                  title: titleController.text,
                  description: descController.text,
                  reminderTime: selectedTime,
                  isActive: true,
                );

                final provider = context.read<TaskProvider>();
                final success = await provider.addTask(task);

                if (success && context.mounted) {
                  Navigator.pop(context);
                  _addLog('✅ Added: ${task.title}');
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    TimeOfDay selectedTime = task.reminderTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                final updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descController.text,
                  reminderTime: selectedTime,
                );

                final provider = context.read<TaskProvider>();
                final success = await provider.updateTask(updatedTask);

                if (success && context.mounted) {
                  Navigator.pop(context);
                  _addLog('✅ Updated: ${updatedTask.title}');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
