import 'package:flutter/material.dart';

import '../api/all_api.dart';
import '../l10n/app_localizations.dart';
import '../models/all_model.dart';
import '../models/user_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {  // Исправляем на StatelessWidget
  final User user;  // Поле для данных пользователя
  final VoidCallback onLogout;  // Колбэк для выхода из профиля

  ProfileScreen({required this.user, required this.onLogout});  // Конструктор

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);  // Локализация

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myprofile),  // Заголовок экрана
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<All?>(
          future: AllAPI.All_anime(user.username),  // Асинхронный вызов API
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());  // Индикатор загрузки
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));  // Обработка ошибки
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available'));  // Нет данных
            } else {
              final all = snapshot.data!;
              return ProfileMenu(user: user, all: all, onLogout: onLogout);  // Отображение меню профиля
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),  // Навигационная панель
    );
  }
}
