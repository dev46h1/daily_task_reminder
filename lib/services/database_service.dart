import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  // Singleton pattern - ensures only one instance exists
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Get database instance (creates if doesn't exist)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    try {
      // Get the default databases directory
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'daily_tasks.db');

      // Open/create the database
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  // Create tables when database is first created
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          reminder_time TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');
      print('Database table created successfully');
    } catch (e) {
      throw Exception('Failed to create database table: $e');
    }
  }

  // Handle database upgrades (for future versions)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here when database schema changes
    // Example: if (oldVersion < 2) { await db.execute('ALTER TABLE...'); }
  }

  // Insert a new task
  Future<int> insertTask(Task task) async {
    try {
      final db = await database;
      final id = await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Task inserted successfully with id: $id');
      return id;
    } catch (e) {
      throw Exception('Failed to insert task: $e');
    }
  }

  // Get all tasks
  Future<List<Task>> getTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        orderBy: 'reminder_time ASC',
      );

      // Convert List<Map> to List<Task>
      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  // Get a single task by id
  Future<Task?> getTask(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return Task.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get task with id $id: $e');
    }
  }

  // Update an existing task
  Future<int> updateTask(Task task) async {
    try {
      if (task.id == null) {
        throw Exception('Cannot update task without an id');
      }

      final db = await database;
      final count = await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      if (count == 0) {
        throw Exception('Task with id ${task.id} not found');
      }

      print('Task updated successfully: ${task.id}');
      return count;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception('Task with id $id not found');
      }

      print('Task deleted successfully: $id');
      return count;
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get active tasks only
  Future<List<Task>> getActiveTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'reminder_time ASC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get active tasks: $e');
    }
  }

  // Get count of tasks
  Future<int> getTaskCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get task count: $e');
    }
  }

  // Delete all tasks (useful for testing or reset functionality)
  Future<int> deleteAllTasks() async {
    try {
      final db = await database;
      final count = await db.delete('tasks');
      print('All tasks deleted. Count: $count');
      return count;
    } catch (e) {
      throw Exception('Failed to delete all tasks: $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('Database closed');
  }

  // Test database operations (for development/debugging)
  Future<void> testDatabaseOperations() async {
    try {
      print('=== Testing Database Operations ===');

      // Test insert
      final testTask = Task(
        title: 'Test Task',
        description: 'This is a test task',
        reminderTime: TimeOfDay(hour: 9, minute: 0),
      );
      final id = await insertTask(testTask);
      print('✓ Insert test passed. ID: $id');

      // Test get all
      final tasks = await getTasks();
      print('✓ Get all tasks test passed. Count: ${tasks.length}');

      // Test get single
      final task = await getTask(id);
      print('✓ Get single task test passed. Task: ${task?.title}');

      // Test update
      if (task != null) {
        final updatedTask = task.copyWith(
          title: 'Updated Test Task',
          isActive: false,
        );
        await updateTask(updatedTask);
        print('✓ Update test passed');
      }

      // Test delete
      await deleteTask(id);
      print('✓ Delete test passed');

      // Test get count
      final count = await getTaskCount();
      print('✓ Get count test passed. Count: $count');

      print('=== All Database Tests Passed ===');
    } catch (e) {
      print('✗ Database test failed: $e');
    }
  }
}
