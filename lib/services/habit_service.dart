import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _habitsCollection = FirebaseFirestore.instance.collection('habits');

  String? get _userId => _auth.currentUser?.uid;

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

  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('habits').doc(habitId).update(data);
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

  Stream<QuerySnapshot> getHabitsByDayArea(String dayArea) {
    if (_userId == null) return Stream.value([] as QuerySnapshot);
    
    return _habitsCollection
        .where('userId', isEqualTo: _userId)
        .where('dayArea', isEqualTo: dayArea)
        .snapshots();
  }

  Future<void> toggleHabitCompletion(String habitId, bool currentStatus) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    try {
      print('Trying to toggle habit: $habitId'); // Debug log
      
      final habitRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId);

      // Sprawdź czy dokument istnieje
      final doc = await habitRef.get();
      if (!doc.exists) {
        print('Habit document not found: $habitId'); // Debug log
        throw Exception('Nawyk nie istnieje');
      }

      await habitRef.update({
        'isCompleted': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Successfully toggled habit completion: $habitId'); // Debug log
    } catch (e) {
      print('Error toggling habit completion: $e');
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getAllCompletions() async {
    final user = _auth.currentUser;
    if (user != null) {
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('isCompleted', isEqualTo: true)
          .get();
      return habitsSnapshot.docs;
    }
    return [];
  }

  Future<int> getActiveHabitsCount() async {
    final user = _auth.currentUser;
    if (user != null) {
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();
      return habitsSnapshot.docs.length;
    }
    return 0;
  }

  Future<Map<DateTime, double>> getMonthlyCompletionRates() async {
    final user = _auth.currentUser;
    if (user != null) {
      final habits = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();

      Map<DateTime, int> totalByDate = {};
      Map<DateTime, int> completedByDate = {};

      for (var habit in habits.docs) {
        final data = habit.data();
        final startDate = (data['startDate'] as Timestamp).toDate();
        final now = DateTime.now();
        
        // Pobierz wszystkie uzupełnienia dla tego nawyku
        final completions = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc(habit.id)
            .collection('completions')
            .get();

        for (var completion in completions.docs) {
          final date = (completion.data()['date'] as Timestamp).toDate();
          final dateKey = DateTime(date.year, date.month, date.day);
          completedByDate[dateKey] = (completedByDate[dateKey] ?? 0) + 1;
          totalByDate[dateKey] = (totalByDate[dateKey] ?? 0) + 1;
        }
      }

      // Oblicz procent ukończenia dla każdego dnia
      Map<DateTime, double> completionRates = {};
      totalByDate.forEach((date, total) {
        final completed = completedByDate[date] ?? 0;
        completionRates[date] = completed / total;
      });

      return completionRates;
    }
    return {};
  }

  Future<Map<int, double>> getMonthlyComparison() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
      
      final habits = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
          .get();

      Map<int, int> totalByMonth = {};
      Map<int, int> completedByMonth = {};

      for (var habit in habits.docs) {
        // Podobna logika jak powyżej, ale grupowanie po miesiącach
        // ...
      }

      // Oblicz procent ukończenia dla każdego miesiąca
      Map<int, double> monthlyRates = {};
      totalByMonth.forEach((month, total) {
        final completed = completedByMonth[month] ?? 0;
        monthlyRates[month] = total > 0 ? completed / total : 0;
      });

      return monthlyRates;
    }
    return {};
  }

  Future<Map<DateTime, bool>> getMonthlyCompletionStatus(String habitId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final completions = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .collection('completions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      Map<DateTime, bool> completionStatus = {};
      for (var completion in completions.docs) {
        final date = (completion.data()['date'] as Timestamp).toDate();
        final dateKey = DateTime(date.year, date.month, date.day);
        completionStatus[dateKey] = true;
      }

      return completionStatus;
    }
    return {};
  }
}