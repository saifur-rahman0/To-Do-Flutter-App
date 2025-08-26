// lib/features/todo/data/repositories/todo_repository.dart
import '../datasources/database_helper.dart';
import '../models/todo_model.dart';

abstract class TodoRepository {
  Future<List<TodoModel>> getTodos();
  Future<void> addTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}

class TodoRepositoryImpl implements TodoRepository {
  final DatabaseHelper _databaseHelper;

  TodoRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<TodoModel>> getTodos() async {
    return await _databaseHelper.getAllTodos();
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    await _databaseHelper.insert(todo);
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    await _databaseHelper.update(todo);
  }

  @override
  Future<void> deleteTodo(int id) async {
    await _databaseHelper.delete(id);
  }
}
