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
}