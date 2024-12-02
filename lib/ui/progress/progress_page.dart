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
    }
  }

  // Dodaj metodę do obliczania procentowego postępu dla każdego dnia tygodnia
  Map<String, double> getWeeklyProgressPercentage() {
    final Map<String, double> weeklyProgressPercentage = {};
    const days = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];
    for (int i = 1; i <= 7; i++) {
      final completionsCount = completionsByDay[i] ?? 0;
      weeklyProgressPercentage[days[i - 1]] = (completionsCount / activeHabits) * 100;
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
              backgroundColor: const Color(0xFF6750A4),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: _buildStatisticCard('Aktywne nawyki', state.activeHabits.toString())),
                      Expanded(child: _buildStatisticCard('Ukończone zadania', state.completedHabits.toString())),
                      Expanded(child: _buildStatisticCard('Procent sukcesu', '${state.successRate.toStringAsFixed(1)}%')),
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
                  const SizedBox(height: 20),
                  const Text(
                    'Nawyki miesięczne',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildMonthlyHabitCharts(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
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
    const days = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          maxY: 100,
          alignment: BarChartAlignment.spaceAround,
          barGroups: days.asMap().entries.map((entry) {
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
                  if (value >= 0 && value < days.length) {
                    return Text(days[value.toInt()], style: TextStyle(color: Colors.black));
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
                  '${days[group.x]}: ${rod.toY.toStringAsFixed(1)}%',
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyHabitCharts(BuildContext context) {
    final habitService = context.read<HabitService>();
    return FutureBuilder<QuerySnapshot>(
      future: habitService.getHabits().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('Brak nawyków do wyświetlenia');
        }

        final habits = snapshot.data!.docs;
        return Column(
          children: habits.map((habit) {
            final habitData = habit.data() as Map<String, dynamic>;
            final habitName = habitData['name'] as String;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habitName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildMonthlyBarChart(context, habit.id),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMonthlyBarChart(BuildContext context, String habitId) {
    return FutureBuilder<Map<DateTime, bool>>(
      future: context.read<HabitService>().getMonthlyCompletionStatus(habitId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final now = DateTime.now();
        final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        final monthlyStatus = snapshot.data ?? {};
        final spots = List.generate(daysInMonth, (index) {
          final day = index + 1;
          final date = DateTime(now.year, now.month, day);
          final isCompleted = monthlyStatus[date] ?? false;
          return FlSpot(day.toDouble(), isCompleted ? 100 : 0);
        });

        return SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}');
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}