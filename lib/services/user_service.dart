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

  // Usuwanie danych użytkownika
  Future<void> deleteUserData() async {
    try {
      if (userId.isEmpty) return;
      await _firestore.collection('users').doc(userId).delete();
      print('Dane użytkownika zostały usunięte.');
    } catch (e) {
      print('Wystąpił błąd podczas usuwania danych: $e');
      rethrow;
    }
  }

  // Usuwanie konta
  Future<void> deleteAccount(String email, String password) async {
    try {
      if (userId.isEmpty) return;
      await reauthenticateUser(email, password);
      await deleteUserData();
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        print('Konto zostało usunięte.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('Użytkownik musi ponownie się zalogować przed usunięciem konta.');
      } else {
        print('Wystąpił błąd: ${e.message}');
      }
      rethrow;
    } catch (e) {
      print('Błąd podczas usuwania konta: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Brak zalogowanego użytkownika.');
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'Użytkownik nie jest zalogowany.',
        );
      }

      print('Ponawiam uwierzytelnienie dla: $email');
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
      print('Ponowne logowanie zakończone sukcesem.');
    } on FirebaseAuthException catch (e) {
      print('Błąd ponownego logowania: ${e.code} - ${e.message}');
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

  // Obliczanie procentu ukończenia zadań w danym miesiącu
  Future<double> calculateMonthlyCompletionPercentage(int year, int month) async {
    try {
      if (userId.isEmpty) return 0.0;
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0);

      print('Zakres dat: $startOfMonth - $endOfMonth');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('completedAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('completedAt', isLessThanOrEqualTo: endOfMonth)
          .get();

      for (var doc in querySnapshot.docs) {
        print(doc.data()); // Wyświetla dane każdego zadania
      }

      final totalTasks = querySnapshot.docs.length;
      if (totalTasks == 0) return 0.0;

      final completedTasks = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final isCompleted = data['isCompleted'] == true;
            final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
            print('isCompleted: $isCompleted, completedAt: $completedAt');
            return isCompleted;
          })
          .length;

      print('Liczba zadań: $totalTasks');
      print('Ukończone zadania: $completedTasks');

      return (completedTasks / totalTasks) * 100;
    } catch (e) {
      print('Błąd podczas obliczania procentu ukończenia zadań: ${e.toString()}');
      return 0.0;
    }
  }
}