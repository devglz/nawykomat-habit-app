import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:habit_app/services/habit_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_app/l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
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
      ],
      child: const MyAppWebWrapper(),
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
                      color: Colors.white,
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
  ThemeMode _themeMode = ThemeMode.light;
  Color _themeColor = const Color(0xFF6750A4);
  Locale _locale = const Locale('pl');
  double _fontSize = 16.0;

  Locale get locale => _locale;
  double get fontSize => _fontSize;

  @override
  void initState() {
    super.initState();
    _initializeTheme();
    _initializeLocale();
    _initializeFontSize();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _initializeTheme();
        _initializeLocale();
        _initializeFontSize();
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
          setThemeColor(_colorFromString(colorString));
        } else {
          debugPrint('Brak koloru w bazie danych, używam domyślnego koloru');
          setThemeColor(const Color(0xFF6750A4));
        }
      } catch (e) {
        debugPrint('Błąd podczas inicjalizacji motywu: $e');
        setThemeColor(const Color(0xFF6750A4));
      }
    } else {
      debugPrint('Użytkownik nie jest zalogowany, używam domyślnego koloru');
      setThemeColor(const Color(0xFF6750A4));
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

  Future<void> _initializeFontSize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final fontSize = doc.data()?['fontSize'] as double?;
          if (fontSize != null) {
            setFontSize(fontSize);
          }
        }
      } catch (e) {
        debugPrint('Błąd podczas inicjalizacji rozmiaru tekstu: $e');
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
    _saveLocaleToFirebase(locale.languageCode);
  }

  void setFontSize(double fontSize) {
    setState(() {
      _fontSize = fontSize;
    });
    _saveFontSizeToFirebase(fontSize);
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

  Future<void> _saveFontSizeToFirebase(double fontSize) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fontSize': fontSize,
        });
      } catch (e) {
        debugPrint('Błąd podczas zapisywania rozmiaru tekstu do Firebase: $e');
      }
    }
  }

  Color _colorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
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
        return const Color(0xFF6750A4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nawykomat',
      theme: ThemeData.light().copyWith(
        primaryColor: _themeColor,
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyLarge: TextStyle(fontSize: _fontSize),
          bodyMedium: TextStyle(fontSize: _fontSize),
          headlineLarge: TextStyle(fontSize: _fontSize * 2),
          headlineMedium: TextStyle(fontSize: _fontSize * 1.75),
          headlineSmall: TextStyle(fontSize: _fontSize * 1.5),
          titleLarge: TextStyle(fontSize: _fontSize * 1.25),
          titleMedium: TextStyle(fontSize: _fontSize),
          titleSmall: TextStyle(fontSize: _fontSize * 0.875),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: _themeColor,
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: TextStyle(fontSize: _fontSize),
          bodyMedium: TextStyle(fontSize: _fontSize),
          headlineLarge: TextStyle(fontSize: _fontSize * 2),
          headlineMedium: TextStyle(fontSize: _fontSize * 1.75),
          headlineSmall: TextStyle(fontSize: _fontSize * 1.5),
          titleLarge: TextStyle(fontSize: _fontSize * 1.25),
          titleMedium: TextStyle(fontSize: _fontSize),
          titleSmall: TextStyle(fontSize: _fontSize * 0.875),
        ),
      ),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: [
        const Locale('en'),
        const Locale('pl'),
        const Locale('de'),
        const Locale('es'),
        const Locale('fr'),
        const Locale('zh'),
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
            data: ThemeData.light().copyWith(
              textTheme: ThemeData.light().textTheme.copyWith(
                bodyLarge: TextStyle(fontSize: 16.0),
                bodyMedium: TextStyle(fontSize: 16.0),
                headlineLarge: TextStyle(fontSize: 32.0),
                headlineMedium: TextStyle(fontSize: 28.0),
                headlineSmall: TextStyle(fontSize: 24.0),
                titleLarge: TextStyle(fontSize: 20.0),
                titleMedium: TextStyle(fontSize: 16.0),
                titleSmall: TextStyle(fontSize: 14.0),
              ),
            ),
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}


