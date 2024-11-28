import 'package:flutter/material.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  _AddHabitPageState createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _progressController = TextEditingController();
  bool _isCompleted = false;
  String _errorMessage = '';
  Timestamp? _startDate;
  Timestamp? _createdAt;

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _addHabit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final progress = int.tryParse(_progressController.text.trim()) ?? 0;
    final startDate = _startDate ?? Timestamp.now();
    final createdAt = _createdAt ?? Timestamp.now();

    if (title.isEmpty) {
      _showError('Proszę wprowadzić tytuł.');
      return;
    }

    if (description.isEmpty) {
      _showError('Proszę wprowadzić opis.');
      return;
    }

    try {
      await HabitService().addHabit(title, description, progress, startDate, _isCompleted);
      Navigator.pop(context);
    } catch (e) {
      _showError('Wystąpił błąd: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = Timestamp.fromDate(picked);
        } else {
          _createdAt = Timestamp.fromDate(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Nawyki'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nowy Nawyki',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
                maxLines: 3,
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
              ListTile(
                title: const Text('Data rozpoczęcia'),
                subtitle: Text(_startDate != null
                    ? _startDate!.toDate().toString()
                    : 'Wybierz datę'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Data utworzenia'),
                subtitle: Text(_createdAt != null
                    ? _createdAt!.toDate().toString()
                    : 'Wybierz datę'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
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
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addHabit,
                  icon: const Icon(Icons.save),
                  label: const Text('Dodaj Nawyki'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
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
      ),
    );
  }
}