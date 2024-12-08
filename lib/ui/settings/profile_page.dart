import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_app/l10n/l10n.dart'; // Dodaj import

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
        final TextEditingController newEmailController = TextEditingController();
        final TextEditingController confirmEmailController = TextEditingController();
        String emailErrorMessage = '';

        void showEmailError(String message) {
          (context as Element).markNeedsBuild();
          emailErrorMessage = message;
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
                  Text(S.of(context).changeEmail), // Dodaj tłumaczenie
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).enterNewEmailTwice), // Dodaj tłumaczenie
                  const SizedBox(height: 16),
                  TextField(
                    controller: newEmailController,
                    decoration: InputDecoration(
                      labelText: S.of(context).newEmail, // Dodaj tłumaczenie
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmEmailController,
                    decoration: InputDecoration(
                      labelText: S.of(context).confirmNewEmail, // Dodaj tłumaczenie
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
                  child: Text(S.of(context).cancel), // Dodaj tłumaczenie
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newEmail = newEmailController.text.trim();
                    final confirmEmail = confirmEmailController.text.trim();
                    if (newEmail.isEmpty || confirmEmail.isEmpty) {
                      setState(() {
                        emailErrorMessage = S.of(context).enterEmailInBothFields; // Dodaj tłumaczenie
                      });
                      return;
                    }
                    if (newEmail != confirmEmail) {
                      setState(() {
                        emailErrorMessage = S.of(context).emailsDoNotMatch; // Dodaj tłumaczenie
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
                          SnackBar(content: Text(S.of(context).emailChangedCheckInbox)), // Dodaj tłumaczenie
                        );
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case 'invalid-email':
                            setState(() {
                              emailErrorMessage = S.of(context).invalidEmail; // Dodaj tłumaczenie
                            });
                            break;
                          case 'email-already-in-use':
                            setState(() {
                              emailErrorMessage = S.of(context).emailAlreadyInUse; // Dodaj tłumaczenie
                            });
                            break;
                          default:
                            setState(() {
                              emailErrorMessage = '${S.of(context).unknownError}: ${e.message}'; // Dodaj tłumaczenie
                            });
                        }
                      } catch (e) {
                        setState(() {
                          emailErrorMessage = '${S.of(context).error}: $e'; // Dodaj tłumaczenie
                        });
                      }
                    }
                  },
                  child: Text(S.of(context).changeEmail), // Dodaj tłumaczenie
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
        final TextEditingController newPasswordController = TextEditingController();
        final TextEditingController confirmPasswordController = TextEditingController();
        String passwordErrorMessage = '';

        void showPasswordError(String message) {
          (context as Element).markNeedsBuild();
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
                  Text(S.of(context).changePassword), // Dodaj tłumaczenie
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).enterNewPasswordTwice), // Dodaj tłumaczenie
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: S.of(context).newPassword, // Dodaj tłumaczenie
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: S.of(context).confirmNewPassword, // Dodaj tłumaczenie
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  if (passwordErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        passwordErrorMessage,
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
                  child: Text(S.of(context).cancel), // Dodaj tłumaczenie
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newPassword = newPasswordController.text.trim();
                    final confirmPassword = confirmPasswordController.text.trim();
                    if (newPassword.isEmpty || confirmPassword.isEmpty) {
                      setState(() {
                        passwordErrorMessage = S.of(context).enterPasswordInBothFields; // Dodaj tłumaczenie
                      });
                      return;
                    }
                    if (newPassword != confirmPassword) {
                      setState(() {
                        passwordErrorMessage = S.of(context).passwordsDoNotMatch; // Dodaj tłumaczenie
                      });
                      return;
                    }
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await user.updatePassword(newPassword);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context).passwordChanged)), // Dodaj tłumaczenie
                        );
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case 'weak-password':
                            setState(() {
                              passwordErrorMessage = S.of(context).weakPassword; // Dodaj tłumaczenie
                            });
                            break;
                          default:
                            setState(() {
                              passwordErrorMessage = '${S.of(context).unknownError}: ${e.message}'; // Dodaj tłumaczenie
                            });
                        }
                      } catch (e) {
                        setState(() {
                          passwordErrorMessage = '${S.of(context).error}: $e'; // Dodaj tłumaczenie
                        });
                      }
                    }
                  },
                  child: Text(S.of(context).changePassword), // Dodaj tłumaczenie
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
              Text(S.of(context).deleteAccount), // Dodaj tłumaczenie
            ],
          ),
          content: Text(S.of(context).confirmDeleteAccount), // Dodaj tłumaczenie
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel), // Dodaj tłumaczenie
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
                      SnackBar(content: Text('${S.of(context).errorDeletingAccount}: $e')), // Dodaj tłumaczenie
                    );
                  }
                }
              },
              child: Text(S.of(context).deleteAccount), // Dodaj tłumaczenie
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await _showConfirmationDialogWithLogo(context, S.of(context).confirmSignOut); // Dodaj tłumaczenie
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
              Text(S.of(context).confirmation), // Dodaj tłumaczenie
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(S.of(context).yes), // Dodaj tłumaczenie
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(S.of(context).no), // Dodaj tłumaczenie
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context); // Poprawiony dostęp do lokalizacji
    final userEmail = userData['email'] ?? localizations.unknownEmail;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile, style: const TextStyle(color: Colors.white)),
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
                  return Center(child: Text(localizations.error)); // Dodaj tłumaczenie
                }
                final userName = snapshot.data ?? localizations.unknownName;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['profilePictureUrl'] ?? 'https://via.placeholder.com/150'),
                    child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
                  ),
                  title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            _buildSectionHeader(localizations.timeRange), // Dodaj tłumaczenie
            ListTile(
              title: Text(localizations.thisWeek), // Dodaj tłumaczenie
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Zmiana zakresu danych czasowych
                },
              ),
            ),
            const Divider(),
            _buildSectionHeader(localizations.quickStats), // Dodaj tłumaczenie
            ListTile(
              title: Text(localizations.totalWorkHours), // Dodaj tłumaczenie
              subtitle: const Text('40 hours'), // Przykładowa wartość
            ),
            ListTile(
              title: Text(localizations.completedTasks), // Dodaj tłumaczenie
              subtitle: const Text('15 tasks'), // Przykładowa wartość
            ),
            const Divider(),
            _buildSectionHeader(localizations.graphicalVisualizations), // Dodaj tłumaczenie
            // Dodaj tutaj wykresy lub inne wizualizacje
            const Divider(),
            _buildSectionHeader(localizations.additionalOptions), // Dodaj tłumaczenie
            ListTile(
              title: Text(localizations.paymentMethods), // Dodaj tłumaczenie
              onTap: () {
                // Zarządzanie metodami płatności
              },
            ),
            ListTile(
              title: Text(localizations.longestStreak), // Dodaj tłumaczenie
              subtitle: const Text('20 days'), // Przykładowa wartość
            ),
            const Divider(),
            _buildSectionHeader(localizations.accountSettings), // Dodaj tłumaczenie
            ListTile(
              title: Text(localizations.changeEmail), // Dodaj tłumaczenie
              onTap: () => _changeEmail(context),
            ),
            ListTile(
              title: Text(localizations.changePassword), // Dodaj tłumaczenie
              onTap: () => _changePassword(context),
            ),
            ListTile(
              title: Text(localizations.deleteAccount), // Dodaj tłumaczenie
              onTap: () => _deleteAccount(context),
            ),
            ListTile(
              title: Text(localizations.signOut), // Dodaj tłumaczenie
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