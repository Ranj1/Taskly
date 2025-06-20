import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

class TaskDatabase {
  static final TaskDatabase _instance = TaskDatabase._internal();
  static Database? _database;

  TaskDatabase._internal();

  factory TaskDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        isDone INTEGER NOT NULL
      )
    ''');
  }

  // 🔹 Insert a task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  // 🔹 Get all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'dueDate ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  //Update a task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  //Delete a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}

