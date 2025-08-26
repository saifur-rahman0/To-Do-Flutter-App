// lib/features/todo/presentation/bloc/todo_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/todo_model.dart';
import '../../data/repositories/todo_repository.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository;

  TodoBloc({required TodoRepository todoRepository})
      : _todoRepository = todoRepository,
        super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await _todoRepository.getTodos();
      emit(TodoLoaded(List.from(todos))); // Emit a copy
    } catch (e) {
      emit(TodoError("Failed to load todos: ${e.toString()}"));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await _todoRepository.addTodo(event.todo);
      // Reload todos to reflect the new addition
      final todos = await _todoRepository.getTodos();
      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError("Failed to add todo: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      await _todoRepository.updateTodo(event.todo);
      final todos = await _todoRepository.getTodos();
      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError("Failed to update todo: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await _todoRepository.deleteTodo(event.id);
      final todos = await _todoRepository.getTodos();
      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError("Failed to delete todo: ${e.toString()}"));
    }
  }

  Future<void> _onToggleTodoCompletion(ToggleTodoCompletion event, Emitter<TodoState> emit) async {
    try {
      final updatedTodo = event.todo.copyWith(isCompleted: !event.todo.isCompleted);
      await _todoRepository.updateTodo(updatedTodo);
      final todos = await _todoRepository.getTodos();
      emit(TodoLoaded(List.from(todos)));
    } catch (e) {
      emit(TodoError("Failed to toggle todo: ${e.toString()}"));
    }
  }
}
