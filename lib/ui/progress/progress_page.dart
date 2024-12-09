import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:habit_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:habit_app/services/user_service.dart'; // Dodaj ten import
import 'package:habit_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart'; // Dodaj ten import
import 'package:intl/intl.dart'; // Dodaj ten import

class ProgressPageState extends ChangeNotifier {
  final HabitService _habitService;
  int activeHabits = 0;
  int completedHabits = 0;
  int longestStreak = 0;
  double successRate = 0.0;
  Map<int, int> completionsByDay = {};
  int mostActiveDay = 1;
  List<FlSpot> weeklyProgress = [];
  int totalHabits = 0;
  Map<int, int> completionsByMonth = {};
  Map<DateTime, int> dailyCompletions = {}; // Add this line
  Map<int, int> activeHabitsByDay = {}; // Dodaj tę zmienną jako pole klasy
  double monthlyCompletionPercentage = 0.0; // Dodaj tę zmienną jako pole klasy

  bool _mounted = true;

  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  ProgressPageState(this._habitService) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // Pobierz aktywne nawyki dla każdego dnia tygodnia
      activeHabitsByDay.clear();
      for (int i = 0; i < 7; i++) {
        activeHabitsByDay[i] = await _habitService.getActiveHabitsCountForDay(i);
        if (!mounted) return;
      }

      // Pobierz wszystkie ukończenia nawyków
      final completions = await _habitService.getAllCompletions();
      if (!mounted) return;

      // Oblicz ukończenia nawyków dla każdego dnia tygodnia
      completionsByDay.clear();
      for (var completion in completions) {
        final data = completion.data() as Map<String, dynamic>;
        if (data['updatedAt'] == null || !(data['updatedAt'] is Timestamp)) {
          debugPrint('Brak pola updatedAt w dokumencie');
          continue;
        }
        final updatedAt = (data['updatedAt'] as Timestamp).toDate();
        final weekday = (updatedAt.weekday - 1) % 7; // Mapowanie: Poniedziałek = 0, ..., Niedziela = 6
        completionsByDay[weekday] = (completionsByDay[weekday] ?? 0) + 1;
      }

      // Oblicz wskaźnik sukcesu dla dzisiaj
      final weekdayIndex = (now.weekday - 1) % 7; // 0 = Poniedziałek, ..., 6 = Niedziela
      activeHabits = activeHabitsByDay[weekdayIndex] ?? 0;
      completedHabits = completionsByDay[weekdayIndex] ?? 0;

      debugPrint('Dane dzisiejsze: activeHabits=$activeHabits, completedHabits=$completedHabits');
      successRate = activeHabits > 0 ? (completedHabits / activeHabits) * 100 : 0.0;

      // Wypełnij dane dla wykresu tygodniowego
      weeklyProgress = List.generate(7, (index) {
        final dayActive = activeHabitsByDay[index] ?? 0;
        final dayCompleted = completionsByDay[index] ?? 0;
        final progress = dayActive > 0 ? (dayCompleted / dayActive) * 100 : 0.0;
        return FlSpot(index.toDouble(), progress.isNaN ? 0.0 : progress);
      });

      // Pobierz liczbę wszystkich nawyków
      totalHabits = await _habitService.getActiveHabitsCount();
      if (!mounted) return;

      // Oblicz ukończenia nawyków dla każdego miesiąca
      completionsByMonth = await _habitService.calculateCompletionsByMonth();
      if (!mounted) return;

      // Oblicz procent ukończenia nawyków w bieżącym miesiącu
      monthlyCompletionPercentage = await _habitService.calculateMonthlyCompletionPercentage();
      if (!mounted) return;

      debugPrint('Procent ukończenia w miesiącu: $monthlyCompletionPercentage%');

