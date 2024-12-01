import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addHabit(
    String name,
    int progress,
    Timestamp startDate,
    bool isCompleted,
    String timeOfDay,
    String dayArea,
    List<String> reminders,
    List<int> selectedDays,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('habits').add({
        'name': name,
        'progress': progress,
        'startDate': startDate,
        'isCompleted': isCompleted,
        'timeOfDay': timeOfDay,
        'dayArea': dayArea,
        'reminders': reminders,
        'selectedDays': selectedDays,
        'createdAt': Timestamp.now(),
      });
    }
  }

 Future<void> updateHabit(
  String habitId,
  int progress,
  Timestamp startDate,
  bool isCompleted,
  List<int> selectedDays,  // Zmiana typu argumentu na List<int>
) async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Aktualizacja dokumentu nawyku w Firestore
      await _firestore.collection('users').doc(user.uid).collection('habits').doc(habitId).update({
        'progress': progress,          // Aktualizacja postępu
        'startDate': startDate,        // Aktualizacja daty rozpoczęcia
        'isCompleted': isCompleted,    // Aktualizacja statusu ukończenia
        'selectedDays': selectedDays,  // Zaktualizowanie listy dni
      });
    } catch (e) {
      // Obsługa błędów (np. jeśli dokument nie istnieje)
      print('Error updating habit: $e');
    }
  }
}

 Future<void> deleteHabit(String habitId) async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Usunięcie dokumentu nawyku
      await _firestore.collection('users').doc(user.uid).collection('habits').doc(habitId).delete();
    } catch (e) {
      // Obsługa błędów (np. jeśli dokument nie istnieje)
      print('Error deleting habit: $e');
    }
  }
}


   Stream<QuerySnapshot> getHabits() {
    final user = _auth.currentUser;
    if (user != null) {
      // Sprawdzamy, czy użytkownik jest zalogowany
      return _firestore
          .collection('users') // Kolekcja użytkowników
          .doc(user.uid) // Dokument konkretnego użytkownika (po uid)
          .collection('habits') // Kolekcja nawyków
          .orderBy('createdAt') // Sortowanie po dacie utworzenia
          .snapshots(); // Odczyt na żywo - stream
    }
    return const Stream.empty(); // Jeśli użytkownik nie jest zalogowany, zwracamy pusty stream
  }
}