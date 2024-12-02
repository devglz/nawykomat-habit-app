import 'package:flutter/material.dart';
import 'package:habit_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Proszę wprowadzić adres e-mail.');
      return;
    }

    if (password.isEmpty) {
      _showError('Proszę wprowadzić hasło.');
      return;
    }

    try {
      User? user = await AuthService().signInWithEmailAndPassword(email, password);
      if (user != null) {
        if (user.emailVerified) {
          Navigator.pushNamed(context, '/home');
        } else {
          _showError('Adres e-mail nie został zweryfikowany. Sprawdź swoją skrzynkę pocztową.');
          await user.sendEmailVerification();
        }
      } else {
        _showError('Nieprawidłowy e-mail lub hasło.');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _showError('Nieprawidłowy adres e-mail.');
          break;
        case 'user-disabled':
          _showError('Konto użytkownika zostało wyłączone.');
          break;
        case 'user-not-found':
        case 'wrong-password':
          _showError('Nieprawidłowy e-mail lub hasło.');
          break;
        default:
          _showError('Wystąpił nieznany błąd: ${e.message}');
      }
    } catch (e) {
      _showError('Wystąpił błąd: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await AuthService().signInWithGoogle();
      if (user != null) {
        Navigator.pushNamed(context, '/home');
      } else {
        _showError('Nie udało się zalogować przez Google.');
      }
    } catch (e) {
      _showError('Wystąpił błąd podczas logowania przez Google: $e');
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Proszę wprowadzić adres e-mail.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showError('E-mail do resetowania hasła został wysłany. Sprawdź swoją skrzynkę pocztową.');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _showError('Nieprawidłowy adres e-mail.');
          break;
        case 'user-not-found':
          _showError('Nie znaleziono użytkownika z tym adresem e-mail.');
          break;
        default:
          _showError('Wystąpił nieznany błąd: ${e.message}');
      }
    } catch (e) {
      _showError('Wystąpił błąd: $e');
    }
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
                      final userQuery = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
                      if (userQuery.isEmpty) {
                        setState(() {
                          _resetErrorMessage = 'Nie znaleziono użytkownika z tym adresem e-mail.';
                        });
                        return;
                      }
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      Navigator.of(context).pop();
                      _showError('E-mail do resetowania hasła został wysłany. Sprawdź swoją skrzynkę pocztową.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/app_logo.svg',
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Logowanie',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Hasło',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signInWithEmailAndPassword,
                    child: const Text('Zaloguj się'),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Nie masz konta? Zarejestruj się',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: _openResetPasswordDialog,
                    child: const Text(
                      'Nie pamiętasz hasła? Zresetuj je',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset('assets/google_logo.png', height: 24.0),
                    label: const Text('Zaloguj się przez Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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