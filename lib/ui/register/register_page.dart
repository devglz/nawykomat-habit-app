import 'package:flutter/material.dart';
import 'package:habit_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Dodaj ten import
import 'package:flutter_svg/flutter_svg.dart';
// Dodaj ten import
import 'package:habit_app/l10n/l10n.dart'; // Dodaj ten import
import 'package:habit_app/main.dart'; // Dodaj import dla MyApp

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _errorMessage = '';

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> saveUserName(String uid, String name) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
    });
  }

  Future<void> _sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _showError(S.of(context).errorMessage(e.message ?? ''));
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      _showError(S.of(context).enterEmail);
      return;
    }

    if (password.isEmpty) {
      _showError(S.of(context).enterPassword);
      return;
    }

    if (confirmPassword.isEmpty) {
      _showError(S.of(context).enterPasswordInBothFields);
      return;
    }

    if (password != confirmPassword) {
      _showError(S.of(context).passwordsDoNotMatch);
      return;
    }

    try {
      User? user = await AuthService().registerWithEmailAndPassword(email, password);
      if (user != null) {
        await saveUserName(user.uid, name); // Zapisz imię użytkownika
        await _sendVerificationEmail(user); // Wyślij e-mail weryfikacyjny
        _showError(S.of(context).emailChangedCheckInbox);
      } else {
        _showError(S.of(context).unknownError(''));
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _showError(S.of(context).emailAlreadyInUse);
          break;
        case 'invalid-email':
          _showError(S.of(context).invalidEmail);
          break;
        case 'operation-not-allowed':
          _showError(S.of(context).unknownError(S.of(context).error));
          break;
        case 'weak-password':
          _showError(S.of(context).weakPassword);
          break;
        default:
          _showError(S.of(context).unknownError(e.message ?? ''));
      }
    } catch (e) {
      _showError(S.of(context).errorMessage(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Dodaj dostęp do lokalizacji

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20, // Przesuń flagi bardziej do góry
              left: 20,
              child: DropdownButton<Locale>(
                value: MyApp.of(context)?.locale ?? S.delegate.supportedLocales.first,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    setState(() {
                      MyApp.of(context)?.setLocale(newLocale);
                    });
                  }
                },
                items: S.delegate.supportedLocales.map<DropdownMenuItem<Locale>>((Locale locale) {
                  final flag = getFlag(locale.languageCode);
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          flag,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(locale.languageCode.toUpperCase(), style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
                underline: Container(), // Usunięcie kreski
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: const EdgeInsets.only(top: 50), // Obniż cały ekran rejestracji
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
                        localizations.createAccount,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: localizations.profile,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: localizations.email,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: localizations.password,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: localizations.confirmNewPassword,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        child: Text(localizations.createAccount),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(localizations.signIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'assets/flags/gb.svg';
      case 'pl':
        return 'assets/flags/pl.svg';
      case 'de':
        return 'assets/flags/de.svg';
      case 'es':
        return 'assets/flags/es.svg';
      case 'fr':
        return 'assets/flags/fr.svg';
      case 'zh':
        return 'assets/flags/cn.svg';
      default:
        return 'assets/flags/unknown.svg';
    }
  }
}
