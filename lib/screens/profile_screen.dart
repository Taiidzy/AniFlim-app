import 'package:flutter/material.dart';
import '../api/all_api.dart';
import '../api/last_api.dart'; // Импорт API для последних аниме
import '../l10n/app_localizations.dart';
import '../models/all_model.dart';
import '../models/user_model.dart';
import '../models/last_model.dart'; // Импорт модели для последних аниме
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myprofile),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<All?>(
          future: AllAPI.All_anime(user.username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data available'));
            } else {
              final all = snapshot.data!;
              return FutureBuilder<List<Last>>(
                future: LastAPI.fetchLastAnime(user.username), // Запрос последних аниме
                builder: (context, lastSnapshot) {
                  if (lastSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (lastSnapshot.hasError) {
                    return Center(child: Text('Error: ${lastSnapshot.error}'));
                  } else if (!lastSnapshot.hasData || lastSnapshot.data == null) {
                    return const Center(child: Text('No recent anime available'));
                  } else {
                    final lastAnimeList = lastSnapshot.data!;
                    return ProfileMenu(
                      user: user,
                      all: all,
                      onLogout: onLogout,
                      lastAnimeList: lastAnimeList, // Передаем последние аниме
                    );
                  }
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
