import 'package:flutter/material.dart';

import '../api/all_api.dart';
import '../l10n/app_localizations.dart';
import '../models/all_model.dart';
import '../models/user_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_menutelessWidget {
  final User user; // Используем правильный тип данных
  final VoidCallback onLogout;

  ProfileScreen({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myprofile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<All?>(
          future: AllAPI.All_anime(user.username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available'));
            } else {
              final all = snapshot.data!;
              return ProfileMenu(user: user, all: all, onLogout: onLogout);
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1), // Устанавливаем индекс для "Profile"
    );
  }
}
