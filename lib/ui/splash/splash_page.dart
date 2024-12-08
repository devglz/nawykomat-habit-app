import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Dodaj import dla SvgPicture
import 'dart:async'; // Dodaj import dla Timer
import 'package:habit_app/main.dart'; // Dodaj import dla MyApp
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import dla S

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _pages = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) { // Dodano sprawdzenie
        if (_currentPage < _pages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializePages();
  }

  void _initializePages() {
    setState(() {
      _pages = [
        {
          'title': S.of(context).setYourHabits,
          'description': S.of(context).setYourHabitsDescription,
        },
        {
          'title': S.of(context).setReminders,
          'description': S.of(context).setRemindersDescription,
        },
        {
          'title': S.of(context).trackProgress,
          'description': S.of(context).trackProgressDescription,
        },
        {
          'title': S.of(context).readyToGo,
          'description': S.of(context).readyToGoDescription,
        },
      ];
    });
  }

  String getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'assets/flags/gb.svg';
      case 'pl':
        return 'assets/flags/pl.svg';
      case 'de':
        return 'assets/flags/de.svg';
      case 'es':
        return 'assets/flags/es.svg';
      case 'fr':
        return 'assets/flags/fr.svg';
      case 'zh':
        return 'assets/flags/cn.svg';
      default:
        return 'assets/flags/unknown.svg';
    }
  }

  void _onSkip() {
    if (_pageController.hasClients) { // Dodano sprawdzenie
      _pageController.animateToPage(
        _pages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildPageIndicator(bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: isActive ? 16.0 : 12.0, // Powiększ kropki
        width: isActive ? 16.0 : 12.0, // Powiększ kropki
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue,
              Colors.purple,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Text(
                S.of(context).appName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith( // Zmieniono na displayMedium
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50), // Przestrzeń dla napisu "Nawykomat"
                    SvgPicture.asset(
                      'assets/app_logo.svg', // Ścieżka do logo SVG
                      height: 180, // Powiększ logo
                    ),
                    SizedBox(height: index == _pages.length - 1 ? 40 : 100), // Przesunięcie tytułu na górę na ostatnim ekranie
                    Text(
                      page['title']!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        page['description']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (index == _pages.length - 1)
                      const SizedBox(height: 30),
                    if (index == _pages.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          backgroundColor: Colors.orange, // Zmieniono kolor tła
                          foregroundColor: Colors.white, // Zmieniono kolor tekstu
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5, // Dodano cień
                          shadowColor: Colors.black.withOpacity(0.5), // Kolor cienia
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(S.of(context).startNow),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward, size: 24),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            Positioned(
              top: 50,
              left: 20,
              child: DropdownButton<Locale>(
                value: MyApp.of(context)?.locale ?? S.delegate.supportedLocales.first,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    setState(() {
                      MyApp.of(context)?.setLocale(newLocale);
                    });
                  }
                },
                items: S.delegate.supportedLocales.map<DropdownMenuItem<Locale>>((Locale locale) {
                  final flag = getFlag(locale.languageCode);
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          flag,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(locale.languageCode.toUpperCase(), style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
                underline: Container(), // Usunięcie kreski
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  S.of(context).skip,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index == _currentPage, index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
