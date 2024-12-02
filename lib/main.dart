import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habit_app/ui/splash/splash_page.dart';
import 'package:habit_app/ui/login/login_page.dart';
import 'package:habit_app/ui/register/register_page.dart';
import 'package:habit_app/ui/home/home_page.dart';
import 'package:habit_app/ui/habit/add_habit_page.dart';
import 'package:habit_app/ui/progress/progress_page.dart';
import 'package:habit_app/ui/news/news_page.dart';
import 'package:habit_app/ui/settings/settings_page.dart';
import 'package:habit_app/ui/settings/personalization_page.dart';
import 'package:habit_app/ui/settings/notifications_page.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // Import do obsługi kIsWeb
import 'package:provider/provider.dart';
import 'package:habit_app/services/habit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Inicjalizacja dla platformy webowej
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Inicjalizacja dla Androida/iOS
    await Firebase.initializeApp(
      name: "habbit-app-86883",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<HabitService>(
          create: (_) => HabitService(),
        ),
        // ...inne provider'y, jeśli są...
      ],
      child: const MyAppWebWrapper(), // Użycie MyAppWebWrapper
    ),
  );
}

class MyAppWebWrapper extends StatelessWidget {
  const MyAppWebWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: kIsWeb
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Colors.purple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 1300,
                      height: 900,
                      color: Colors.white, // Tło dla głównej aplikacji
                      child: const MyApp(),
                    ),
                  ),
                ),
              )
            : const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nawykomat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/addHabit': (context) => const AddHabitPage(),
        '/progress': (context) => const ProgressPage(),
        '/news': (context) => const NewsPage(),
        '/settings': (context) => const SettingsPage(),
        '/personalization': (context) => const PersonalizationPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}