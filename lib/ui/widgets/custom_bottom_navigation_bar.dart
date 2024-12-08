// custom_bottom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj ten import

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    this.selectedItemColor = Colors.blue, // Domyślny kolor aktywnej ikony
    this.unselectedItemColor = Colors.grey, // Domyślny kolor nieaktywnej ikony
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Dodaj lokalizacje

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: localizations.habits,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: localizations.guides,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: localizations.statistics,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localizations.settings,
          ),
        ],
      ),
    );
  }
}