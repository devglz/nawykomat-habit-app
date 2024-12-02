import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Dodaj import dla SvgPicture
import 'dart:async'; // Dodaj import dla Timer

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'USTAL SWOJE NAWYKI',
      'description':
          'Z łatwością wprowadzaj i modyfikuj nawyki, które pomogą Ci osiągnąć lepszą wersję siebie.',
    },
    {
      'title': 'USTAW PRZYPOMNIENIA',
      'description':
          'Dzięki powiadomieniom nie zapomnisz o codziennym kroku w stronę lepszego siebie.',
    },
    {
      'title': 'ŚLEDŹ SWOJE POSTĘPY',
      'description':
          'Nasze wykresy i raporty pomogą Ci zobaczyć, jak rozwijasz swoje nawyki.',
    },
    {
      'title': 'GOTOWY DO DZIAŁANIA',
      'description': 'Jesteś gotowy, aby rozpocząć swoją podróż!',
    },
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
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
    });
  }

  void _onSkip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                'Nawykomat',
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
                    const SizedBox(height: 100), // Przesunięcie tytułu na dół
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
                        ),
                        child: const Text('Rozpocznij teraz'),
                      ),
                  ],
                );
              },
            ),
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _onSkip,
                child: const Text(
                  'Pomiń',
                  style: TextStyle(color: Colors.white),
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
