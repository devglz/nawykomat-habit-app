// lib/ui/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_app/main.dart'; // Dodaj ten import
import 'personalization_page.dart'; // Dodaj ten import
import './notifications_page.dart'; // Poprawiony import
import 'support_pages.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Import MyApp
import 'package:habit_app/l10n/l10n.dart'; // Import L10n
// Poprawiony import

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
      'email': user?.email ?? S.of(context).unknownEmail,
      'name': user?.displayName ?? S.of(context).unknownName
    };
  }

  Future<String> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? S.of(context).unknownName;
      }
    }
    return S.of(context).unknownName;
  }

  Future<void> _changeEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.sendEmailVerification();
        if (mounted) _showMessage(S.of(context).emailChangedCheckInbox);
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          switch (e.code) {
            case 'invalid-email':
              _showMessage(S.of(context).invalidEmail);
              break;
            case 'email-already-in-use':
              _showMessage(S.of(context).emailAlreadyInUse);
              break;
            default:
              _showMessage(S.of(context).unknownError(e.message ?? ''));
          }
        }
      } catch (e) {
        if (mounted) _showMessage(S.of(context).unknownError(e.toString()));
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
      if (mounted) _showMessage(S.of(context).resetPasswordEmailSent);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        switch (e.code) {
          case 'invalid-email':
            _showMessage(S.of(context).invalidEmail);
            break;
          case 'user-not-found':
            _showMessage(S.of(context).userNotFound);
            break;
          default:
            _showMessage(S.of(context).unknownError(e.message ?? ''));
        }
      }
    } catch (e) {
      if (mounted) _showMessage(S.of(context).unknownError(e.toString()));
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
              Text(S.of(context).deleteAccountTitle),
            ],
          ),
          content: Text(S.of(context).deleteAccountConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteAccount();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: Text(S.of(context).deleteAccount),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _openResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController resetEmailController = TextEditingController();
        String resetErrorMessage = '';

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
                  Text(S.of(context).resetPasswordTitle),
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
                      labelText: S.of(context).email,
                      border: const OutlineInputBorder(),
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
                      if (mounted) {
                        Navigator.of(context).pop();
                        _showMessage(S.of(context).resetPasswordEmailSent);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (mounted) {
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
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          resetErrorMessage = S.of(context).unknownError(e.toString());
                        });
                      }
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

  void _openChangeEmailDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController newEmailController = TextEditingController();
        final TextEditingController confirmEmailController = TextEditingController();
        String emailErrorMessage = '';

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
                  Text(S.of(context).changeEmailTitle),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).changeEmailDescription),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newEmailController,
                    decoration: InputDecoration(
                      labelText: S.of(context).newEmail,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmEmailController,
                    decoration: InputDecoration(
                      labelText: S.of(context).confirmNewEmail,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (emailErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        emailErrorMessage,
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
                    final newEmail = newEmailController.text.trim();
                    final confirmEmail = confirmEmailController.text.trim();
                    if (newEmail.isEmpty || confirmEmail.isEmpty) {
                      setState(() {
                        emailErrorMessage = S.of(context).enterEmailInBothFields;
                      });
                      return;
                    }
                    if (newEmail != confirmEmail) {
                      setState(() {
                        emailErrorMessage = S.of(context).emailsDoNotMatch;
                      });
                      return;
                    }
                    await _changeEmail(newEmail);
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).changeEmail),
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
              Text(S.of(context).signOutTitle),
            ],
          ),
          content: Text(S.of(context).signOutConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await _signOut();
              },
              child: Text(S.of(context).signOut),
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

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings, style: TextStyle(color: Colors.white)),
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
              return Center(child: Text(S.of(context).loadingError));
            }

            final userData = snapshot.data ?? {};
            final userEmail = userData['email'] ?? S.of(context).unknownEmail;

            return ListView(
              children: [
                _buildSectionHeader(localizations.profile),
                FutureBuilder<String>(
                  future: fetchUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text(S.of(context).loadingError));
                    }
                    final userName = snapshot.data ?? S.of(context).unknownName;
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
                _buildSectionHeader(localizations.generalSettings), // Zmieniono na generalSettings
                ListTile(
                  title: Text(localizations.notifications),
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
                  title: Text(localizations.morePersonalization),
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
                  title: Text(localizations.darkMode),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: _toggleDarkMode,
                  ),
                ),
                ListTile(
                  title: Text(localizations.language),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        getFlag((MyApp.of(context)?.locale ?? S.delegate.supportedLocales.first).languageCode),
                        width: 24,
                        height: 24,
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(localizations.selectLanguage),
                          content: Container(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 16), // Dodaj odstęp
                                Center(
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: S.delegate.supportedLocales.map((locale) {
                                      final flag = getFlag(locale.languageCode);
                                      return GestureDetector(
                                        onTap: () {
                                          MyApp.of(context)?.setLocale(locale);
                                          Navigator.of(context).pop();
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              flag,
                                              width: 60,
                                              height: 60,
                                            ),
                                            SizedBox(height: 8),
                                            Text(locale.languageCode.toUpperCase()),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                _buildSectionHeader(localizations.accountSettings), // Zmieniono na accountSettings
                ListTile(
                  title: Text(localizations.changeEmail),
                  onTap: _openChangeEmailDialog,
                ),
                ListTile(
                  title: Text(localizations.changePassword),
                  onTap: _openResetPasswordDialog,
                ),
                ListTile(
                  title: Text(localizations.deleteAccount),
                  onTap: _openDeleteAccountDialog,
                ),
                ListTile(
                  title: Text(localizations.signOut),
                  onTap: _openSignOutDialog,
                ),
                const Divider(),
                _buildSectionHeader(localizations.support),
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: Text(localizations.contact),
                  subtitle: Text(localizations.contactSupportSubtitle),
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
                  title: Text(localizations.feedback),
                  subtitle: Text(localizations.feedbackSubtitle),
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
                  title: Text(localizations.privacyPolicy),
                  subtitle: Text(localizations.privacyPolicySubtitle),
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
                  title: Text(localizations.aboutApp),
                  subtitle: Text(localizations.aboutAppSubtitle),
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
              Text(S.of(context).confirmation),
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