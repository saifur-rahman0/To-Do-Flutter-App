// lib/features/todo/data/models/todo_model.dart
import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;

  const TodoModel({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
  });

  // Convert a TodoModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // SQLite uses 0 and 1 for booleans
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  // Implement a method to create a TodoModel from a map (for database interaction)
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
    );
  }

  //copyWith method
  TodoModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, dueDate];
}
