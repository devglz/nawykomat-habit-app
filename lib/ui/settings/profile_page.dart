import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _newEmailController = TextEditingController();
        final TextEditingController _confirmEmailController = TextEditingController();
        String _emailErrorMessage = '';

        void _showEmailError(String message) {
          (context as Element).markNeedsBuild();
          _emailErrorMessage = message;
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
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await user.verifyBeforeUpdateEmail(newEmail);
                        await user.sendEmailVerification();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('E-mail logowania został zmieniony. Sprawdź swoją skrzynkę pocztową, aby zweryfikować nowy adres e-mail.')),
                        );
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case 'invalid-email':
                            setState(() {
                              _emailErrorMessage = 'Nieprawidłowy adres e-mail.';
                            });
                            break;
                          case 'email-already-in-use':
                            setState(() {
                              _emailErrorMessage = 'Adres e-mail jest już używany.';
                            });
                            break;
                          default:
                            setState(() {
                              _emailErrorMessage = 'Wystąpił nieznany błąd: ${e.message}';
                            });
                        }
                      } catch (e) {
                        setState(() {
                          _emailErrorMessage = 'Wystąpił błąd: $e';
                        });
                      }
                    }
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

  Future<void> _changePassword(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _newPasswordController = TextEditingController();
        final TextEditingController _confirmPasswordController = TextEditingController();
        String _passwordErrorMessage = '';

        void _showPasswordError(String message) {
          (context as Element).markNeedsBuild();
          _passwordErrorMessage = message;
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
                  const Text('Zmień hasło'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Wprowadź nowe hasło dwukrotnie, aby je zmienić.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Nowe hasło',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Potwierdź nowe hasło',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  if (_passwordErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordErrorMessage,
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
                    final newPassword = _newPasswordController.text.trim();
                    final confirmPassword = _confirmPasswordController.text.trim();
                    if (newPassword.isEmpty || confirmPassword.isEmpty) {
                      setState(() {
                        _passwordErrorMessage = 'Proszę wprowadzić hasło w obu polach.';
                      });
                      return;
                    }
                    if (newPassword != confirmPassword) {
                      setState(() {
                        _passwordErrorMessage = 'Hasła nie są zgodne.';
                      });
                      return;
                    }
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await user.updatePassword(newPassword);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hasło zostało zmienione.')),
                        );
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case 'weak-password':
                            setState(() {
                              _passwordErrorMessage = 'Hasło jest zbyt słabe.';
                            });
                            break;
                          default:
                            setState(() {
                              _passwordErrorMessage = 'Wystąpił nieznany błąd: ${e.message}';
                            });
                        }
                      } catch (e) {
                        setState(() {
                          _passwordErrorMessage = 'Wystąpił błąd: $e';
                        });
                      }
                    }
                  },
                  child: const Text('Zmień hasło'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
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
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    // Usuń dane użytkownika z Firestore
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                    // Usuń konto użytkownika z Firebase Authentication
                    await user.delete();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wystąpił błąd podczas usuwania konta: $e')),
                    );
                  }
                }
              },
              child: const Text('Usuń konto'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await _showConfirmationDialogWithLogo(context, 'Czy na pewno chcesz się wylogować?');
    if (confirm) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
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

  @override
  Widget build(BuildContext context) {
    final userEmail = userData['email'] ?? 'Nieznany email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6750A4),
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
            ListTile(
              title: const Text('Wyloguj się'),
              onTap: () => _signOut(context),
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