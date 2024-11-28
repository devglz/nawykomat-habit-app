// lib/services/user_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get userStream => _auth.authStateChanges();

  // Podstawowe gettery
  String get userEmail => currentUser?.email ?? 'Brak email';
  String get userName => currentUser?.displayName ?? 'Użytkownik';
  String get userId => currentUser?.uid ?? '';

  // Pobieranie dodatkowych danych użytkownika
  Future<Map<String, dynamic>> getUserData() async {
    try {
      if (userId.isEmpty) return {};
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Błąd podczas pobierania danych użytkownika: $e');
      return {};
    }
  }

  // Aktualizacja danych użytkownika
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (userId.isEmpty) return;
      await _firestore.collection('users').doc(userId).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Błąd podczas aktualizacji danych: $e');
      rethrow;
    }
  }

  // Aktualizacja ustawień powiadomień
  Future<void> updateNotificationSettings(bool enabled) async {
    try {
      await updateUserData({'notificationsEnabled': enabled});
    } catch (e) {
      print('Błąd podczas aktualizacji ustawień powiadomień: $e');
      rethrow;
    }
  }

  // Usuwanie konta
  Future<void> deleteAccount() async {
    try {
      if (userId.isEmpty) return;
      await _firestore.collection('users').doc(userId).delete();
      await currentUser?.delete();
    } catch (e) {
      print('Błąd podczas usuwania konta: $e');
      rethrow;
    }
  }

  // Inicjalizacja danych użytkownika
  Future<void> initializeUserData() async {
    try {
      if (userId.isEmpty) return;
      final userData = {
        'email': userEmail,
        'name': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'notificationsEnabled': true,
      };
      await updateUserData(userData);
    } catch (e) {
      print('Błąd podczas inicjalizacji danych użytkownika: $e');
      rethrow;
    }
  }
}