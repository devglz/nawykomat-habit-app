import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotifications(List<QueryDocumentSnapshot> habits) async {
    for (var habit in habits) {
      final data = habit.data() as Map<String, dynamic>;
      final title = data['title'];
      final timeOfDay = data['timeOfDay'];

      final androidDetails = AndroidNotificationDetails(
        'habit_channel',
        'Habit Notifications',
        channelDescription: 'Notifications for habit reminders',
        importance: Importance.max,
        priority: Priority.high,
      );
      final iosDetails = DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(
        hours: int.parse(timeOfDay.split(':')[0]),
        minutes: int.parse(timeOfDay.split(':')[1]),
      ));

      await flutterLocalNotificationsPlugin.zonedSchedule(
        habit.id.hashCode,
        'Przypomnienie o nawyku',
        'Czas na: $title', // Dodaj tekst "Przypomnienie o nawyku"
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}