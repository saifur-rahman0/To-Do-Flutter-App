// lib/features/todo/presentation/widgets/todo_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl
import '../../data/models/todo_model.dart';

class TodoListItem extends StatelessWidget {
  final TodoModel todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    String subtitleText = todo.description;
    if (todo.dueDate != null) {
      final formattedDueDate = DateFormat.yMd().add_jm().format(todo.dueDate!);
      if (subtitleText.isNotEmpty) {
        subtitleText += '\nDue: $formattedDueDate';
      } else {
        subtitleText = 'Due: $formattedDueDate';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (bool? value) {
            if (value != null) {
              onToggle(value);
            }
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: subtitleText.isNotEmpty
            ? Text(
                subtitleText,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit ToDo',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete ToDo',
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
