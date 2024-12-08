// lib/ui/news/news_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:habit_app/l10n/l10n.dart'; // Dodaj ten import

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Dodaj lokalizacje

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.guides, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHeader(localizations),
            Expanded(
              child: ListView(
                children: [
                  _buildGuideCard(
                    context,
                    title: localizations.guideTitle1,
                    subtitle: localizations.guideSubtitle1,
                    imageUrl: 'assets/images/jak-tworzyc-dobre-nawyki.jpg',
                    thumbnailUrl: 'assets/images/jak-tworzyc-dobre-nawyki.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, localizations.guideTitle1, localizations.guideContent1, 'assets/images/jak-tworzyc-dobre-nawyki.jpg');
                    },
                  ),
                  _buildGuideCard(
                    context,
                    title: localizations.guideTitle2,
                    subtitle: localizations.guideSubtitle2,
                    imageUrl: 'assets/images/zarzadzanie-czasem.jpg',
                    thumbnailUrl: 'assets/images/zarzadzanie-czasem.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, localizations.guideTitle2, localizations.guideContent2, 'assets/images/zarzadzanie-czasem.jpg');
                    },
                  ),
                  _buildGuideCard(
                    context,
                    title: localizations.guideTitle3,
                    subtitle: localizations.guideSubtitle3,
                    imageUrl: 'assets/images/motywacja-do-dzialania.jpg',
                    thumbnailUrl: 'assets/images/motywacja-do-dzialania.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, localizations.guideTitle3, localizations.guideContent3, 'assets/images/motywacja-do-dzialania.jpg');
                    },
                  ),
                  _buildGuideCard(
                    context,
                    title: localizations.guideTitle4,
                    subtitle: localizations.guideSubtitle4,
                    imageUrl: 'assets/images/zdrowe-nawyki-zywieniowe.jpg',
                    thumbnailUrl: 'assets/images/zdrowe-nawyki-zywieniowe.jpg',
                    onTap: () {
                      _navigateToGuideDetail(context, localizations.guideTitle4, localizations.guideContent4, 'assets/images/zdrowe-nawyki-zywieniowe.jpg');
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

  Widget _buildHeader(S localizations) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.white, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              localizations.guidesHeader,
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward, color: Colors.grey),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(imageUrl, height: 300, fit: BoxFit.cover)
                        : Image.asset(imageUrl, height: 300, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
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