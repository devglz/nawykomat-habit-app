import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Dodaj ten import
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_app/l10n/l10n.dart'; // Import L10n
import 'package:cloud_firestore/cloud_firestore.dart'; // Dodaj ten import

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
                      width: 1100,
                      height: 700,
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) => context.findAncestorStateOfType<MyAppState>();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Ustaw domyślnie jasny motyw
  Color _themeColor = const Color(0xFF6750A4); // Domyślny fioletowy kolor
  Locale _locale = const Locale('pl'); // Domyślny język polski

  Locale get locale => _locale;

  @override
  void initState() {
    super.initState();
    _initializeTheme();
    _initializeLocale(); // Dodaj inicjalizację języka
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _initializeTheme();
        _initializeLocale(); // Dodaj inicjalizację języka
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<void> _initializeTheme() async {
    final habitService = context.read<HabitService>();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final colorString = await habitService.getThemeColor();
        if (colorString != null) {
          debugPrint('Ustawiam kolor motywu: $colorString');
          setThemeColor(_colorFromString(colorString)); // Załaduj kolor z bazy
        } else {
          debugPrint('Brak koloru w bazie danych, używam domyślnego koloru');
          setThemeColor(const Color(0xFF6750A4)); // Domyślny fioletowy
        }
      } catch (e) {
        debugPrint('Błąd podczas inicjalizacji motywu: $e');
        setThemeColor(const Color(0xFF6750A4)); // Domyślny fioletowy
      }
    } else {
      debugPrint('Użytkownik nie jest zalogowany, używam domyślnego koloru');
      setThemeColor(const Color(0xFF6750A4)); // Domyślny fioletowy
    }
  }

  Future<void> _initializeLocale() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final localeString = doc.data()?['locale'] as String?;
          if (localeString != null) {
            setLocale(Locale(localeString));
          }
        }
      } catch (e) {
        debugPrint('Błąd podczas inicjalizacji języka: $e');
      }
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void setThemeColor(Color color) {
    setState(() {
      _themeColor = color;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _saveLocaleToFirebase(locale.languageCode); // Zapisz język do Firebase
  }

  Future<void> _saveLocaleToFirebase(String languageCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'locale': languageCode,
        });
      } catch (e) {
        debugPrint('Błąd podczas zapisywania języka do Firebase: $e');
      }
    }
  }

  Color _colorFromString(String colorString) {
    switch (colorString.toLowerCase()) { // Dodaj obsługę małych i dużych liter
      case 'niebieski':
        return Colors.blue;
      case 'zielony':
        return Colors.green;
      case 'czerwony':
        return Colors.red;
      case 'brązowy':
        return Colors.brown;
      case 'czarny':
        return Colors.black;
      case 'szary':
        return Colors.grey;
      case 'pomarańczowy':
        return Colors.orange;
      case 'różowy':
        return Colors.pink;
      case 'limonkowy':
        return Colors.lime;
      default:
        return const Color(0xFF6750A4); // Domyślny fioletowy kolor
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nawykomat',
      theme: ThemeData.light().copyWith(primaryColor: _themeColor),
      darkTheme: ThemeData.dark().copyWith(primaryColor: _themeColor),
      themeMode: _themeMode, // Użyj zmiennej _themeMode
      locale: _locale,
      supportedLocales: [
        const Locale('en'), // angielski
        const Locale('pl'), // polski
        const Locale('de'), // niemiecki
        const Locale('es'), // hiszpański
        const Locale('fr'), // francuski
        const Locale('zh'), // chiński
      ],
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
      builder: (context, child) {
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute == '/login' || currentRoute == '/register') {
          return Theme(
            data: ThemeData.light(),
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}
