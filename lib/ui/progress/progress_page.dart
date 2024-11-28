// lib/ui/progress/progress_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Dodajemy bibliotekę do wykresów

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki i postępy'),
        backgroundColor: Color.fromARGB(255, 255, 253, 208), // Delikatny żółty kolor
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
              'Twoje postępy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildLineChart(),
            const SizedBox(height: 20),
            const Text(
              'Statystyki',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildStatisticCard('Dni z rzędu', '5')),
                Expanded(child: _buildStatisticCard('Ukończone nawyki', '12')),
                Expanded(child: _buildStatisticCard('Procent sukcesu', '80%')),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Szczegółowe dane',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBarChart(),
            const SizedBox(height: 20),
            const Text(
              'Ostatnie aktywności',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRecentActivities(),
            const SizedBox(height: 20),
            const Text(
              'Cele na przyszłość',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFutureGoals(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 5),
                FlSpot(4, 3),
                FlSpot(5, 4),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.lightBlueAccent)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlueAccent)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.lightBlueAccent)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.lightBlueAccent)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.lightBlueAccent)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: Colors.lightBlueAccent)]),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
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

  Widget _buildRecentActivities() {
    return Column(
      children: List.generate(5, (index) {
        return ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('Aktywność ${index + 1}'),
          subtitle: Text('Opis aktywności ${index + 1}'),
        );
      }),
    );
  }

  Widget _buildFutureGoals() {
    return Column(
      children: List.generate(3, (index) {
        return ListTile(
          leading: Icon(Icons.flag, color: Colors.blue),
          title: Text('Cel ${index + 1}'),
          subtitle: Text('Opis celu ${index + 1}'),
        );
      }),
    );
  }
}