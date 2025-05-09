import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/api/auth_api.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  // Список URL изображений аниме-персонажей
  final List<String> _characterImages = [
    'https://i.pinimg.com/originals/ac/69/c9/ac69c90d9ab7636ee8966d345b38cad8.png',
    'https://s-media-cache-ak0.pinimg.com/originals/1d/75/78/1d757811194ce7a2ab13b4a78ffb3d58.jpg',
  ];

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(bool rememberMe) async {
    final username = _loginController.text;
    final password = _passwordController.text;
    final localizations = AppLocalizations.of(context);

    if (_formKey.currentState?.validate() ?? false) {
      final token = await AuthAPI.login(username, password, rememberMe);
      if (token != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setToken(token as String?);
        widget.onLoginSuccess();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[800],
            title: Text(
              localizations.lf,
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              localizations.iup,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Форма логина, общая для всех экранов.
  Widget _buildLoginForm(AppLocalizations localizations, Size screenSize) {
    return Card(
      color: const Color.fromARGB(255, 59, 59, 59).withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопка возврата и заголовок
              Row(
                children: [
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft02,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                  const Spacer(),
                  Text(
                    localizations.logIn,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(HugeIcons.strokeRoundedUser, color: Color.fromARGB(181, 102, 80, 164)),
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
                  prefixIcon: const Icon(HugeIcons.strokeRoundedSquareLock02, color: Color.fromARGB(181, 102, 80, 164)),
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
              SwitchListTile(
                title: Text(localizations.rememberMe, style: TextStyle(fontSize: 16, color: Colors.white)),
                value: _rememberMe,
                onChanged: (value) {
                    setState(() {
                      _rememberMe = value;
                    });
                  },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _login(_rememberMe),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    localizations.logIn,
                    style: const TextStyle(fontSize: 16 * 1.2, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: Text(
                  localizations.register,
                  style: const TextStyle(color: Colors.purpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Виджет с изображением аниме-персонажа, предназначенный для ПК (отображается слева)
  Widget _buildSideImage(double maxWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 280,
      child: Image.network(
        _characterImages[0],
        fit: BoxFit.contain,
      ),
    );
  }

  /// Виджет с изображением аниме-персонажа для мобильных устройств (отображается сверху)
  Widget _buildTopImage(double maxWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 150,
      child: Image.network(
        _characterImages[1],
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Если ширина экрана больше 600 - считаем это ПК/планшет, иначе мобильное устройство.
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  // Слева изображения (аниме-персонаж)
                  _buildSideImage(screenSize.width),
                  // Справа форма логина
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: _buildLoginForm(localizations, screenSize),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // На мобильном устройствах сначала изображение сверху
                    _buildTopImage(screenSize.width),
                    // Затем форма логина
                    _buildLoginForm(localizations, screenSize),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
