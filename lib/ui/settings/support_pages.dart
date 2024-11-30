import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakt'),
        backgroundColor: Colors.yellowAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masz pytania? Skontaktuj się z nami!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildContactTile(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@nawykomat.pl',
              onTap: () => _launchEmail('support@nawykomat.pl'),
            ),
            _buildContactTile(
              icon: Icons.phone,
              title: 'Telefon',
              subtitle: '+48 123 456 789',
              onTap: () => _launchPhone('+48123456789'),
            ),
            _buildContactTile(
              icon: Icons.message,
              title: 'Chat',
              subtitle: 'Dostępny w godz. 8:00-20:00',
              onTap: () => _openChat(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(emailUri);
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    await launchUrl(phoneUri);
  }

  void _openChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat z supportem'),
        content: const Text('Funkcja chatu będzie dostępna wkrótce!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opinie'),
        backgroundColor: Colors.yellowAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Twoja opinia jest dla nas ważna!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Napisz swoją opinię...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitFeedback,
                child: const Text('Wyślij opinię'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (_rating == 0 || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę dodać ocenę i opinię')),
      );
      return;
    }
    
    // Tu można dodać logikę wysyłania opinii
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dziękujemy za opinię!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polityka Prywatności'),
        backgroundColor: Colors.yellowAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Polityka Prywatności',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            '1. Gromadzenie danych',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Zbieramy tylko niezbędne dane potrzebne do funkcjonowania aplikacji...',
          ),
          SizedBox(height: 20),
          Text(
            '2. Wykorzystanie danych',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Twoje dane są wykorzystywane wyłącznie w celu...',
          ),
          // Dodaj więcej sekcji według potrzeb
        ],
      ),
    );
  }
}

class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O aplikacji'),
        backgroundColor: Colors.yellowAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/app_logo.png', // Dodaj logo aplikacji
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nawykomat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text('Wersja: 1.0.0'),
            const SizedBox(height: 20),
            const Text(
              'O nas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nawykomat to aplikacja stworzona z myślą o pomocy w budowaniu pozytywnych nawyków...',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Dodaj link do strony z licencjami
              },
              child: const Text('Licencje open source'),
            ),
          ],
        ),
      ),
    );
  }
}