import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/db_helper.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final dbHelper = DBHelper();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Görev Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Başlık',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            SizedBox(height: 8,),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Açıklama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue[100]),
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                _selectedDate == null
                    ? 'Bitiş Tarihi Seç'
                    : 'Bitiş Tarihi: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;
                final newTask = Task(
                  id: const Uuid().v4(),
                  title: _titleController.text,
                  description: _descController.text,
                  dueDate: _selectedDate ?? DateTime.now(),
                );
                await dbHelper.insertTask(newTask);
                Navigator.pop(context, true); // HomeScreen’e geri dön
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
