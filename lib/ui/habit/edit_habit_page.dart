import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/services/habit_service.dart';

class EditHabitPage extends StatefulWidget {
  final DocumentSnapshot habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _progressController;
  late Timestamp _startDate;
  bool _isCompleted = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit['title']);
    _descriptionController = TextEditingController(text: widget.habit['description']);
    _progressController = TextEditingController(text: widget.habit['progress'].toString());
    _startDate = widget.habit['startDate'];
    _isCompleted = widget.habit['isCompleted'] ?? false;
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _updateHabit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final progress = int.tryParse(_progressController.text.trim()) ?? 0;

    if (title.isEmpty) {
      _showError('Proszę wprowadzić tytuł.');
      return;
    }

    if (description.isEmpty) {
      _showError('Proszę wprowadzić opis.');
      return;
    }

    try {
      await HabitService().updateHabit(widget.habit.id, title, description, progress, _startDate, _isCompleted);
      Navigator.pop(context);
    } catch (e) {
      _showError('Wystąpił błąd: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj Nawyki'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _progressController,
              decoration: const InputDecoration(
                labelText: 'Postęp',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('Wykonane'),
              value: _isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  _isCompleted = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateHabit,
              child: const Text('Zaktualizuj Nawyki'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}