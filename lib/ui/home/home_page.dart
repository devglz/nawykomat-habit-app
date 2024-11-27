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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex], // Wyświetlanie odpowiedniej strony
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

// Dodaj ten widget jako osobną klasę
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: HabitService().getHabits(),
      builder: (context, snapshot) {
        // Tutaj przenieś całą logikę wyświetlania nawyków
        // która była wcześniej bezpośrednio w body Scaffold
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: HabitService().getHabits(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Wystąpił błąd'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Brak nawyków'));
                  }

                  final habits = snapshot.data!.docs;
                  final activeHabits = habits.where((habit) => !(habit.data() as Map<String, dynamic>)['isCompleted']).toList();
                  final completedHabits = habits.where((habit) => (habit.data() as Map<String, dynamic>)['isCompleted']).toList();

                  return ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Aktywne Nawyki',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...activeHabits.map((habit) {
                        final data = habit.data() as Map<String, dynamic>;
                        final title = data['title'];
                        final description = data['description'];
                        final progress = data['progress'] ?? 0;
                        final isCompleted = data['isCompleted'] ?? false;

                        return ListTile(
                          title: Text(title),
                          subtitle: Text('Opis: $description, Postęp: $progress dni'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isCompleted,
                                onChanged: (bool? value) async {
                                  await HabitService().updateHabit(
                                    habit.id,
                                    title,
                                    description,
                                    progress + (value == true ? 1 : -1),
                                    data['startDate'],
                                    value ?? false,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/editHabit',
                                    arguments: habit,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await HabitService().deleteHabit(habit.id);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Zrobione Nawyki',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...completedHabits.map((habit) {
                        final data = habit.data() as Map<String, dynamic>;
                        final title = data['title'];
                        final description = data['description'];
                        final progress = data['progress'] ?? 0;
                        final isCompleted = data['isCompleted'] ?? false;

                        return ListTile(
                          title: Text(
                            title,
                            style: const TextStyle(decoration: TextDecoration.lineThrough),
                          ),
                          subtitle: Text('Opis: $description, Postęp: $progress dni'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isCompleted,
                                onChanged: (bool? value) async {
                                  await HabitService().updateHabit(
                                    habit.id,
                                    title,
                                    description,
                                    progress + (value == true ? 1 : -1),
                                    data['startDate'],
                                    value ?? false,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/editHabit',
                                    arguments: habit,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await HabitService().deleteHabit(habit.id);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}