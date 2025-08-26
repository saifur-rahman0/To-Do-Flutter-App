// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart'; // Ensure this is imported
import 'package:sqflite/sqflite.dart'; // Ensure this is imported
import 'dart:io'; // For Directory

import 'features/todo/data/datasources/database_helper.dart';
import 'features/todo/data/repositories/todo_repository.dart';
import 'features/todo/presentation/pages/todo_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database helper (optional, as it's a singleton and will init on first use)
  // However, doing it here can pre-warm it if necessary.
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TodoRepositoryImpl>(
      create: (context) => TodoRepositoryImpl(databaseHelper: DatabaseHelper.instance),
      child: MaterialApp(
        title: 'ToDo App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true, // Optional: Enable Material 3
        ),
        home: const TodoPage(), // Set TodoPage as the home
        debugShowCheckedModeBanner: false, // Optional: remove debug banner
      ),
    );
  }
}
