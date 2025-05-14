import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/providers/user_provider.dart';
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
    if (reg == 201) {
      final token = await AuthAPI.login(login, password, true);
      if (token != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setToken(token as String?);
      }
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkTheme 
              ? Colors.black.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkTheme 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            ),
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft02,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        size: 24.0,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                    const Spacer(),
                    Text(
                      localizations.registration,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: TextFormField(
                      controller: _loginController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(HugeIcons.strokeRoundedUser, color: Color.fromARGB(181, 102, 80, 164)),
                        labelText: localizations.login,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDarkTheme 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.enl;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(HugeIcons.strokeRoundedSquareLock02, color: Color.fromARGB(181, 102, 80, 164)),
                        labelText: localizations.password,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDarkTheme 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.enp;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: TextFormField(
                      controller: _passwordControllerConfirmation,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(HugeIcons.strokeRoundedSquareLockCheck01, color: Color.fromARGB(181, 102, 80, 164)),
                        labelText: localizations.passwordConfirmation,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDarkTheme 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.enp;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations.register,
                          style: const TextStyle(
                            fontSize: 16 * 1.2, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          ),
                        ),
                      ),
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
                    style: TextStyle(
                      color: isDarkTheme ? Colors.purpleAccent : Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://pic.rutubelist.ru/video/2024-10-08/01/da/01daee6107408babfd3c400d734f36ec.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Row(
                      children: [
                        _buildSideImage(screenSize.width),
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
                          _buildTopImage(screenSize.width),
                          _buildLoginForm(localizations, screenSize),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
