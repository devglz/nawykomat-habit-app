import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

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

  Future<void> _changeEmail(BuildContext context) async {
    final newEmail = await _showInputDialog(context, 'Enter new email');
    if (newEmail != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.sendEmailVerification();
      }
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final newPassword = await _showInputDialog(context, 'Enter new password');
    if (newPassword != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await _showConfirmationDialog(context, 'Are you sure you want to delete your account?');
    if (confirm) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final userEmail = userData['email'] ?? 'Nieznany email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Edycja profilu
                    },
                  ),
                );
              },
            ),
            const Divider(),
            _buildSectionHeader('Zakres danych czasowych'),
            ListTile(
              title: const Text('Ten tydzień'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Zmiana zakresu danych czasowych
                },
              ),
            ),
            const Divider(),
            _buildSectionHeader('Szybkie Statystyki użytkownika'),
            ListTile(
              title: const Text('Całkowite godziny pracy'),
              subtitle: const Text('40 godzin'), // Przykładowa wartość
            ),
            ListTile(
              title: const Text('Zadania ukończone'),
              subtitle: const Text('15 zadań'), // Przykładowa wartość
            ),
            const Divider(),
            _buildSectionHeader('Wizualizacje graficzne'),
            // Dodaj tutaj wykresy lub inne wizualizacje
            const Divider(),
            _buildSectionHeader('Opcje dodatkowe'),
            ListTile(
              title: const Text('Metody płatności'),
              onTap: () {
                // Zarządzanie metodami płatności
              },
            ),
            ListTile(
              title: const Text('Najdłuższa seria'),
              subtitle: const Text('20 dni'), // Przykładowa wartość
            ),
            const Divider(),
            _buildSectionHeader('Ustawienia konta'),
            ListTile(
              title: const Text('Zmień email'),
              onTap: () => _changeEmail(context),
            ),
            ListTile(
              title: const Text('Zmień hasło'),
              onTap: () => _changePassword(context),
            ),
            ListTile(
              title: const Text('Usuń konto'),
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
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