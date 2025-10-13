import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_do_app/models/task.dart';
import '../widgets/task_tile.dart';


class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'todo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            dueDate TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }

  // Görev ekleme
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.toIso8601String(),
      'isCompleted': task.isCompleted ? 1 : 0,
    });
  }

  // Görevleri çekme
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
        isCompleted: maps[i]['isCompleted'] == 1,
      );
    });
  }

  // Görev güncelleme
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'isCompleted': task.isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Görev silme
  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
