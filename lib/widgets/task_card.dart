import 'package:flutter/material.dart';
import '../models/task.dart';

/// Task Card Widget - Displays individual task information
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('task_${task.id}'),
      background: _buildDismissBackground(context, isLeft: true),
      secondaryBackground: _buildDismissBackground(context, isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left to delete
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: Card(
        elevation: task.isActive ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.grey.shade300,
            width: task.isActive ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: task.isActive
                  ? null
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Status Icon
                _buildStatusIcon(context),
                const SizedBox(width: 12),

                // Task Content
                Expanded(
                  child: _buildTaskContent(context),
                ),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build Status Icon
  Widget _buildStatusIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: task.isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        task.isActive ? Icons.notifications_active : Icons.notifications_off,
        color: task.isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade500,
        size: 24,
      ),
    );
  }

  /// Build Task Content (Title, Description, Time)
  /// Build Task Content (Title, Description, Time)
  Widget _buildTaskContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Title
        Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: task.isActive ? Colors.black87 : Colors.grey.shade600,
            decoration: task.isActive ? null : TextDecoration.lineThrough,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          // Task Description
          Text(
            task.description,
            style: TextStyle(
              fontSize: 14,
              color:
                  task.isActive ? Colors.grey.shade700 : Colors.grey.shade500,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),

        // Reminder Time + Status Row (fixed)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: task.isActive ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                task.getFormattedTime(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: task.isActive ? Colors.blue : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: task.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: task.isActive ? Colors.green : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          iconSize: 20,
          color: Colors.blue,
          tooltip: 'Edit task',
          onPressed: onEdit,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),

        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete_outline),
          iconSize: 20,
          color: Colors.red,
          tooltip: 'Delete task',
          onPressed: () => _handleDelete(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  /// Build Dismiss Background (for swipe-to-delete)
  Widget _buildDismissBackground(BuildContext context, {required bool isLeft}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle Delete with Confirmation
  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed == true) {
      onDelete?.call();
    }
  }

  /// Show Delete Confirmation Dialog
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Task'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"${task.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Compact Task Card (for alternate designs)
class CompactTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;

  const CompactTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isActive,
          onChanged: (value) => onToggleActive?.call(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isActive ? null : TextDecoration.lineThrough,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${task.getFormattedTime()} • ${task.description}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
