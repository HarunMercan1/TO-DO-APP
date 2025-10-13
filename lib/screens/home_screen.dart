import 'package:flutter/material.dart';
import 'package:to_do_app/widgets/task_tile.dart';
import 'package:uuid/uuid.dart'; // Benzersiz ID için
import '../models/db_helper.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void printDBPath() async {
  String path = join(await getDatabasesPath(), 'todo.db');
  print('DB Path: $path');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    fetchTasks(); // Başlangıçta veritabanından görevleri çek
    printDBPath();

  }

  Future<void> fetchTasks() async {
    final data = await dbHelper.getTasks();
    setState(() {
      tasks = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo App'),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Görev yok. Eklemek için + butonuna bas!'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(
            task: task,
            onChanged: (value) async {
              task.isCompleted = value!;
              await dbHelper.updateTask(task);
              fetchTasks();
            },
            onDelete: () async {
              await dbHelper.deleteTask(task.id);
              fetchTasks();
            },
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // AddTaskScreen'den yeni görev ekle
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (result == true) {
            fetchTasks(); // Yeni görev eklendiyse listeyi yenile
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
