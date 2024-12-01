import 'package:flutter/material.dart';
import 'package:habit_app/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:habit_app/services/auth_service.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/ui/news/news_page.dart';
import 'package:habit_app/ui/progress/progress_page.dart';
import 'package:habit_app/ui/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista widgetów/stron dla każdej zakładki
  final List<Widget> _pages = [
    const HomeContent(), // Główna zawartość strony
    const NewsPage(),    // Strona z aktualnościami
    const ProgressPage(), // Strona ze statystykami
    const SettingsPage(), // Strona z ustawieniami
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nawykomat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addHabit');
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],  // Wyświetlanie odpowiedniej strony
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SectionTitle(title: 'Nawyki aktywne'),
          HabitList(isCompleted: false),  // Aktywne nawyki
          SectionTitle(title: 'Nawyki ukończone'),
          HabitList(isCompleted: true),   // Ukończone nawyki
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HabitList extends StatelessWidget {
  final bool isCompleted;

  const HabitList({required this.isCompleted, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: HabitService().getHabits(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filtrujemy nawyki na podstawie statusu isCompleted
        final habits = snapshot.data!.docs
            .where((doc) => doc['isCompleted'] == isCompleted)
            .toList();

        if (habits.isEmpty) {
          return const Center(child: Text('Brak nawyków'));
        }

        return ListView.builder(
          shrinkWrap: true,  // Zapewnia, że lista jest ograniczona do wysokości dostępnego obszaru
          physics: const NeverScrollableScrollPhysics(),  // Wyłączamy przewijanie w obrębie tej listy
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final data = habit.data() as Map<String, dynamic>;
            final habitId = habit.id;  // Pobieranie ID nawyku
            final title = data['name'] ?? '';
            final description = data['description'] ?? '';
            final progress = data['progress'] ?? 0;
            final isCompleted = data['isCompleted'] ?? false;
            final startDate = data['startDate'] as Timestamp;
            final dayArea = data['dayArea'] ?? 'Unknown';
            final reminders = List<String>.from(data['reminders'] ?? []);

            return HabitCard(
              habitId: habitId,
              title: title,
              description: description,
              progress: progress,
              isCompleted: isCompleted,
              startDate: startDate,
              dayArea: dayArea,
              reminders: reminders,
            );
          },
        );
      },
    );
  }
}

class HabitCard extends StatelessWidget {
  final String habitId;
  final String title;
  final String description;
  final int progress;
  final bool isCompleted;
  final Timestamp startDate;
  final String dayArea;
  final List<String> reminders;

  const HabitCard({
    required this.habitId,
    required this.title,
    required this.description,
    required this.progress,
    required this.isCompleted,
    required this.startDate,
    required this.dayArea,
    required this.reminders,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(
          isCompleted ? Icons.check_circle : Icons.circle,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        onTap: () {
          // Logika dla otwierania szczegółów nawyku (np. edytowanie lub szczegóły)
          Navigator.pushNamed(context, '/habitDetail', arguments: habitId);
        },
      ),
    );
  }
}
