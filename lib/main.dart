import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habit_app/ui/splash/splash_page.dart';
import 'package:habit_app/ui/login/login_page.dart';
import 'package:habit_app/ui/register/register_page.dart';
import 'package:habit_app/ui/home/home_page.dart';
import 'package:habit_app/ui/habit/add_habit_page.dart';
import 'package:habit_app/ui/habit/edit_habit_page.dart';
import 'package:habit_app/ui/progress/progress_page.dart'; // Upewnij się, że ten import jest dodany
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // Import do obsługi kIsWeb


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

  runApp(const MyApp());
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
        '/progress': (context) => const ProgressPage(), // Dodaj tę trasę
      },
    );
  }
}