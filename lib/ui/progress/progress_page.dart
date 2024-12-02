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

      // Oblicz procent sukcesu
      if (activeHabits > 0) {
        successRate = (completedHabits / (activeHabits * 7)) * 100;
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
                    'Podsumowanie ogólne',
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
                  _buildLineChart(state.weeklyProgress),
                  const SizedBox(height: 20),
                  Text(
                    'Najbardziej aktywny dzień: ${state.getMostActiveDayName()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots) {
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
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Nd'];
                if (value >= 0 && value < days.length) {
                  return Text(days[value.toInt()]);
                }
                return const Text('');
              },
            )),
          ),
        ),
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
}
