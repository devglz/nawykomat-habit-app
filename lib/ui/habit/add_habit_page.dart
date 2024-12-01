import 'package:flutter/material.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  AddHabitPageState createState() => AddHabitPageState();
}

class AddHabitPageState extends State<AddHabitPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final bool _isCompleted = false;
  String _errorMessage = '';
  Timestamp? _startDate;
  String _dayArea = 'PORANEK';
  final List<TimeOfDay> _reminders = [];
  late TabController _tabController;
  final List<bool> _selectedDays = List.generate(7, (index) => true);
  final List<bool> _selectedMonthDays = List.generate(31, (index) => false);
  int _intervalDays = 1;
  final List<String> _weekDays = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];
  final TimeOfDay _timeOfDay = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addHabit() async {
    try {
      List<int> selectedDays = [];
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) {
          selectedDays.add(i);
        }
      }

      List<String> reminders = _reminders.map((reminder) => '${reminder.hour}:${reminder.minute}').toList();

      await HabitService().addHabit(
        _nameController.text,
        0,
        _startDate ?? Timestamp.now(),
        _isCompleted,
        '${_timeOfDay.hour}:${_timeOfDay.minute}',
        _dayArea,
        reminders,
        selectedDays,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
        }
      });
    }
  }

  Widget _buildDailyTab(StateSetter setState) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wybierz dni tygodnia',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(7, (index) {
            return FilterChip(
              label: Text(_weekDays[index]),
              selected: _selectedDays[index], // Sprawdzamy, czy dany dzień jest zaznaczony
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (bool selected) {
                setState(() {
                  _selectedDays[index] = selected; // Zmiana stanu zaznaczenia dnia
                });
              },
            );
          }),
        ),
      ],
    ),
  );
}


  Widget _buildMonthlyTab(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wybierz dni miesiąca',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(31, (index) {
                  return FilterChip(
                    label: Text('${index + 1}'),
                    selected: _selectedMonthDays[index],
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedMonthDays[index] = selected;
                      });
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalTab(StateSetter setState) { // Dodaj parametr setState
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wybierz interwał',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Powtarzaj co'),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _intervalDays,
                items: List.generate(20, (index) => index + 1)
                    .map((days) => DropdownMenuItem(
                          value: days,
                          child: Text('$days'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() { // Użyj przekazanego setState
                    _intervalDays = value!;
                  });
                },
              ),
              const SizedBox(width: 16),
              const Text('dni'),
            ],
          ),
        ],
      ),
    );
  }

  String _getRepeatSummary() {
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

  void _showRepeatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ustawienia powtarzania',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tabs: const [
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Codziennie'),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Miesięcznie'),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Interwał'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Material(
                            color: Colors.white,
                            child: _buildDailyTab(setDialogState),
                          ),
                          Material(
                            color: Colors.white,
                            child: _buildMonthlyTab(setDialogState),
                          ),
                          Material(
                            color: Colors.white,
                            child: _buildIntervalTab(setDialogState), // Przekaż setDialogState
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'ANULUJ',
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Aktualizuje widok główny
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white, // Dodaj kolor tekstu
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'ZAPISZ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Nawyk'),
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
                      subtitle: Text(_startDate != null
                          ? '${_startDate!.toDate().toLocal().toString().split(' ')[0]}'
                          : 'Wybierz datę'),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
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
                      onPressed: _addHabit,
                      child: const Text('ZAPISZ'),
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
}