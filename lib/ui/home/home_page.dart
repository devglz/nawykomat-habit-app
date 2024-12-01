import 'package:flutter/material.dart';
import 'package:habit_app/ui/widgets/custom_bottom_navigation_bar.dart';
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

  // Przywracamy oryginalne strony dla dolnej nawigacji
  final List<Widget> _pages = [
    const HomePageContent(),  // Nowa główna strona z zakładkami
    const NewsPage(),
    const ProgressPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nawykomat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/addHabit'),
          ),
        ],
      ),
      body: _pages[_currentIndex],
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

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Wszystkie'),
              Tab(text: 'Poranek'),
              Tab(text: 'Południe'),
              Tab(text: 'Wieczór'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DayAreaPage(dayArea: 'all'),
                DayAreaPage(dayArea: 'PORANEK'),
                DayAreaPage(dayArea: 'POŁUDNIE'),
                DayAreaPage(dayArea: 'WIECZÓR'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DayAreaPage extends StatelessWidget {
  final String dayArea;
  const DayAreaPage({required this.dayArea, super.key});

  String _getSectionTitle(bool isActive) {
    if (isActive) {
      return 'Aktywne nawyki ${_getDayAreaText()}';
    }
    return 'Ukończone nawyki ${_getDayAreaText()}';
  }

  String _getDayAreaText() {
    switch (dayArea) {
      case 'PORANEK': return '(poranne)';
      case 'POŁUDNIE': return '(południowe)';
      case 'WIECZÓR': return '(wieczorne)';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SectionTitle(title: _getSectionTitle(true)),
          HabitList(isCompleted: false, dayArea: dayArea),
          SectionTitle(title: _getSectionTitle(false)),
          HabitList(isCompleted: true, dayArea: dayArea),
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
  final String dayArea;

  const HabitList({
    required this.isCompleted,
    required this.dayArea,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: HabitService().getHabits(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Center(
            child: Text('Wystąpił błąd podczas ładowania nawyków'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        print('Total habits: ${snapshot.data!.docs.length}');

        final habits = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final habitIsCompleted = data['isCompleted'] ?? false;
          final habitDayArea = data['dayArea'] ?? '';
          
          print('Habit: ${data['name']}, dayArea: $habitDayArea, isCompleted: $habitIsCompleted');
          
          if (dayArea == 'all') {
            return habitIsCompleted == isCompleted;
          }
          return habitIsCompleted == isCompleted && habitDayArea == dayArea;
        }).toList();

        print('Filtered habits for $dayArea (isCompleted: $isCompleted): ${habits.length}');

        if (habits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                isCompleted ? 'Brak ukończonych nawyków' : 'Brak aktywnych nawyków',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final data = habit.data() as Map<String, dynamic>;
            
            print('Building HabitCard with ID: ${habit.id}');
            
            return HabitCard(
              habitId: habit.id,
              title: data['name'] ?? '',
              description: data['description'] ?? '',
              progress: data['progress'] ?? 0,
              isCompleted: data['isCompleted'] ?? false,
              startDate: data['startDate'] as Timestamp,
              dayArea: data['dayArea'] ?? 'Unknown',
              reminders: List<String>.from(data['reminders'] ?? []),
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
    print('Rendering HabitCard: $habitId');
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 30,
          ),
          onPressed: () async {
            print('Toggling habit: $habitId');
            try {
              await HabitService().toggleHabitCompletion(habitId, isCompleted);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isCompleted ? 'Nawyk oznaczony jako nieukończony' : 'Nawyk ukończony!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              print('Error in HabitCard toggle: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Błąd: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/habitDetail', arguments: habitId);
        },
      ),
    );
  }
}