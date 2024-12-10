import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj ten import

class Habit {
  final String id;
  final String name;
  final int progress;
  final Timestamp startDate;
  final bool isCompleted;
  final String timeOfDay;
  final String dayArea;
  final List<String> reminders;
  final List<int> selectedDays;

  Habit({
    required this.id,
    required this.name,
    required this.progress,
    required this.startDate,
    required this.isCompleted,
    required this.timeOfDay,
    required this.dayArea,
    required this.reminders,
    required this.selectedDays,
  });

  factory Habit.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      name: data['name'],
      progress: data['progress'],
      startDate: data['startDate'],
      isCompleted: data['isCompleted'],
      timeOfDay: data['timeOfDay'],
      dayArea: data['dayArea'],
      reminders: List<String>.from(data['reminders']),
      selectedDays: List<int>.from(data['selectedDays']),
    );
  }
}

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
        'updatedAt': Timestamp.now(), // Dodaj pole updatedAt
      });
    }
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      data['updatedAt'] = Timestamp.now(); // Aktualizuj pole updatedAt
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
        if (!currentStatus) 'completedID': FieldValue.serverTimestamp(), // Aktualizuj completedID, jeśli nawyk jest ukończony
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
      try {
        final habitsSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .where('isCompleted', isEqualTo: true)
            .get();
        
        debugPrint('Znalezione ukończenia: ${habitsSnapshot.docs.length}');
        return habitsSnapshot.docs;
      } catch (e) {
        debugPrint('Błąd podczas pobierania ukończeń: $e');
        return [];
      }
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
          final data = completion.data();
          if (data['updatedAt'] == null || data['updatedAt'] is! Timestamp) {
            debugPrint('Brak pola updatedAt w dokumencie: ${completion.id}');
            continue;
          }
          if (data['isCompleted'] == null || data['isCompleted'] is! bool) {
            debugPrint('Brak pola isCompleted w dokumencie: ${completion.id}');
            continue;
          }
          final updatedAt = (data['updatedAt'] as Timestamp).toDate();
          final weekday = (updatedAt.weekday + 6) % 7; // Poniedziałek = 0, ..., Niedziela = 6
          completedByDate[updatedAt] = (completedByDate[updatedAt] ?? 0) + 1;
          totalByDate[updatedAt] = (totalByDate[updatedAt] ?? 0) + 1;
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
      final sixMonthsAgo = DateTime(
        now.month - 5 < 1 ? now.year - 1 : now.year,
        now.month - 5 < 1 ? 12 + now.month - 5 : now.month - 5,
        1
      );
      
      final habits = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
          .get();

      Map<int, int> totalByMonth = {};
      Map<int, int> completedByMonth = {};

      for (var habit in habits.docs) {
        final data = habit.data();
        final startDate = (data['startDate'] as Timestamp).toDate();
        final isCompleted = data['isCompleted'] as bool;

        for (var date = startDate; date.isBefore(now); date = DateTime(date.year, date.month + 1, 1)) {
          final month = date.month;
          totalByMonth[month] = (totalByMonth[month] ?? 0) + 1;
        }

        if (isCompleted) {
          final completedDate = (data['completedID'] as Timestamp?)?.toDate();
          if (completedDate != null) {
            final month = completedDate.month;
            completedByMonth[month] = (completedByMonth[month] ?? 0) + 1;
          }
        }
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

  Future<Map<String, double>> getYearlyCompletionPercentage(S localizations) async {
  final user = _auth.currentUser;
  if (user != null) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    final habits = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
        .get();

    Map<int, int> totalByMonth = {};
    Map<int, int> completedByMonth = {};

    for (var habit in habits.docs) {
      final data = habit.data();
      final startDate = (data['startDate'] as Timestamp).toDate();
      final isCompleted = data['isCompleted'] as bool;

      for (int month = startDate.month; month <= now.month; month++) {
        totalByMonth[month] = (totalByMonth[month] ?? 0) + 1;
      }

      if (isCompleted) {
        final completedDate = (data['completedID'] as Timestamp?)?.toDate();
        if (completedDate != null) {
          final month = completedDate.month;
          completedByMonth[month] = (completedByMonth[month] ?? 0) + 1;
        }
      }
    }

    Map<String, double> monthlyRates = {};
    final months = [
      localizations.january,
      localizations.february,
      localizations.march,
      localizations.april,
      localizations.may,
      localizations.june,
      localizations.july,
      localizations.august,
      localizations.september,
      localizations.october,
      localizations.november,
      localizations.december
    ];
    for (int i = 1; i <= 12; i++) {
      final total = totalByMonth[i] ?? 0;
      final completed = completedByMonth[i] ?? 0;
      monthlyRates[months[i - 1]] = total > 0 ? (completed / total) * 100 : 0;
    }

    return monthlyRates;
  }
  return {};
}

  Future<void> updateProgress(String habitId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final habitRef = _firestore.collection('users').doc(user.uid).collection('habits').doc(habitId);
      final doc = await habitRef.get();
      if (doc.exists) {
        final currentProgress = doc.data()?['progress'] ?? 0;
        await habitRef.update({
          'progress': currentProgress + 1,
          'updatedAt': Timestamp.now(),
        });
      }
    }
  }

  Future<void> saveThemeColor(String color) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'themeColor': color,
      }, SetOptions(merge: true));
    }
  }

