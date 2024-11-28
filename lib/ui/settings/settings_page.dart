// lib/ui/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        data['email'] = user.email; // Dodanie adresu email do danych użytkownika
        data['name'] = user.displayName; // Dodanie imienia do danych użytkownika
        return data;
      }
    }
    return {
      'email': user?.email ?? 'Nieznany email',
      'name': user?.displayName ?? 'Nieznane imię'
    };
  }

  Future<String> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Nieznane imię';
      }
    }
    return 'Nieznane imię';
  }

  Future<void> _changeEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
      await user.sendEmailVerification();
    }
  }

  Future<void> _changePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Wystąpił błąd'));
            }

            final userData = snapshot.data ?? {};
            final userEmail = userData['email'] ?? 'Nieznany email';

            return ListView(
              children: [
                _buildSectionHeader('Profil'),
                FutureBuilder<String>(
                  future: fetchUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Wystąpił błąd'));
                    }
                    final userName = snapshot.data ?? 'Nieznane imię';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userData['profilePictureUrl'] ?? 'https://via.placeholder.com/150'),
                        child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
                      ),
                      title: Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(userEmail),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(userData: userData)),
                          );
                        },
                        child: const Text('View'),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildSectionHeader('Ogólne'),
                SwitchListTile(
                  title: const Text('Powiadomienia'),
                  value: true, // wartość powinna być pobrana z ustawień użytkownika
                  onChanged: (bool value) {
                    // Zarządzanie powiadomieniami
                  },
                ),
                ListTile(
                  title: const Text('Więcej personalizacji'),
                  onTap: () {
                    // Przejście do opcji personalizacji aplikacji
                  },
                ),
                const Divider(),
                _buildSectionHeader('Ustawienia konta'),
                ListTile(
                  title: const Text('Zmień email'),
                  onTap: () async {
                    final newEmail = await _showInputDialog(context, 'Wprowadź nowy email');
                    if (newEmail != null) {
                      await _changeEmail(newEmail);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Zmień hasło'),
                  onTap: () async {
                    final newPassword = await _showInputDialog(context, 'Wprowadź nowe hasło');
                    if (newPassword != null) {
                      await _changePassword(newPassword);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Usuń konto'),
                  onTap: () async {
                    final confirm = await _showConfirmationDialog(context, 'Czy na pewno chcesz usunąć swoje konto?');
                    if (confirm) {
                      await _deleteAccount();
                    }
                  },
                ),
                const Divider(),
                _buildSectionHeader('Wsparcie'),
                ListTile(
                  title: const Text('Kontakt'),
                  onTap: () {
                    // Umożliwia kontakt z obsługą techniczną
                  },
                ),
                ListTile(
                  title: const Text('Opinie'),
                  onTap: () {
                    // Pozwala na zgłaszanie opinii, sugestii lub problemów
                  },
                ),
                ListTile(
                  title: const Text('Polityka prywatności'),
                  onTap: () {
                    // Przejście do szczegółowych informacji o polityce prywatności
                  },
                ),
                ListTile(
                  title: const Text('O aplikacji'),
                  onTap: () {
                    // Wyświetla informacje o aplikacji
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<String?> _showInputDialog(BuildContext context, String title) async {
    String? input;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}