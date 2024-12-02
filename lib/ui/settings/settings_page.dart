// lib/ui/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_app/main.dart'; // Dodaj ten import
import 'profile_page.dart';
import 'personalization_page.dart'; // Dodaj ten import
import './notifications_page.dart'; // Poprawiony import
import 'support_pages.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.sendEmailVerification();
        _showMessage('E-mail logowania został zmieniony. Sprawdź swoją skrzynkę pocztową, aby zweryfikować nowy adres e-mail.');
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'invalid-email':
            _showMessage('Nieprawidłowy adres e-mail.');
            break;
          case 'email-already-in-use':
            _showMessage('Adres e-mail jest już używany.');
            break;
          default:
            _showMessage('Wystąpił nieznany błąd: ${e.message}');
        }
      } catch (e) {
        _showMessage('Wystąpił błąd: $e');
      }
    }
  }

  Future<void> _changePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('E-mail do resetowania hasła został wysłany. Sprawdź swoją skrzynkę pocztową.');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _showMessage('Nieprawidłowy adres e-mail.');
          break;
        case 'user-not-found':
          _showMessage('Nie znaleziono użytkownika z tym adresem e-mail.');
          break;
        default:
          _showMessage('Wystąpił nieznany błąd: ${e.message}');
      }
    } catch (e) {
      _showMessage('Wystąpił błąd: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  void _openDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              SvgPicture.asset(
                'assets/app_logo.svg',
                height: 80,
              ),
              const SizedBox(height: 16),
              const Text('Usuwanie konta'),
            ],
          ),
          content: const Text('Czy na pewno chcesz usunąć swoje konto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteAccount();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Usuń konto'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _openResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _resetEmailController = TextEditingController();
        String _resetErrorMessage = '';

        void _showResetError(String message) {
          setState(() {
            _resetErrorMessage = message;
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  SvgPicture.asset(
                    'assets/app_logo.svg',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text('Resetowanie hasła'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Wpisz swój adres e-mail, aby zresetować hasło.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resetEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_resetErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _resetErrorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = _resetEmailController.text.trim();
                    if (email.isEmpty) {
                      setState(() {
                        _resetErrorMessage = 'Proszę wprowadzić adres e-mail.';
                      });
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      Navigator.of(context).pop();
                      _showMessage('E-mail do resetowania hasła został wysłany. Sprawdź swoją skrzynkę pocztową.');
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case 'invalid-email':
                          setState(() {
                            _resetErrorMessage = 'Nieprawidłowy adres e-mail.';
                          });
                          break;
                        default:
                          setState(() {
                            _resetErrorMessage = 'Wystąpił nieznany błąd: ${e.message}';
                          });
                      }
                    } catch (e) {
                      setState(() {
                        _resetErrorMessage = 'Wystąpił błąd: $e';
                      });
                    }
                  },
                  child: const Text('Zresetuj hasło'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openChangeEmailDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _newEmailController = TextEditingController();
        final TextEditingController _confirmEmailController = TextEditingController();
        String _emailErrorMessage = '';

        void _showEmailError(String message) {
          setState(() {
            _emailErrorMessage = message;
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  SvgPicture.asset(
                    'assets/app_logo.svg',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text('Zmień adres e-mail'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Wprowadź nowy adres e-mail dwukrotnie, aby go zmienić.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Nowy e-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Potwierdź nowy e-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_emailErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _emailErrorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Anuluj'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newEmail = _newEmailController.text.trim();
                    final confirmEmail = _confirmEmailController.text.trim();
                    if (newEmail.isEmpty || confirmEmail.isEmpty) {
                      setState(() {
                        _emailErrorMessage = 'Proszę wprowadzić adres e-mail w obu polach.';
                      });
                      return;
                    }
                    if (newEmail != confirmEmail) {
                      setState(() {
                        _emailErrorMessage = 'Adresy e-mail nie są zgodne.';
                      });
                      return;
                    }
                    await _changeEmail(newEmail);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Zmień e-mail'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              SvgPicture.asset(
                'assets/app_logo.svg',
                height: 80,
              ),
              const SizedBox(height: 16),
              const Text('Wylogowanie'),
            ],
          ),
          content: const Text('Czy na pewno chcesz się wylogować?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _signOut();
              },
              child: const Text('Wyloguj się'),
            ),
          ],
        );
      },
    );
  }

  void _toggleDarkMode(bool isDarkMode) {
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    MyApp.of(context)?.setThemeMode(themeMode);
  }

  void _applyThemeColor(String color) {
    Color themeColor;
    switch (color) {
      case 'Yellow':
        themeColor = Colors.yellow;
        break;
      case 'Blue':
        themeColor = Colors.blue;
        break;
      case 'Green':
        themeColor = Colors.green;
        break;
      case 'Red':
        themeColor = Colors.red;
        break;
      default:
        themeColor = const Color(0xFF6750A4); // Purple
    }
    MyApp.of(context)?.setThemeColor(themeColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor, // Użyj koloru motywu
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
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
                    );
                  },
                ),
                const Divider(),
                _buildSectionHeader('Ogólne'),
                ListTile(
                  title: const Text('Powiadomienia'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Więcej personalizacji'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PersonalizationPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Tryb ciemny'),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: _toggleDarkMode,
                  ),
                ),
                const Divider(),
                _buildSectionHeader('Ustawienia konta'),
                ListTile(
                  title: const Text('Zmień email'),
                  onTap: _openChangeEmailDialog,
                ),
                ListTile(
                  title: const Text('Zmień hasło'),
                  onTap: _openResetPasswordDialog,
                ),
                ListTile(
                  title: const Text('Usuń konto'),
                  onTap: _openDeleteAccountDialog,
                ),
                ListTile(
                  title: const Text('Wyloguj się'),
                  onTap: _openSignOutDialog,
                ),
                const Divider(),
                _buildSectionHeader('Wsparcie'),
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: const Text('Kontakt'),
                  subtitle: const Text('Skontaktuj się z naszym zespołem'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: const Text('Opinie'),
                  subtitle: const Text('Podziel się swoją opinią'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Polityka prywatności'),
                  subtitle: const Text('Informacje o ochronie danych'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('O aplikacji'),
                  subtitle: const Text('Informacje i licencje'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutAppPage()),
                    );
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

  Future<bool> _showConfirmationDialogWithLogo(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              SvgPicture.asset(
                'assets/app_logo.svg',
                height: 80,
              ),
              const SizedBox(height: 16),
              const Text('Potwierdzenie'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Tak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Nie'),
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