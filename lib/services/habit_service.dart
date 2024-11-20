import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addHabit(String title, String description, int progress, Timestamp startDate, bool isCompleted) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('habits').add({
        'title': title,
        'description': description,
        'progress': progress,
        'startDate': startDate,
        'isCompleted': isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateHabit(String habitId, String title, String description, int progress, Timestamp startDate, bool isCompleted) async {
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