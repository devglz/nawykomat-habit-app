import 'package:flutter/material.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_app/services/notification_service.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje Nawyki'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addHabit');
            },
          ),
        ],
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

          // Logowanie pobranych dokumentów
          for (var doc in snapshot.data!.docs) {
            debugPrint('Dokument ID: ${doc.id}');
            debugPrint('Dane: ${doc.data()}');
          }

          final habits = snapshot.data!.docs;
          NotificationService().scheduleNotifications(habits); // Przeniesienie logiki powiadomień
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final data = habit.data() as Map<String, dynamic>;

              // Sprawdź, czy dokument zawiera wymagane pola
              if (!data.containsKey('title')) {
                return const ListTile(
                  title: Text('Niepełne dane'),
                  subtitle: Text('Brakuje wymaganych informacji'),
                );
              }

              try {
                final title = data['title'];
                final progress = data['progress'] ?? 0;
                final isCompleted = data['isCompleted'] ?? false;

                return ListTile(
                  title: Text(title),
                  subtitle: Text('Postęp: $progress dni'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) async {
                          await HabitService().updateHabit(
                            habit.id,
                            {
                              'title': title,
                              'progress': progress + (value == true ? 1 : -1),
                              'startDate': data['startDate'],
                              'isCompleted': value ?? false,
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/editHabit',
                            arguments: habit,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await HabitService().deleteHabit(habit.id);
                        },
                      ),
                    ],
                  ),
                );
              } catch (e) {
                debugPrint('Błąd odczytu dokumentu: ${habit.id}, błąd: $e');
                return const ListTile(
                  title: Text('Błąd danych'),
                  subtitle: Text('Nie można odczytać danych dla tego dokumentu'),
                );
              }
            },
          );
        },
      ),
    );
  }
}