Future<String?> getThemeColor() async {
  final user = _auth.currentUser;
  
  if (user == null) {
    debugPrint('Użytkownik nie jest zalogowany! Nie ustawiam koloru.');
    return null; // Nie rób nic, jeśli użytkownik nie jest zalogowany
  }

  try {
    debugPrint('Pobieram dane dla użytkownika o ID: ${user.uid}');
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data();
      debugPrint('Dane użytkownika: $data');

      final themeColor = data?['themeColor'] as String?;
      if (themeColor != null) {
        debugPrint('Odczytano themeColor: $themeColor');
        return themeColor;
      } else {
        debugPrint('Pole themeColor nie istnieje w dokumencie!');
      }
    } else {
      debugPrint('Dokument użytkownika nie istnieje!');
    }
  } catch (e) {
    debugPrint('Błąd podczas odczytu themeColor: $e');
  }

  return null; // Jeśli nic nie znaleziono, zwróć null
}

  Future<int> getActiveHabitsCountForDay(int day) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final habitsSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .where('selectedDays', arrayContains: day)
            .get();
        
        debugPrint('Aktywne nawyki dla dnia $day: ${habitsSnapshot.docs.length}');
        return habitsSnapshot.docs.length;
      } catch (e) {
        debugPrint('Błąd podczas pobierania aktywnych nawyków: $e');
        return 0;
      }
    }
    return 0;
  }

  Future<List<Habit>> getHabitsForMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    final querySnapshot = await _habitsCollection
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();
    return querySnapshot.docs.map((doc) => Habit.fromSnapshot(doc)).toList();
  }

  Future<List<DocumentSnapshot>> getHabitsFromDate(DateTime startDate) async {
    final user = _auth.currentUser;
    if (user != null) {
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();
      return habitsSnapshot.docs;
    }
    return [];
  }

  Future<Map<DateTime, int>> calculateTotalByDate(DateTime startDate, DateTime endDate) async {
    final user = _auth.currentUser;
    if (user != null) {
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<DateTime, int> totalByDate = {};

      for (var habit in habitsSnapshot.docs) {
        final data = habit.data();
        final selectedDays = data['selectedDays'] as List<int>;

        for (var date = startDate;
            date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
            date = date.add(Duration(days: 1))) {
          final weekday = (date.weekday + 6) % 7; // Poniedziałek = 0, ..., Niedziela = 6
          if (selectedDays.contains(weekday)) {
            totalByDate[date] = (totalByDate[date] ?? 0) + 1;
          }
        }
      }

      return totalByDate;
    }
    return {};
  }

  Future<Map<DateTime, int>> calculateCompletedByDate(DateTime startDate, DateTime endDate) async {
    final user = _auth.currentUser;
    if (user != null) {
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<DateTime, int> completedByDate = {};

      for (var habit in habitsSnapshot.docs) {
        final data = habit.data();
        final selectedDays = data['selectedDays'] as List<int>;
        final isCompleted = data['isCompleted'] as bool;
        final completedDate = data['completedDate'] != null
            ? (data['completedDate'] as Timestamp).toDate()
            : null;

        for (var date = startDate;
            date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
            date = date.add(Duration(days: 1))) {
          final weekday = (date.weekday + 6) % 7; // Poniedziałek = 0, ..., Niedziela = 6
          if (selectedDays.contains(weekday) && isCompleted && completedDate != null && completedDate.isBefore(date.add(Duration(days: 1)))) {
            completedByDate[date] = (completedByDate[date] ?? 0) + 1;
          }
        }
      }

      return completedByDate;
    }
    return {};
  }

  Future<double> calculateCompletionPercentage(DateTime startDate, DateTime endDate) async {
    final totalByDate = await calculateTotalByDate(startDate, endDate);
    final completedByDate = await calculateCompletedByDate(startDate, endDate);

    int total = totalByDate.values.fold(0, (sum, count) => sum + count);
    int completed = completedByDate.values.fold(0, (sum, count) => sum + count);

    return total > 0 ? (completed / total) * 100 : 0.0;
  }

  Future<double> calculateCompletionPercentageFromStartOfMonth() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      final completionsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('isCompleted', isEqualTo: true)
          .where('completedID', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('completedID', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      final totalHabits = habitsSnapshot.docs.length;
      final completedHabits = completionsSnapshot.docs.length;

      return totalHabits > 0 ? (completedHabits / totalHabits) * 100 : 0.0;
    }
    return 0.0;
  }

  Future<Map<int, int>> calculateCompletionsByMonth() async {
    final user = _auth.currentUser;
    if (user != null) {
      final habits = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();

      Map<int, int> completionsByMonth = {};

      for (var habit in habits.docs) {
        final data = habit.data();
        final completedAt = (data['completedID'] as Timestamp?)?.toDate();

        if (completedAt != null) {
          final month = completedAt.month;
          completionsByMonth[month] = (completionsByMonth[month] ?? 0) + 1;
        }
      }
      return completionsByMonth;
    }
    return {};
  }

  Future<double> calculateMonthlyCompletionPercentage() async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final today = DateTime(now.year, now.month, now.day);

    final habitsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(today))
        .get();

    int totalScheduledDays = 0;
    int totalCompletedDays = 0;

    for (var habitDoc in habitsSnapshot.docs) {
      final data = habitDoc.data();
      final selectedDays = List<int>.from(data['selectedDays']);
      final completedID = (data['completedID'] as Timestamp?)?.toDate();
      final startDate = (data['startDate'] as Timestamp).toDate();

      if (startDate.isAfter(today)) continue;

      for (var day = startOfMonth;
          day.isBefore(today) || day.isAtSameMomentAs(today);
          day = day.add(Duration(days: 1))) {
        if (selectedDays.contains((day.weekday + 6) % 7)) {
          totalScheduledDays++;
          if (completedID != null &&
              completedID.year == day.year &&
              completedID.month == day.month &&
              completedID.day == day.day) {
            totalCompletedDays++;
          }
        }
      }
    }

    return totalScheduledDays > 0
        ? (totalCompletedDays / totalScheduledDays) * 100
        : 0.0;
  }
}