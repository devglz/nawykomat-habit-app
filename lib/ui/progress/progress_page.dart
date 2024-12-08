import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:habit_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart'; // Dodaj ten import

class ProgressPageState extends ChangeNotifier {
  final HabitService _habitService;
  int activeHabits = 0;
  int completedHabits = 0;
  int longestStreak = 0;
  double successRate = 0.0;
  Map<int, int> completionsByDay = {};
  int mostActiveDay = 1;
  List<FlSpot> weeklyProgress = [];
  int totalHabits = 0; // Dodaj zmienną do przechowywania liczby wszystkich nawyków

  ProgressPageState(this._habitService) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final today = DateTime.now().weekday - 1; // Pobierz dzisiejszy dzień tygodnia (0 - poniedziałek, 1 - wtorek, itd.)

      // Pobierz dane asynchronicznie
      final activeHabitsCount = await _habitService.getActiveHabitsCountForDay(today);
      final completions = await _habitService.getAllCompletions();

      // Aktualizuj stan
      activeHabits = activeHabitsCount;
      completedHabits = completions.length;

      // Oblicz procent sukcesu na podstawie dzisiejszych danych
      final todayCompletions = completions.where((completion) {
        final data = completion.data() as Map<String, dynamic>;
        final date = (data['updatedAt'] as Timestamp).toDate();
        return date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
      }).length;

      if (activeHabits > 0) {
        successRate = (todayCompletions / activeHabits) * 100;
      } else {
        successRate = 0.0;
      }

      // Oblicz statystyki dzienne
      Map<DateTime, int> dailyCompletions = {};
      for (var completion in completions) {
        final data = completion.data() as Map<String, dynamic>;
        final date = (data['updatedAt'] as Timestamp).toDate();
        dailyCompletions[date] = (dailyCompletions[date] ?? 0) + 1;
        completionsByDay[date.weekday] = (completionsByDay[date.weekday] ?? 0) + 1;
      }

      // Znajdź najbardziej aktywny dzień
      int maxCompletions = 0;
      completionsByDay.forEach((day, dayCount) {
        if (dayCount > maxCompletions) {
          maxCompletions = dayCount;
          mostActiveDay = day;
        }
      });

      // Oblicz postęp tygodniowy
      weeklyProgress.clear();
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final completionsCount = dailyCompletions[date] ?? 0;
        weeklyProgress.add(FlSpot(6-i.toDouble(), completionsCount.toDouble()));
      }

      // Pobierz liczbę wszystkich nawyków
      totalHabits = await _habitService.getActiveHabitsCount();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      activeHabits = 0;
      completedHabits = 0;
      successRate = 0.0;
      completionsByDay.clear();
      weeklyProgress.clear();
      totalHabits = 0;
      notifyListeners();
    }
  }

  // Dodaj metodę do obliczania procentowego postępu dla każdego dnia tygodnia
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
    for (int i = 1; i <= 7; i++) {
      final completionsCount = completionsByDay[i] ?? 0;
      if (activeHabits > 0) {
        weeklyProgressPercentage[fullDays[i - 1]] = (completionsCount / activeHabits) * 100;
      } else {
        weeklyProgressPercentage[fullDays[i - 1]] = 0.0;
      }
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
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return ChangeNotifierProvider(
      create: (_) => ProgressPageState(context.read<HabitService>()),
      child: Consumer<ProgressPageState>(
        builder: (context, state, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(localizations.progressTitle, style: TextStyle(color: Colors.white)),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
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
                            _buildStatisticCard(localizations.activeHabits, state.activeHabits.toString(), textColor, cardWidth),
                            _buildStatisticCard(localizations.completedTasks, state.completedHabits.toString(), textColor, cardWidth),
                            _buildStatisticCard(localizations.successRate, '${state.successRate.toStringAsFixed(1)}%', textColor, cardWidth),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.weeklyProgress,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  _buildWeeklyProgressPercentage(state.getWeeklyProgressPercentage(localizations), textColor),
                  const SizedBox(height: 20),
                  _buildWeeklyBarChart(state.getWeeklyProgressPercentage(localizations), localizations, textColor),
                  const SizedBox(height: 20),
                  Text(
                    '${localizations.mostActiveDay}: ${state.getMostActiveDayName(localizations)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${localizations.totalHabits}: ${state.totalHabits}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 40), // Zwiększ odstęp
                  Text(
                    localizations.habitCompletionPercentage,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  _buildYearlyProgressChart(context, localizations, textColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, Color textColor, double width) {
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor), // Zmniejsz rozmiar czcionki
              ),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor), // Zmniejsz rozmiar czcionki
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressPercentage(Map<String, double> weeklyProgressPercentage, Color textColor) {
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
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyBarChart(Map<String, double> weeklyProgressPercentage, S localizations, Color textColor) {
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
                  return Text('${value.toInt()}%', style: TextStyle(color: textColor));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < shortDays.length) {
                    return Text(shortDays[value.toInt()], style: TextStyle(color: textColor));
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
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyProgressChart(BuildContext context, S localizations, Color textColor) {
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
      future: habitService.getYearlyCompletionPercentage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final yearlyProgress = snapshot.data ?? {};
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
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  Text(
                    '${progress.isNaN ? 0.0 : progress.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
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