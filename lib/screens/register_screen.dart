import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../api/auth_api.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final login = _loginController.text;
    final password = _passwordController.text;
    final email = _emailController.text;
    final localizations = AppLocalizations.of(context);

    final reg = await AuthAPI.register(login, password, email);
    if (reg == 200) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.rf),
          content: Text(localizations.iupe),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.registration),
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
                          localizations.registration,
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
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email),
                                  labelText: localizations.email,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return localizations.ene;
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
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.2,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  localizations.register,
                                  style: const TextStyle(fontSize: 16),
                                ),
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
