import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/services/habit_service.dart';

class EditHabitPage extends StatefulWidget {
  final DocumentSnapshot habit;
  const EditHabitPage({super.key, required this.habit});

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TabController _tabController;
  bool _isCompleted = false;
  String _errorMessage = '';
  late Timestamp _startDate;
  String _timeOfDay = 'Kiedykolwiek';
  String _dayArea = 'PORANEK';
  List<TimeOfDay> _reminders = [];
  final List<bool> _selectedDays = List.generate(7, (index) => true);
  final List<bool> _selectedMonthDays = List.generate(31, (index) => false);
  int _intervalDays = 1;
  final List<String> _weekDays = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController(text: widget.habit['name']);
    _startDate = widget.habit['startDate'];
    _isCompleted = widget.habit['isCompleted'] ?? false;
    _dayArea = widget.habit['dayArea'] ?? 'PORANEK';
    // Tutaj dodać inicjalizację pozostałych pól z danych nawyku
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    IconData? icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  // Skopiuj metody _buildDailyTab, _buildMonthlyTab, _buildIntervalTab, _showRepeatDialog
  // z AddHabitPage i dostosuj je do potrzeb edycji
  // ...existing code from AddHabitPage...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj Nawyk'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Podstawowe informacje',
                icon: Icons.edit,
                content: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nazwa nawyku',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              _buildSectionCard(
                title: 'Harmonogram',
                icon: Icons.calendar_today,
                content: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Data rozpoczęcia'),
                      subtitle: Text(_startDate.toDate().toString().split(' ')[0]),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate.toDate(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = Timestamp.fromDate(picked);
                            });
                          }
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Powtarzaj'),
                      subtitle: Text(_getRepeatSummary()),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showRepeatDialog,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Szczegóły wykonania',
                icon: Icons.access_time,
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _dayArea,
                      decoration: InputDecoration(
                        labelText: 'Pora dnia',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['PORANEK', 'POŁUDNIE', 'WIECZÓR']
                          .map((time) => DropdownMenuItem(
                                value: time,
                                child: Text(time),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _dayArea = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Przypomnienia',
                icon: Icons.notifications,
                content: Column(
                  children: [
                    ..._reminders.map((reminder) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(reminder.format(context)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _reminders.remove(reminder);
                              });
                            },
                          ),
                        )),
                    TextButton.icon(
                      icon: const Icon(Icons.add_alarm),
                      label: const Text('Dodaj przypomnienie'),
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _reminders.add(picked);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Implementacja aktualizacji nawyku
                        try {
                          await HabitService().updateHabit(
                            widget.habit.id,
                            _nameController.text,
                            '', // description
                            0, // progress
                            _startDate,
                            _isCompleted,
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          _showError('Wystąpił błąd: $e');
                        }
                      },
                      child: const Text('ZAPISZ ZMIANY'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ANULUJ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  String _getRepeatSummary() {
    // Skopiuj implementację z AddHabitPage
    switch (_tabController.index) {
      case 0:
        final selectedDaysCount = _selectedDays.where((day) => day).length;
        return 'Codziennie (${selectedDaysCount} dni w tygodniu)';
      case 1:
        final selectedMonthDaysCount = _selectedMonthDays.where((day) => day).length;
        return 'Miesięcznie (${selectedMonthDaysCount} dni)';
      case 2:
        return 'Co ${_intervalDays} dni';
      default:
        return 'Nie wybrano';
    }
  }
}