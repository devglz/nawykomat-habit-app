// lib/ui/news/news_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poradniki', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6750A4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                children: [
                  _buildGuideCard(
                    context,
                    title: 'Jak tworzyć dobre nawyki',
                    subtitle: 'Dowiedz się, jak skutecznie tworzyć i utrzymywać dobre nawyki.',
                    imageUrl: 'assets/images/jak-tworzyc-dobre-nawyki.jpg',
                    thumbnailUrl: 'assets/images/jak-tworzyc-dobre-nawyki.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, 'Jak tworzyć dobre nawyki', 'Tworzenie dobrych nawyków wymaga systematyczności i cierpliwości. Oto kilka kroków, które mogą Ci pomóc:\n\n1. Zdefiniuj cel.\n2. Rozpocznij od małych kroków.\n3. Bądź konsekwentny.\n4. Monitoruj postępy.\n5. Nagradzaj się za osiągnięcia.\n\nDodatkowe informacje:\n- Ustal realistyczne cele.\n- Znajdź swoje "dlaczego".\n- Otaczaj się pozytywnymi ludźmi.\n- Celebruj małe sukcesy.\n- Bądź elastyczny i dostosowuj swoje plany.', 'assets/images/jak-tworzyc-dobre-nawyki.jpg');
                    },
                  ),
                  _buildGuideCard(
                    context,
                    title: 'Zarządzanie czasem',
                    subtitle: 'Porady dotyczące efektywnego zarządzania czasem.',
                    imageUrl: 'assets/images/zarzadzanie-czasem.jpg',
                    thumbnailUrl: 'assets/images/zarzadzanie-czasem.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, 'Zarządzanie czasem', 'Efektywne zarządzanie czasem jest kluczowe dla osiągnięcia sukcesu. Oto kilka wskazówek:\n\n1. Planuj swój dzień.\n2. Ustal priorytety.\n3. Unikaj rozpraszaczy.\n4. Deleguj zadania.\n5. Regularnie oceniaj swoje postępy.\n\nDodatkowe informacje:\n- Ustal realistyczne cele.\n- Znajdź swoje "dlaczego".\n- Otaczaj się pozytywnymi ludźmi.\n- Celebruj małe sukcesy.\n- Bądź elastyczny i dostosowuj swoje plany.', 'assets/images/zarzadzanie-czasem.jpg');
                    },
                  ),
                  _buildGuideCard(
                    context,
                    title: 'Motywacja do działania',
                    subtitle: 'Jak utrzymać motywację do działania na wysokim poziomie.',
                    imageUrl: 'assets/images/motywacja-do-dzialania.jpg',
                    thumbnailUrl: 'assets/images/motywacja-do-dzialania.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, 'Motywacja do działania', 'Utrzymanie motywacji do działania może być wyzwaniem. Oto kilka strategii:\n\n1. Ustal realistyczne cele.\n2. Znajdź swoje "dlaczego".\n3. Otaczaj się pozytywnymi ludźmi.\n4. Celebruj małe sukcesy.\n5. Bądź elastyczny i dostosowuj swoje plany.\n\nDodatkowe informacje:\n- Ustal realistyczne cele.\n- Znajdź swoje "dlaczego".\n- Otaczaj się pozytywnymi ludźmi.\n- Celebruj małe sukcesy.\n- Bądź elastyczny i dostosowuj swoje plany.', 'assets/images/motywacja-do-dzialania.jpg');
                    },
                  ),
                  _buildGuideCard(
                    context,
                    title: 'Zdrowe nawyki żywieniowe',
                    subtitle: 'Porady dotyczące zdrowego odżywiania i nawyków żywieniowych.',
                    imageUrl: 'assets/images/zdrowe-nawyki-zywieniowe.jpg',
                    thumbnailUrl: 'assets/images/zdrowe-nawyki-zywieniowe.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, 'Zdrowe nawyki żywieniowe', 'Zdrowe nawyki żywieniowe są kluczowe dla dobrego samopoczucia. Oto kilka wskazówek:\n\n1. Jedz regularnie.\n2. Wybieraj pełnowartościowe produkty.\n3. Unikaj przetworzonej żywności.\n4. Pij dużo wody.\n5. Słuchaj swojego ciała.\n\nDodatkowe informacje:\n- Ustal realistyczne cele.\n- Znajdź swoje "dlaczego".\n- Otaczaj się pozytywnymi ludźmi.\n- Celebruj małe sukcesy.\n- Bądź elastyczny i dostosowuj swoje plany.', 'assets/images/zdrowe-nawyki-zywieniowe.jpg');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.white, size: 40),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Witaj w sekcji poradników! Znajdziesz tu najnowsze informacje i porady dotyczące zarządzania nawykami.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, {required String title, required String subtitle, required String imageUrl, required String thumbnailUrl, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _navigateToGuideDetail(BuildContext context, String title, String content, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideDetailPage(title: title, content: content, imageUrl: imageUrl),
      ),
    );
  }
}

class GuideDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;

  const GuideDetailPage({super.key, required this.title, required this.content, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(imageUrl, height: 300, fit: BoxFit.cover)
                        : Image.asset(imageUrl, height: 300, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      content,
                      style: TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}