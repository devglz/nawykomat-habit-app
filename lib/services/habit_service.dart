import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Dodano import

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addHabit(
    String name,
    String title, // zostawiamy parametry ale nie używamy ich w bazie
    String description,
    int progress,
    Timestamp startDate,
    bool isCompleted,
    String repeatCycle,
    String goal,
    String timeOfDay,
    String dayArea,
    List<TimeOfDay?> reminders, // Lista nullable TimeOfDay
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('habits').add({
        'name': name,
        'startDate': startDate,
        'isCompleted': isCompleted,
        'repeatCycle': repeatCycle,
        'goal': goal,
        'timeOfDay': timeOfDay,
        'dayArea': dayArea,
        'reminders': reminders
            .where((reminder) => reminder != null) // Filtruj null
            .map((reminder) => '${reminder!.hour}:${reminder.minute}')
            .toList(),
      });
    }
  }

  Future<void> updateHabit(
    String habitId,
    String title,
    String description,
    int progress,
    Timestamp startDate,
    bool isCompleted,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('habits').doc(habitId).update({
        'title': title,
        'description': description,
        'progress': progress,
        'startDate': startDate,
        'isCompleted': isCompleted,
      });
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('habits').doc(habitId).delete();
    }
  }

  Stream<QuerySnapshot> getHabits() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('habits').orderBy('createdAt').snapshots();
    }
    return const Stream.empty();
  }
}
