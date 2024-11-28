// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeController {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  ThemeData getTheme() {
    return isDarkMode.value ? _darkTheme : _lightTheme;
  }

  static final _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
  );
}