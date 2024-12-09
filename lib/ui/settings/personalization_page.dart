import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/main.dart'; // Dodaj ten import
import 'package:provider/provider.dart'; // Dodaj ten import
import 'package:habit_app/services/habit_service.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import
import 'package:flutter_svg/flutter_svg.dart'; // Dodaj ten import

class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  PersonalizationPageState createState() => PersonalizationPageState();
}

class PersonalizationPageState extends State<PersonalizationPage> {
  bool isDarkMode = false;
  double fontSize = 16.0;
  String selectedColor = 'Purple';
  bool isCompactView = false;
  bool showLabels = true;
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
        isCompactView = prefs.getBool('compactView') ?? false;
        showLabels = prefs.getBool('showLabels') ?? true;
        _applyThemeColor(selectedColor);
      });
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    await prefs.setDouble('fontSize', fontSize);
    await prefs.setString('themeColor', selectedColor);
    await prefs.setBool('compactView', isCompactView);
    await prefs.setBool('showLabels', showLabels);
    _applyThemeColor(selectedColor);
    if (!mounted) return;
    final habitService = Provider.of<HabitService>(context, listen: false);
    await habitService.saveThemeColor(selectedColor);
    MyApp.of(context)?.setFontSize(fontSize); // Zapisz rozmiar tekstu do Firebase
    MyApp.of(context)?.setCompactView(isCompactView);
    MyApp.of(context)?.setShowLabels(showLabels);
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

  String getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'assets/flags/gb.svg';
      case 'pl':
        return 'assets/flags/pl.svg';
      case 'de':
        return 'assets/flags/de.svg';
      case 'es':
        return 'assets/flags/es.svg';
      case 'fr':
        return 'assets/flags/fr.svg';
      case 'zh':
        return 'assets/flags/cn.svg';
      default:
        return 'assets/flags/unknown.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.personalizationTitle, style: TextStyle(color: Colors.white, fontSize: fontSize)),
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
                    style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(localizations.darkMode, style: TextStyle(color: textColor, fontSize: fontSize)),
                    subtitle: Text(localizations.darkModeSubtitle, style: TextStyle(color: textColor, fontSize: fontSize - 2)),
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
                    title: Text(localizations.textSize, style: TextStyle(color: textColor, fontSize: fontSize)),
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
                    style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: colorOptions.map((color) {
                      return ChoiceChip(
                        label: Text(color, style: TextStyle(color: textColor, fontSize: fontSize)),
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
                    localizations.language,
                    style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: S.delegate.supportedLocales.map((locale) {
                      final flag = getFlag(locale.languageCode);
                      return ChoiceChip(
                        avatar: SvgPicture.asset(
                          flag,
                          width: 24,
                          height: 24,
                        ),
                        label: Text(locale.languageCode.toUpperCase(), style: TextStyle(color: textColor, fontSize: fontSize)),
                        selected: MyApp.of(context)?.locale == locale,
                        onSelected: (bool selected) {
                          if (selected) {
                            MyApp.of(context)?.setLocale(locale);
                            _saveSettings();
                          }
                        },
                      );
                    }).toList(),
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