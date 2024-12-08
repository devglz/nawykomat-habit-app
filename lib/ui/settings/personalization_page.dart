import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/main.dart'; // Dodaj ten import
import 'package:provider/provider.dart'; // Dodaj ten import
import 'package:habit_app/services/habit_service.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import

class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  PersonalizationPageState createState() => PersonalizationPageState();
}

class PersonalizationPageState extends State<PersonalizationPage> {
  bool isDarkMode = false;
  double fontSize = 16.0;
  String selectedColor = 'Purple';
  final List<String> colorOptions = [
    'Blue', 'Green', 'Purple', 'Red', 'Brown', 'Black', 'Grey', 'Orange', 'Pink', 'Lime'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isDarkMode = prefs.getBool('darkMode') ?? false;
        fontSize = prefs.getDouble('fontSize') ?? 16.0;
        selectedColor = prefs.getString('themeColor') ?? 'Purple';
        _applyThemeColor(selectedColor);
      });
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setString('themeColor', selectedColor);
    _applyThemeColor(selectedColor);
    if (!mounted) return;
    final habitService = Provider.of<HabitService>(context, listen: false);
    await habitService.saveThemeColor(selectedColor);
    MyApp.of(context)?.setFontSize(fontSize); // Zapisz rozmiar tekstu do Firebase
  }

  void _applyThemeColor(String color) {
    Color themeColor;
    switch (color) {
      case 'Blue':
        themeColor = Colors.blue;
        break;
      case 'Green':
        themeColor = Colors.green;
        break;
      case 'Red':
        themeColor = Colors.red;
        break;
      case 'Brown':
        themeColor = Colors.brown;
        break;
      case 'Black':
        themeColor = Colors.black;
        break;
      case 'Grey':
        themeColor = Colors.grey;
        break;
      case 'Orange':
        themeColor = Colors.orange;
        break;
      case 'Pink':
        themeColor = Colors.pink;
        break;
      case 'Lime':
        themeColor = Colors.lime;
        break;
      default:
        themeColor = const Color(0xFF6750A4); // Purple
    }
    MyApp.of(context)?.setThemeColor(themeColor);
  }

  void _toggleDarkMode(bool isDarkMode) {
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    MyApp.of(context)?.setThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.personalizationTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.appearance,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(localizations.darkMode, style: TextStyle(color: textColor)),
                    subtitle: Text(localizations.darkModeSubtitle, style: TextStyle(color: textColor)),
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                        _toggleDarkMode(value);
                        _saveSettings();
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(localizations.textSize, style: TextStyle(color: textColor)),
                    subtitle: Slider(
                      value: fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      label: fontSize.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          fontSize = value;
                          _saveSettings();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.themeColor,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: colorOptions.map((color) {
                      return ChoiceChip(
                        label: Text(color, style: TextStyle(color: textColor)),
                        selected: selectedColor == color,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedColor = color;
                            _saveSettings();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.layout,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(localizations.compactView, style: TextStyle(color: textColor)),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Implementacja zmiany układu
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(localizations.showLabels, style: TextStyle(color: textColor)),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Implementacja pokazywania etykiet
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}