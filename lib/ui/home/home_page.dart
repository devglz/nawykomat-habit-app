import 'package:flutter/material.dart';
import 'package:habit_app/services/auth_service.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekran główny'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

          final habits = snapshot.data!.docs;
          final activeHabits = habits.where((habit) => !(habit.data() as Map<String, dynamic>)['isCompleted']).toList();
          final completedHabits = habits.where((habit) => (habit.data() as Map<String, dynamic>)['isCompleted']).toList();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Aktywne Nawyki',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...activeHabits.map((habit) {
                final data = habit.data() as Map<String, dynamic>;
                final title = data['title'];
                final description = data['description'];
                final progress = data['progress'] ?? 0;
                final isCompleted = data['isCompleted'] ?? false;

                return ListTile(
                  title: Text(title),
                  subtitle: Text('Opis: $description, Postęp: $progress dni'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) async {
                          await HabitService().updateHabit(
                            habit.id,
                            title,
                            description,
                            progress + (value == true ? 1 : -1),
                            data['startDate'],
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
              }).toList(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Zrobione Nawyki',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...completedHabits.map((habit) {
                final data = habit.data() as Map<String, dynamic>;
                final title = data['title'];
                final description = data['description'];
                final progress = data['progress'] ?? 0;
                final isCompleted = data['isCompleted'] ?? false;

                return ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  subtitle: Text('Opis: $description, Postęp: $progress dni'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) async {
                          await HabitService().updateHabit(
                            habit.id,
                            title,
                            description,
                            progress + (value == true ? 1 : -1),
                            data['startDate'],
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
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addHabit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}