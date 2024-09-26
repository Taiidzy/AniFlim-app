import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/auth_api.dart';
import '../api/lists_api.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  LoginScreen({required this.onLoginSuccess});

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

  Future _reg() async {
    Navigator.pushReplacementNamed(context, '/register');
  }

  Future<void> _login() async {
    final username = _loginController.text;
    final password = _passwordController.text;
    final localizations = AppLocalizations.of(context)!;

    if (_formKey.currentState?.validate() ?? false) {
      final user = await AuthAPI.login(username, password);

      if (user != null) {
        // Сохраните информацию о пользователе
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        // Загрузите списки пользователя после входа
        final userLists = await ListsAPI.fetchlists(user.username);
        if (userLists != null) {
          Provider.of<UserProvider>(context, listen: false).setUserLists(userLists);
        }
        widget.onLoginSuccess(); // Вызов функции при успешном входе
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.lf),
            content: Text(localizations.iup),
            actions: [
              TextButton(
                child: Text('OK'),
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
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.logIn),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // Вернуться на предыдущий экран
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(labelText: localizations.login),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enl;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: localizations.password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enp;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text(localizations.logIn),
              ),
              ElevatedButton(
                onPressed: _reg,
                child: Text(localizations.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
