import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/all_model.dart';
import '../models/user_model.dart';
import '../models/last_model.dart'; // Импорт модели для последних аниме
import '../widgets/last_anime_card.dart'; // Импорт виджета карточки

class ProfileMenu extends StatelessWidget {
  final User user;
  final All all;
  final Function onLogout;
  final List<Last> lastAnimeList; // Добавляем список последних аниме

  const ProfileMenu({super.key, 
    required this.user,
    required this.all,
    required this.onLogout,
    required this.lastAnimeList, // Передаем список через конструктор
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView( // Используем ScrollView для прокрутки содержимого
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://aniflim.space/${user.avatar}'),
            radius: 50,
          ),
          const SizedBox(height: 16),
          Text(user.username, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Text('${localizations.all_watched}: ${all.all_watched}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Text('${localizations.all_watching}: ${all.all_watching}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onLogout();
            },
            child: Text(localizations.logout),
          ),
          const SizedBox(height: 16), // Добавляем отступ перед списком последних аниме
          Text(localizations.lastanime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true, // Чтобы GridView не занимал всю высоту
            physics: const NeverScrollableScrollPhysics(), // Отключаем прокрутку для GridView
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Две карточки в ряду
              childAspectRatio: 0.96, // Пропорции карточек
            ),
            itemCount: lastAnimeList.length, // Количество карточек
            itemBuilder: (context, index) {
              final anime = lastAnimeList[index];
              return LastCard(anime: anime); // Используем уже готовый виджет карточки
            },
          ),
        ],
      ),
    );
  }
}
