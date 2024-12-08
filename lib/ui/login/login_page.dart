import 'package:flutter/material.dart';
import 'package:habit_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj ten import
import 'package:habit_app/main.dart'; // Dodaj import dla MyApp

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
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
      _showError(S.of(context).enterEmail);
      return;
    }

    if (password.isEmpty) {
      _showError(S.of(context).enterPassword);
      return;
    }

    try {
      User? user = await AuthService().signInWithEmailAndPassword(email, password);
      if (user != null) {
        if (user.emailVerified) {
          if (!mounted) return;
          Navigator.pushNamed(context, '/home');
        } else {
          _showError(S.of(context).emailNotVerified);
          await user.sendEmailVerification();
        }
      } else {
        _showError(S.of(context).invalidEmailOrPassword);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _showError(S.of(context).invalidEmail);
          break;
        case 'user-disabled':
          _showError(S.of(context).userDisabled);
          break;
        case 'user-not-found':
        case 'wrong-password':
          _showError(S.of(context).invalidEmailOrPassword);
          break;
        default:
          _showError(S.of(context).unknownError(e.message ?? ''));
      }
    } catch (e) {
      _showError(S.of(context).errorMessage(e.toString()));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await AuthService().signInWithGoogle();
      if (user != null) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/home');
      } else {
        _showError(S.of(context).googleSignInFailed);
      }
    } catch (e) {
      _showError(S.of(context).googleSignInError(e.toString()));
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError(S.of(context).enterEmail);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showError(S.of(context).resetPasswordEmailSent);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          _showError(S.of(context).invalidEmail);
          break;
        case 'user-not-found':
          _showError(S.of(context).userNotFound);
          break;
        default:
          _showError(S.of(context).unknownError(e.message ?? ''));
      }
    } catch (e) {
      _showError(S.of(context).errorMessage(e.toString()));
    }
  }

  void _openResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController resetEmailController = TextEditingController();
        String resetErrorMessage = '';

        void showResetError(String message) {
          setState(() {
            resetErrorMessage = message;
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
                  Text(S.of(context).resetPassword),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).resetPasswordDescription),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (resetErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        resetErrorMessage,
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
                  child: Text(S.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = resetEmailController.text.trim();
                    if (email.isEmpty) {
                      setState(() {
                        resetErrorMessage = S.of(context).enterEmail;
                      });
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      _showError(S.of(context).resetPasswordEmailSent);
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case 'invalid-email':
                          setState(() {
                            resetErrorMessage = S.of(context).invalidEmail;
                          });
                          break;
                        default:
                          setState(() {
                            resetErrorMessage = S.of(context).unknownError(e.message ?? '');
                          });
                      }
                    } catch (e) {
                      setState(() {
                        resetErrorMessage = S.of(context).errorMessage(e.toString());
                      });
                    }
                  },
                  child: Text(S.of(context).resetPassword),
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
                  margin: const EdgeInsets.only(top: 50), // Obniż cały ekran logowania
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0),
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
                        localizations.login,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                      ElevatedButton(
                        onPressed: _signInWithEmailAndPassword,
                        child: Text(localizations.signIn),
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
                        onPressed: _openResetPasswordDialog,
                        child: Text(localizations.forgotPassword),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(localizations.createAccount),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: SvgPicture.asset(
                          'assets/google_logo.svg',
                          height: 24,
                        ),
                        label: Text(localizations.signInWithGoogle),
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