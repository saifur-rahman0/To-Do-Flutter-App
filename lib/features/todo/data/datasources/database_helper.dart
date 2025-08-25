// lib/features/todo/data/datasources/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo_model.dart';

class DatabaseHelper {
  static const _databaseName = "ToDoDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'todo_table';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnIsCompleted = 'isCompleted';
  static const columnDueDate = 'dueDate';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create it if it doesn't exist
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT,
            $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
            $columnDueDate TEXT
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(TodoModel todo) async {
    Database db = await instance.database;
    return await db.insert(table, todo.toMap());
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<TodoModel>> getAllTodos() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      return TodoModel.fromMap(maps[i]);
    });
  }

  // Updates a row in the database. The return value is the number of rows affected.
  Future<int> update(TodoModel todo) async {
    Database db = await instance.database;
    return await db.update(table, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  // Deletes a row in the database. The return value is the number of rows affected.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
