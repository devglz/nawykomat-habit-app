import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/services/habit_service.dart';



class ProgressPageState extends ChangeNotifier {
  final HabitService _habitService;
  int activeHabits = 0;
  int completedHabits = 0;
  int longestStreak = 0;
  double successRate = 0.0;
  Map<int, int> completionsByDay = {};
  int mostActiveDay = 1;
  List<FlSpot> weeklyProgress = [];

  ProgressPageState(this._habitService) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      // Pobierz dane asynchronicznie
      final activeHabitsCount = await _habitService.getActiveHabitsCount();
      final completions = await _habitService.getAllCompletions();

      // Aktualizuj stan
      activeHabits = activeHabitsCount;
      completedHabits = completions.length;

      // Oblicz procent sukcesu na podstawie dzisiejszych danych
      final today = DateTime.now();
      final todayCompletions = completions.where((completion) {
        final data = completion.data() as Map<String, dynamic>;
        final date = (data['updatedAt'] as Timestamp).toDate();
        return date.year == today.year && date.month == today.month && date.day == today.day;
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

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      activeHabits = 0;
      completedHabits = 0;
      successRate = 0.0;
      completionsByDay.clear();
      weeklyProgress.clear();
      notifyListeners();
    }
  }

  // Dodaj metodę do obliczania procentowego postępu dla każdego dnia tygodnia
  Map<String, double> getWeeklyProgressPercentage() {
    final Map<String, double> weeklyProgressPercentage = {};
    const fullDays = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];
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

  String getMostActiveDayName() {
    switch (mostActiveDay) {
      case 1: return 'Poniedziałek';
      case 2: return 'Wtorek';
      case 3: return 'Środa';
      case 4: return 'Czwartek';
      case 5: return 'Piątek';
      case 6: return 'Sobota';
      case 7: return 'Niedziela';
      default: return '';
    }
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressPageState(context.read<HabitService>()),
      child: Consumer<ProgressPageState>(
        builder: (context, state, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Statystyki i postępy', style: TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
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
                  const Text(
                    'Podsumowanie dzisiaj',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatisticCard('Aktywne nawyki', state.activeHabits.toString()),
                      _buildStatisticCard('Ukończone zadania', state.completedHabits.toString()),
                      _buildStatisticCard('Procent sukcesu', '${state.successRate.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Postęp tygodniowy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildWeeklyProgressPercentage(state.getWeeklyProgressPercentage()),
                  const SizedBox(height: 20),
                  _buildWeeklyBarChart(state.getWeeklyProgressPercentage()),
                  const SizedBox(height: 20),
                  Text(
                    'Najbardziej aktywny dzień: ${state.getMostActiveDayName()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40), // Zwiększ odstęp
                  const Text(
                    'Procent wykonania nawyków od stycznia do grudnia',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildYearlyProgressChart(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value) {
    return SizedBox(
      width: 130, // Ustal szerokość kart
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Zmniejsz rozmiar czcionki
              ),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Zmniejsz rozmiar czcionki
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressPercentage(Map<String, double> weeklyProgressPercentage) {
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
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyBarChart(Map<String, double> weeklyProgressPercentage) {
    const shortDays = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Ndz'];
    const fullDays = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];
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
                  return Text('${value.toInt()}%', style: TextStyle(color: Colors.black));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < shortDays.length) {
                    return Text(shortDays[value.toInt()], style: TextStyle(color: Colors.black));
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

  Widget _buildYearlyProgressChart(BuildContext context) {
    final months = ['Styczeń', 'Luty', 'Marzec', 'Kwiecień', 'Maj', 'Czerwiec', 'Lipiec', 'Sierpień', 'Wrzesień', 'Październik', 'Listopad', 'Grudzień'];
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
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${progress.isNaN ? 0.0 : progress.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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