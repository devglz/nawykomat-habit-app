import 'package:flutter/material.dart';
import 'package:habit_app/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/ui/news/news_page.dart';
import 'package:habit_app/ui/progress/progress_page.dart';
import 'package:habit_app/ui/settings/settings_page.dart';
import 'package:habit_app/ui/habit/edit_habit_page.dart'; // Dodaj import
import 'package:habit_app/services/auth_service.dart'; // Dodaj import
import 'package:intl/intl.dart'; // Dodaj import
import 'package:flutter/foundation.dart' show kIsWeb; // Dodaj import
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import
import 'package:flutter_localizations/flutter_localizations.dart'; // Dodaj import
import 'package:audioplayers/audioplayers.dart'; // Dodaj import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const NewsPage(),
    const ProgressPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Stack(
                children: [
                  if (kIsWeb) // Dodaj warunek
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
                        style: const TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Roboto'), // Zmień czcionkę
                      ),
                    ),
                  Center(
                    child: Padding( // Dodaj Padding
                      padding: const EdgeInsets.only(left: 50.0), // Przesuń lekko w lewo
                      child: Text(localizations.appTitle, style: const TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white, // Zawsze biały kolor tła
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await AuthService().signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            )
          : null,
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/addHabit'),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor, // Użyj koloru motywu
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor, // Użyj koloru motywu
            child: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: localizations.all),
                Tab(text: localizations.morning),
                Tab(text: localizations.afternoon),
                Tab(text: localizations.evening),
              ],
            ),
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

  String _getSectionTitle(bool isActive, BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji
    if (isActive) {
      return '${localizations.activeHabits} ${_getDayAreaText(context)}';
    }
    return '${localizations.completedHabits} ${_getDayAreaText(context)}';
  }

  String _getDayAreaText(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji
    switch (dayArea) {
      case 'PORANEK': return '(${localizations.morning})';
      case 'POŁUDNIE': return '(${localizations.afternoon})';
      case 'WIECZÓR': return '(${localizations.evening})';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // Pobierz dzisiejszy dzień tygodnia (0 - poniedziałek, 1 - wtorek, itd.)

    return SingleChildScrollView(
      child: Column(
        children: [
          SectionTitle(title: _getSectionTitle(true, context)),
          HabitList(isCompleted: false, dayArea: dayArea, selectedDay: today), // Przekaż dzisiejszy dzień tygodnia
          SectionTitle(title: _getSectionTitle(false, context)),
          HabitList(isCompleted: true, dayArea: dayArea, selectedDay: today), // Przekaż dzisiejszy dzień tygodnia
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
  final int selectedDay; // Dodaj pole selectedDay

  const HabitList({
    required this.isCompleted,
    required this.dayArea,
    required this.selectedDay, // Dodaj pole selectedDay
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: HabitService().getHabits(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(
            child: Text(S.of(context).loadingError), // Dodaj tłumaczenie błędu
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
          final habitSelectedDays = List<int>.from(data['selectedDays'] ?? []);

          print('Habit: ${data['name']}, dayArea: $habitDayArea, isCompleted: $habitIsCompleted, selectedDays: $habitSelectedDays');

          if (dayArea == 'all') {
            return habitIsCompleted == isCompleted && habitSelectedDays.contains(selectedDay);
          }
          return habitIsCompleted == isCompleted && habitDayArea == dayArea && habitSelectedDays.contains(selectedDay);
        }).toList();

        print('Filtered habits for $dayArea (isCompleted: $isCompleted, selectedDay: $selectedDay): ${habits.length}');

        if (habits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                isCompleted ? S.of(context).noCompletedHabits : S.of(context).noActiveHabits, // Dodaj tłumaczenie
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
              habit: habit, // Dodaj przekazanie habit
            );
          },
        );
      },
    );
  }
}

class HabitCard extends StatefulWidget {
  final String habitId;
  final String title;
  final String description;
  final int progress;
  final bool isCompleted;
  final Timestamp startDate;
  final String dayArea;
  final List<String> reminders;
  final DocumentSnapshot habit; // Dodaj pole habit

  const HabitCard({
    required this.habitId,
    required this.title,
    required this.description,
    required this.progress,
    required this.isCompleted,
    required this.startDate,
    required this.dayArea,
    required this.reminders,
    required this.habit, // Dodaj pole habit
    super.key,
  });

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Dodaj instancję AudioPlayer

  @override
  Widget build(BuildContext context) {
    print('Rendering HabitCard: ${widget.habitId}');
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Powiększenie i pogrubienie nazwy nawyku
        ),
        subtitle: Text(widget.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                widget.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: widget.isCompleted ? Colors.green : Colors.grey,
                size: 30,
              ),
              onPressed: () async {
                print('Toggling habit: ${widget.habitId}');
                try {
                  await HabitService().toggleHabitCompletion(widget.habitId, widget.isCompleted);
                  if (mounted) { // Sprawdź, czy widget jest zamontowany
                    if (!widget.isCompleted) {
                      await _audioPlayer.setVolume(1.0); // Ustaw głośność na 100%
                      await _audioPlayer.play(AssetSource('bell-ring.mp3')); // Odtwórz dźwięk
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.isCompleted ? S.of(context).habitMarkedIncomplete : S.of(context).habitCompleted, // Dodaj tłumaczenie
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error in HabitCard toggle: $e');
                  if (mounted) { // Sprawdź, czy widget jest zamontowany
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${S.of(context).error}: ${e.toString()}'), // Dodaj tłumaczenie
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHabitPage(habit: widget.habit),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}