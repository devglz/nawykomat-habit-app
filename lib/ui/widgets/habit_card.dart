import 'package:flutter/material.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Dodaj import dla Timestamp

class HabitCard extends StatelessWidget {
  final String habitId;
  final String title;
  final String description;
  final int progress;
  final bool isCompleted;
  final bool isCompletedStyle;

  const HabitCard({
    required this.habitId,
    required this.title,
    required this.description,
    required this.progress,
    required this.isCompleted,
    this.isCompletedStyle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: isCompletedStyle ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
        ),
        subtitle: Text('Opis: $description, Postęp: $progress dni'),
        trailing: Wrap(
          spacing: 12,
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (bool? value) async {
                await HabitService().updateHabit(
                  habitId,
                  title,
                  description,
                  progress + (value == true ? 1 : -1),
                  Timestamp.fromDate(DateTime.now()), // Konwertuj DateTime na Timestamp
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
                  arguments: habitId,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await HabitService().deleteHabit(habitId);
              },
            ),
          ],
        ),
      ),
    );
  }
}