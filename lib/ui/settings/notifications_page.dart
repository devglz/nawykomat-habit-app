import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override 
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool reminderEnabled = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);
  List<bool> selectedDays = List.generate(7, (_) => true);
  final List<String> daysOfWeek = [
    S.current.monday,
    S.current.tuesday,
    S.current.wednesday,
    S.current.thursday,
    S.current.friday,
    S.current.saturday,
    S.current.sunday
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        pushEnabled = prefs.getBool('pushEnabled') ?? true;
        emailEnabled = prefs.getBool('emailEnabled') ?? false;
        reminderEnabled = prefs.getBool('reminderEnabled') ?? true;
        final hour = prefs.getInt('reminderHour') ?? 20;
        final minute = prefs.getInt('reminderMinute') ?? 0;
        reminderTime = TimeOfDay(hour: hour, minute: minute);
        for (var i = 0; i < 7; i++) {
          selectedDays[i] = prefs.getBool('day_$i') ?? true;
        }
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pushEnabled', pushEnabled);
      await prefs.setBool('emailEnabled', emailEnabled);
      await prefs.setBool('reminderEnabled', reminderEnabled);
      await prefs.setInt('reminderHour', reminderTime.hour);
      await prefs.setInt('reminderMinute', reminderTime.minute);
      for (var i = 0; i < 7; i++) {
        await prefs.setBool('day_$i', selectedDays[i]);
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null) {
      setState(() {
        reminderTime = picked;
        _saveSettings();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notificationsTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
      ),
      body: ListView(
        children: [
          _buildSwitchCard(
            title: localizations.pushNotifications,
            subtitle: localizations.pushNotificationsSubtitle,
            value: pushEnabled,
            onChanged: (value) {
              setState(() {
                pushEnabled = value;
                _saveSettings();
              });
            },
          ),
          _buildSwitchCard(
            title: localizations.emailNotifications,
            subtitle: localizations.emailNotificationsSubtitle,
            value: emailEnabled,
            onChanged: (value) {
              setState(() {
                emailEnabled = value;
                _saveSettings();
              });
            },
          ),
          _buildReminderCard(),
          _buildDaysSelectionCard(),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildReminderCard() {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(localizations.dailyReminders),
            subtitle: Text(localizations.dailyRemindersSubtitle),
            value: reminderEnabled,
            onChanged: (value) {
              setState(() {
                reminderEnabled = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: Text(localizations.reminderTime),
            trailing: TextButton(
              onPressed: reminderEnabled ? _selectTime : null,
              child: Text(
                '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelectionCard() {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.notificationDays,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 4.0,
              children: List.generate(7, (index) {
                return FilterChip(
                  label: Text(daysOfWeek[index]),
                  selected: selectedDays[index],
                  onSelected: reminderEnabled
                      ? (value) {
                          setState(() {
                            selectedDays[index] = value;
                            _saveSettings();
                          });
                        }
                      : null,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
