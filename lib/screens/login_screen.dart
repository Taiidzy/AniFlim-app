import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

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
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Список URL изображений аниме-персонажей
  final List<String> _characterImages = [
    'https://i.pinimg.com/originals/ac/69/c9/ac69c90d9ab7636ee8966d345b38cad8.png',
    'https://s-media-cache-ak0.pinimg.com/originals/1d/75/78/1d757811194ce7a2ab13b4a78ffb3d58.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loginFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_loginFocusNode.hasFocus && !_passwordFocusNode.hasFocus) {
      // Сбрасываем состояние клавиатуры при потере фокуса
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
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
                      localizations.logIn,
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
                TextFormField(
                  controller: _loginController,
                  focusNode: _loginFocusNode,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
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
                const SizedBox(height: 20),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkTheme 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          localizations.rememberMe, 
                          style: TextStyle(
                            fontSize: 16, 
                            color: isDarkTheme ? Colors.white : Colors.black87
                          )
                        ),
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value;
                          });
                        },
                      ),
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
                        onPressed: () => _login(_rememberMe),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations.logIn,
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
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: Text(
                    localizations.register,
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
