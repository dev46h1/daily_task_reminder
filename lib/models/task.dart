import 'package:flutter/material.dart';

class Task {
  final int? id;
  final String title;
  final String description;
  final TimeOfDay reminderTime;
  final bool isActive;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.reminderTime,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Task object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminder_time':
          '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Task object from Map (database retrieval)
  factory Task.fromMap(Map<String, dynamic> map) {
    // Parse time string "HH:mm" to TimeOfDay
    final timeParts = (map['reminder_time'] as String).split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      reminderTime: TimeOfDay(hour: hour, minute: minute),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Create a copy of Task with optional field updates
  Task copyWith({
    int? id,
    String? title,
    String? description,
    TimeOfDay? reminderTime,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // String representation for debugging
  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, reminderTime: ${reminderTime.hour}:${reminderTime.minute}, isActive: $isActive, createdAt: $createdAt}';
  }

  // Helper method to get formatted time string for display
  String getFormattedTime() {
    final hour =
        reminderTime.hourOfPeriod == 0 ? 12 : reminderTime.hourOfPeriod;
    final minute = reminderTime.minute.toString().padLeft(2, '0');
    final period = reminderTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.reminderTime.hour == reminderTime.hour &&
        other.reminderTime.minute == reminderTime.minute &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      reminderTime.hour,
      reminderTime.minute,
      isActive,
      createdAt,
    );
  }
}