      if (mounted) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Błąd w _loadStatistics: $e');
    }
  }

  // Oblicz procent ukończenia dla każdego dnia tygodnia
  Map<String, double> getWeeklyProgressPercentage(S localizations) {
    final Map<String, double> weeklyProgressPercentage = {};
    final fullDays = [
      localizations.monday,
      localizations.tuesday,
      localizations.wednesday,
      localizations.thursday,
      localizations.friday,
      localizations.saturday,
      localizations.sunday
    ];

    // Oblicz procent ukończenia dla każdego dnia tygodnia
    for (int i = 0; i < 7; i++) {
      final completionsCount = completionsByDay[i] ?? 0;
      final dayActiveHabits = activeHabitsByDay[i] ?? 0;

      if (dayActiveHabits > 0) {
        weeklyProgressPercentage[fullDays[i]] = (completionsCount / dayActiveHabits) * 100;
      } else {
        weeklyProgressPercentage[fullDays[i]] = 0.0;
      }

      debugPrint('Dzień ${fullDays[i]}: '
          'completed=$completionsCount, active=$dayActiveHabits, '
          'progress=${weeklyProgressPercentage[fullDays[i]]}%');
    }

    return weeklyProgressPercentage;
  }


  String getMostActiveDayName(S localizations) {
    switch (mostActiveDay) {
      case 1: return localizations.monday;
      case 2: return localizations.tuesday;
      case 3: return localizations.wednesday;
      case 4: return localizations.thursday;
      case 5: return localizations.friday;
      case 6: return localizations.saturday;
      case 7: return localizations.sunday;
      default: return '';
    }
  }

  double getMonthlyCompletionPercentage(int month) {
    final completed = completionsByMonth[month] ?? 0;
    final active = activeHabitsByDay.values.fold(0, (sum, count) => sum + count);
    return active > 0 ? (completed / active) * 100 : 0.0;
  }

  Future<double> calculateCompletionPercentageFromDecember2024() async {
    final startDate = DateTime(2024, 12, 1);
    final habits = await _habitService.getHabitsFromDate(startDate);
    final completions = await _habitService.getAllCompletions();

    int totalHabits = 0;
    int completedHabits = 0;

    for (var habit in habits) {
      final data = habit.data() as Map<String, dynamic>;
      final selectedDays = data['selectedDays'] as List<int>;
      final habitStartDate = (data['startDate'] as Timestamp).toDate();

      if (habitStartDate.isAfter(startDate)) {
        totalHabits += selectedDays.length;

        for (var completion in completions) {
          final completionData = completion.data() as Map<String, dynamic>;
          final completionDate = (completionData['updatedAt'] as Timestamp).toDate();

          if (completionDate.isAfter(startDate) && completionData['isCompleted'] == true) {
            completedHabits++;
          }
        }
      }
    }

    return totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0.0;
  }

  Future<double> calculateCompletionPercentage(DateTime startDate, DateTime endDate) async {
    return await _habitService.calculateCompletionPercentage(startDate, endDate);
  }

  Future<double> calculateCompletionPercentageFromStartOfMonth() async {
    return await _habitService.calculateCompletionPercentageFromStartOfMonth();
  }

  double calculateMonthlyProgress(int month) {
    final now = DateTime.now();
    
    // Początek miesiąca
    final startOfMonth = DateTime(now.year, month, 1);
    final today = now.month == month ? now.day : DateTime(now.year, month + 1, 0).day;

    int totalActive = 0; // Wszystkie aktywne nawyki od początku miesiąca
    int totalCompleted = 0; // Wszystkie ukończone nawyki od początku miesiąca

    for (int day = 1; day <= today; day++) {
      final date = DateTime(now.year, month, day);
      final weekday = (date.weekday + 6) % 7; // Mapowanie dni tygodnia (0-poniedziałek)

      // Pobierz liczbę aktywnych nawyków dla tego dnia
      final activeHabitsForDay = activeHabitsByDay[weekday] ?? 0;
      final completedHabitsForDay = completionsByDay[weekday] ?? 0;

      totalActive += activeHabitsForDay;
      totalCompleted += completedHabitsForDay;
    }

    // Oblicz procent wykonania
    return totalActive > 0 ? (totalCompleted / totalActive) * 100 : 0.0;
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    final fontSize = MyApp.of(context)?.fontSize ?? 16.0; // Pobierz rozmiar czcionki z MyApp

    return ChangeNotifierProvider(
      create: (_) => ProgressPageState(context.read<HabitService>()),
      child: Consumer<ProgressPageState>(
        builder: (context, state, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.progressTitle, style: TextStyle(color: Colors.white, fontSize: fontSize)),
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.summaryToday,
                    style: TextStyle(fontSize: fontSize + 8, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth / (kIsWeb ? 4 : 2) - 16; // Zmienna szerokość kart

                      return Center(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildStatisticCard(localizations.activeHabits, state.activeHabits.toString(), textColor, cardWidth, fontSize),
                            _buildStatisticCard(localizations.completedTasks, state.completedHabits.toString(), textColor, cardWidth, fontSize),
                            _buildStatisticCard(localizations.successRate, '${state.successRate.toStringAsFixed(1)}%', textColor, cardWidth, fontSize),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.weeklyProgress,
                    style: TextStyle(fontSize: fontSize + 8, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  _buildWeeklyProgressPercentage(state.getWeeklyProgressPercentage(localizations), textColor, fontSize),
                  const SizedBox(height: 20),
                  _buildWeeklyBarChart(state.getWeeklyProgressPercentage(localizations), localizations, textColor, fontSize),
                  const SizedBox(height: 20),
                  Text(
                    '${localizations.mostActiveDay}: ${state.getMostActiveDayName(localizations)}',
                    style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${localizations.totalHabits}: ${state.totalHabits}',
                    style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 40), // Zwiększ odstęp
                  Text(
                    localizations.yearlyProgress,
                    style: TextStyle(fontSize: fontSize + 8, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  _buildYearlyProgressChart(context, localizations, textColor, fontSize),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, Color textColor, double width, double fontSize) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize - 1, fontWeight: FontWeight.bold, color: textColor), // Zmniejsz rozmiar czcionki
              ),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize + 6, fontWeight: FontWeight.bold, color: textColor), // Zmniejsz rozmiar czcionki
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressPercentage(Map<String, double> weeklyProgressPercentage, Color textColor, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeklyProgressPercentage.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: TextStyle(fontSize: fontSize + 2, color: textColor),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyBarChart(Map<String, double> weeklyProgressPercentage, S localizations, Color textColor, double fontSize) {
    final shortDays = [
      localizations.mondayShort,
      localizations.tuesdayShort,
      localizations.wednesdayShort,
      localizations.thursdayShort,
      localizations.fridayShort,
      localizations.saturdayShort,
      localizations.sundayShort
    ];
    final fullDays = [
      localizations.monday,
      localizations.tuesday,
      localizations.wednesday,
      localizations.thursday,
      localizations.friday,
      localizations.saturday,
      localizations.sunday
    ];
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          maxY: 100,
          alignment: BarChartAlignment.spaceAround,
          barGroups: fullDays.asMap().entries.map((entry) {
            final dayIndex = entry.key;
            final dayName = entry.value;
            final progress = weeklyProgressPercentage[dayName] ?? 0.0;
            return BarChartGroupData(
              x: dayIndex,
              barRods: [
                BarChartRodData(
                  toY: progress,
                  color: progress > 0 ? Colors.blue : Colors.transparent,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: Colors.grey[300],
                  ),
                ),
              ],
              showingTooltipIndicators: [],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%', style: TextStyle(color: textColor, fontSize: fontSize - 2));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < shortDays.length) {
                    return Text(shortDays[value.toInt()], style: TextStyle(color: textColor, fontSize: fontSize - 2));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${fullDays[group.x]}: ${rod.toY.toStringAsFixed(1)}%',
                  TextStyle(color: Colors.white, fontSize: fontSize - 2),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyProgressChart(BuildContext context, S localizations, Color textColor, double fontSize) {
    final months = [
      localizations.january,
      localizations.february,
      localizations.march,
      localizations.april,
      localizations.may,
      localizations.june,
      localizations.july,
      localizations.august,
      localizations.september,
      localizations.october,
      localizations.november,
      localizations.december
    ];
    final habitService = context.read<HabitService>();
    return FutureBuilder<Map<String, double>>(
      future: habitService.getYearlyCompletionPercentage(localizations),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(localizations.noActiveHabits, style: TextStyle(color: textColor, fontSize: fontSize));
        }
        final yearlyProgress = snapshot.data!;
        return Column(
          children: months.map((month) {
            final progress = yearlyProgress[month] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: TextStyle(fontSize: fontSize + 2, color: textColor),
                  ),
                  Text(
                    '${progress.isNaN ? 0.0 : progress.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
