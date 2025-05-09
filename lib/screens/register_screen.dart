import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/api/auth_api.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _passwordController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordControllerConfirmation = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _characterImages = [
    'https://i.pinimg.com/originals/de/14/48/de14480c364250016277d1daac1136db.png',
    'https://s-media-cache-ak0.pinimg.com/originals/d5/59/f8/d559f814c47faedc6ba0578b05a7c75f.png',
  ];

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _passwordControllerConfirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final login = _loginController.text;
    final password = _passwordController.text;
    final passwordConfirm = _passwordControllerConfirmation.text;
    final localizations = AppLocalizations.of(context);

    if (password != passwordConfirm) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            localizations.rf,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            localizations.pdm,
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
      return;
    }

    final reg = await AuthAPI.register(login, password);
    if (reg == 200) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            localizations.rf,
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
                    localizations.registration,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordControllerConfirmation,
                decoration: InputDecoration(
                  prefixIcon: const Icon(HugeIcons.strokeRoundedSquareLockCheck01, color: Color.fromARGB(181, 102, 80, 164)),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    localizations.register,
                    style: const TextStyle(fontSize: 16 * 1.2, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/profile');
                },
                child: Text(
                  localizations.logIn,
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
