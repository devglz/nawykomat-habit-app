import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/main.dart'; // Dodaj ten import
import 'package:provider/provider.dart'; // Dodaj ten import
import 'package:habit_app/services/habit_service.dart';


class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  PersonalizationPageState createState() => PersonalizationPageState();
}

class PersonalizationPageState extends State<PersonalizationPage> {
  bool isDarkMode = false;
  double fontSize = 16.0;
  String selectedColor = 'Fioletowy';
  final List<String> colorOptions = ['Niebieski', 'Zielony', 'Fioletowy', 'Czerwony', 'Brązowy', 'Czarny', 'Szary', 'Pomarańczowy', 'Różowy', 'Limonkowy'];

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
        selectedColor = prefs.getString('themeColor') ?? 'Fioletowy';
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
  }

  void _applyThemeColor(String color) {
    Color themeColor;
    switch (color) {
      case 'Niebieski':
        themeColor = Colors.blue;
        break;
      case 'Zielony':
        themeColor = Colors.green;
        break;
      case 'Czerwony':
        themeColor = Colors.red;
        break;
      case 'Brązowy':
        themeColor = Colors.brown;
        break;
      case 'Czarny':
        themeColor = Colors.black;
        break;
      case 'Szary':
        themeColor = Colors.grey;
        break;
      case 'Pomarańczowy':
        themeColor = Colors.orange;
        break;
      case 'Różowy':
        themeColor = Colors.pink;
        break;
      case 'Limonkowy':
        themeColor = Colors.lime;
        break;
      default:
        themeColor = const Color(0xFF6750A4); // Fioletowy
    }
    MyApp.of(context)?.setThemeColor(themeColor);
  }

  void _toggleDarkMode(bool isDarkMode) {
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    MyApp.of(context)?.setThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizacja', style: TextStyle(color: Colors.white)),
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
                  const Text(
                    'Wygląd',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Tryb ciemny'),
                    subtitle: const Text('Zmień schemat kolorów aplikacji'),
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
                    title: const Text('Rozmiar tekstu'),
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
                  const Text(
                    'Motyw kolorystyczny',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: colorOptions.map((color) {
                      return ChoiceChip(
                        label: Text(color),
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
                  const Text(
                    'Układ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Kompaktowy widok'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Implementacja zmiany układu
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Pokaż etykiety'),
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