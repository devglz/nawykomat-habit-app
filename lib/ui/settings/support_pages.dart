import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.contact, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.contactSupportSubtitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildContactTile(
              icon: Icons.email,
              title: localizations.email,
              subtitle: 'support@nawykomat.pl',
              onTap: () => _launchEmail('support@nawykomat.pl'),
            ),
            _buildContactTile(
              icon: Icons.phone,
              title: localizations.phone,
              subtitle: '+48 123 456 789',
              onTap: () => _launchPhone('+48123456789'),
            ),
            _buildContactTile(
              icon: Icons.message,
              title: localizations.chat,
              subtitle: localizations.chatAvailability,
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
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.chatWithSupport),
        content: Text(localizations.chatComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.feedback, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.feedbackSubtitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: localizations.feedbackHint,
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
                child: Text(localizations.submitFeedback),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    if (_rating == 0 || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.feedbackError)),
      );
      return;
    }
    
    // Tu można dodać logikę wysyłania opinii
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.feedbackSuccess)),
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
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.privacyPolicy, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            localizations.privacyPolicy,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _PolicySection(
            title: localizations.privacyPolicySection1Title,
            content: localizations.privacyPolicySection1Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection2Title,
            content: localizations.privacyPolicySection2Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection3Title,
            content: localizations.privacyPolicySection3Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection4Title,
            content: localizations.privacyPolicySection4Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection5Title,
            content: localizations.privacyPolicySection5Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection6Title,
            content: localizations.privacyPolicySection6Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection7Title,
            content: localizations.privacyPolicySection7Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection8Title,
            content: localizations.privacyPolicySection8Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection9Title,
            content: localizations.privacyPolicySection9Content,
          ),
          _PolicySection(
            title: localizations.privacyPolicySection10Title,
            content: localizations.privacyPolicySection10Content,
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.aboutApp, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/app_logo.svg',
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              localizations.appTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text('${localizations.version}: 1.0.0'),
            const SizedBox(height: 20),
            Text(
              localizations.aboutApp,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(localizations.aboutAppDescription),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Dodaj link do strony z licencjami
              },
              child: Text(localizations.openSourceLicenses),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.support, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(localizations.supportTitle),
      ),
    );
  }
}

class SupportPages extends StatelessWidget {
  const SupportPages({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Dodaj dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.supportTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(localizations.contactSupport),
            subtitle: Text(localizations.contactSupportSubtitle),
            onTap: () {
              // ...existing code...
            },
          ),
          ListTile(
            title: Text(localizations.feedback),
            subtitle: Text(localizations.feedbackSubtitle),
            onTap: () {
              // ...existing code...
            },
          ),
          ListTile(
            title: Text(localizations.privacyPolicy),
            subtitle: Text(localizations.privacyPolicySubtitle),
            onTap: () {
              // ...existing code...
            },
          ),
          ListTile(
            title: Text(localizations.aboutApp),
            subtitle: Text(localizations.aboutAppSubtitle),
            onTap: () {
              // ...existing code...
            },
          ),
        ],
      ),
    );
  }
}