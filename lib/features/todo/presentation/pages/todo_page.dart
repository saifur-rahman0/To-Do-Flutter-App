// lib/features/todo/presentation/pages/todo_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Import intl
import '../../data/models/todo_model.dart';
import '../../data/repositories/todo_repository.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_list_item.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(
        todoRepository: RepositoryProvider.of<TodoRepositoryImpl>(context),
      )..add(LoadTodos()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ToDo App with BLoC'),
        ),
        body: const TodoView(),
        floatingActionButton: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () => _showAddEditTodoDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Add ToDo',
            );
          },
        ),
      ),
    );
  }
}

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state is TodoLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TodoLoaded) {
          if (state.todos.isEmpty) {
            return const Center(child: Text('No ToDos yet! Add one.'));
          }
          return ListView.builder(
            itemCount: state.todos.length,
            itemBuilder: (context, index) {
              final todo = state.todos[index];
              return TodoListItem(
                  todo: todo,
                  onToggle: (isCompleted) {
                    context.read<TodoBloc>().add(ToggleTodoCompletion(todo));
                  },
                  onDelete: () {
                    context.read<TodoBloc>().add(DeleteTodo(todo.id!));
                  },
                  onEdit: () {
                    _showAddEditTodoDialog(context, existingTodo: todo);
                  });
            },
          );
        } else if (state is TodoError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Something went wrong!'));
      },
    );
  }
}

// Combined Add/Edit Dialog
void _showAddEditTodoDialog(BuildContext parentContext, {TodoModel? existingTodo}) {
  final titleController = TextEditingController(text: existingTodo?.title ?? '');
  final descriptionController = TextEditingController(text: existingTodo?.description ?? '');
  DateTime? selectedDateTime = existingTodo?.dueDate;

  showDialog(
    context: parentContext,
    builder: (context) {
      return StatefulBuilder( // Use StatefulBuilder to manage dialog state for date/time
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existingTodo == null ? 'Add New ToDo' : 'Edit ToDo'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    autofocus: true,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedDateTime == null
                          ? 'No due date set'
                          : 'Due: ${DateFormat.yMd().add_jm().format(selectedDateTime!)}'),
                      TextButton(
                        child: Text(selectedDateTime == null ? 'Set Date/Time' : 'Change'),
                        onPressed: () async {
                          final now = DateTime.now();
                          final initialDate = selectedDateTime ?? now;
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: now.subtract(const Duration(days: 30)), // Allow past dates for editing
                            lastDate: DateTime(2101),
                          );

                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? initialDate),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      )
                    ],
                  ),
                  if (selectedDateTime != null)
                    TextButton(
                      child: const Text('Clear Due Date', style: TextStyle(color: Colors.redAccent)),
                      onPressed: () {
                        setState(() {
                          selectedDateTime = null;
                        });
                      }
                    )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(existingTodo == null ? 'Add' : 'Save'),
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    if (existingTodo == null) {
                      final newTodo = TodoModel(
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: selectedDateTime,
                      );
                      parentContext.read<TodoBloc>().add(AddTodo(newTodo));
                    } else {
                      final updatedTodo = existingTodo.copyWith(
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: selectedDateTime,
                      );
                      parentContext.read<TodoBloc>().add(UpdateTodo(updatedTodo));
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
