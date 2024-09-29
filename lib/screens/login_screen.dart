import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../api/lists_api.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _loginController.text;
    final password = _passwordController.text;
    final localizations = AppLocalizations.of(context);

    if (_formKey.currentState?.validate() ?? false) {
      final user = await AuthAPI.login(username, password);

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        final userLists = await ListsAPI.fetchlists(user.username);
        if (userLists != null) {
          Provider.of<UserProvider>(context, listen: false).setUserLists(userLists);
        }
        widget.onLoginSuccess();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.lf),
            content: Text(localizations.iup),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.logIn),
        leading: IconButton(
          icon: HugeIcon( icon: HugeIcons.strokeRoundedArrowLeft02, color: isDarkTheme ? Colors.white : Colors.black, size: 24.0),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // Вернуться на главный экран
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purpleAccent, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizations.logIn,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _loginController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: localizations.login,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return localizations.enl;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: localizations.password,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return localizations.enp;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.3,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  localizations.logIn,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/register');
                                },
                                child: Text(localizations.register),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
