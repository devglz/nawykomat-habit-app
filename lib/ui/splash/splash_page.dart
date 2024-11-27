import 'package:flutter/material.dart';

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
      'image': 'assets/images/introduction1.png',
    },
    {
      'title': 'USTAW PRZYPOMNIENIA',
      'description':
          'Dzięki powiadomieniom nie zapomnisz o codziennym kroku w stronę lepszego siebie.',
      'image': 'assets/images/introduction2.png',
    },
    {
      'title': 'ŚLEDŹ SWOJE POSTĘPY',
      'description':
          'Nasze wykresy i raporty pomogą Ci zobaczyć, jak rozwijasz swoje nawyki.',
      'image': 'assets/images/introduction3.png',
    },
    {
      'title': 'GOTOWY DO DZIAŁANIA',
      'description': 'Jesteś gotowy, aby rozpocząć swoją podróż!',
      'image': 'assets/images/introduction4.png',
    },
  ];

  void _onSkip() {
    // Przejdź do ostatniej strony
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

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: isActive ? 12.0 : 8.0,
      width: isActive ? 12.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(page['image']!,
                      height: MediaQuery.of(context).size.height * 0.4),
                  const SizedBox(height: 20),
                  Text(
                    page['title']!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      page['description']!,
                      style: Theme.of(context).textTheme.bodyMedium,
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
                style: TextStyle(color: Colors.blue),
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
                (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
