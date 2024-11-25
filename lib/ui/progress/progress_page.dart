import 'package:flutter/material.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Śledzenie Postępów'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final data = habit.data() as Map<String, dynamic>;
              final title = data['title'];
              final progress = data['progress'] ?? 0;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Postęp: $progress dni'),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: progress.toDouble(),
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}