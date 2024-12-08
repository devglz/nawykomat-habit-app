import 'package:flutter/material.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj ten import

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
  String _dayArea = ''; // Initialize as empty string
  final List<TimeOfDay> _reminders = [];
  late TabController _tabController;
  final List<bool> _selectedDays = List.generate(7, (index) => true);
  final List<String> _weekDays = []; // Initialize as empty list
  final TimeOfDay _timeOfDay = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Zmiana długości na 1
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeWeekDays(); // Initialize week days
    _initializeDayArea(); // Initialize day area
  }

  void _initializeWeekDays() {
    final localizations = S.of(context);
    setState(() {
      _weekDays.addAll([
        localizations.monday,
        localizations.tuesday,
        localizations.wednesday,
        localizations.thursday,
        localizations.friday,
        localizations.saturday,
        localizations.sunday,
      ]);
    });
  }

  void _initializeDayArea() {
    final localizations = S.of(context);
    setState(() {
      _dayArea = localizations.morning; // Set initial value to localized morning
    });
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Wyśrodkuj zawartość
        children: [
          Text(
            S.of(context).selectDaysOfWeek,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center, // Wyśrodkuj elementy w Wrap
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

  String _getRepeatSummary() {
    final selectedDaysCount = _selectedDays.where((day) => day).length;
    return S.of(context).repeatSummary(selectedDaysCount);
  }

  void _showRepeatDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5, // Zmniejsz szerokość
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).repeatSettings,
                          style: TextStyle(
                            fontSize: 18, // Zmniejsz rozmiar czcionki
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
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                          color: isDarkMode ? Colors.grey[700] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tabs: [
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(S.of(context).daily),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200, // Zmniejsz wysokość
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Material(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            child: _buildDailyTab(setDialogState),
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
                            S.of(context).cancel,
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
                          child: Text(
                            S.of(context).save,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = S.of(context); // Dodaj dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.addHabit),
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
                title: localizations.basicInfo,
                icon: Icons.edit,
                content: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.habitName,
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              _buildSectionCard(
                title: localizations.schedule,
                icon: Icons.calendar_today,
                content: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localizations.startDate),
                      subtitle: Text(_startDate != null
                          ? _startDate!.toDate().toLocal().toString().split(' ')[0]
                          : localizations.selectDate),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localizations.repeat),
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
                title: localizations.executionDetails,
                icon: Icons.access_time,
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _dayArea,
                      decoration: InputDecoration(
                        labelText: localizations.timeOfDay,
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        localizations.morning,
                        localizations.afternoon,
                        localizations.evening
                      ].map((time) => DropdownMenuItem(
                                value: time,
                                child: Text(time),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _dayArea = value!;
                        });
                      },
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: localizations.reminders,
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
                      label: Text(localizations.addReminder),
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
                      child: Text(localizations.save),
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
                      child: Text(localizations.cancel),
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