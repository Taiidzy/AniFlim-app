import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hugeicons/hugeicons.dart';
import '../screens/anime_offline_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../l10n/app_localizations.dart';

class DownloadedAnimeScreen extends StatefulWidget {
  const DownloadedAnimeScreen({super.key});

  @override
  _DownloadedAnimeScreenState createState() => _DownloadedAnimeScreenState();
}

class _DownloadedAnimeScreenState extends State<DownloadedAnimeScreen> {
  List<String> downloadedAnimeList = [];

  @override
  void initState() {
    super.initState();
    loadDownloadedAnime();
  }

  Future<void> loadDownloadedAnime() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    setState(() {
      downloadedAnimeList = keys.where((key) => key.startsWith('anime_')).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(localizations.downloadedanime),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: downloadedAnimeList.isEmpty
          ? const Center(child: Text('Аниме ещё не было скачено'))
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
        ),
        itemCount: downloadedAnimeList.length,
        itemBuilder: (context, index) {
          final animeKey = downloadedAnimeList[index];
          return FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final prefs = snapshot.data as SharedPreferences;
              final animeInfo = prefs.getStringList(animeKey);
              print('animeInfo: $animeInfo');

              // Проверяем, есть ли информация о аниме
              if (animeInfo == null || animeInfo.length < 3) {
                return Container(); // Возвращаем пустой контейнер, если данных недостаточно
              }

              final animeName = animeInfo[1];
              final posterPath = animeInfo[2];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeOfflineScreen(animeInfo: animeInfo),
                    ),
                  );
                },
                child: SizedBox(
                  height: 300,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Image.file(
                            File(posterPath),
                            fit: BoxFit.cover,
                            height: 240,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            animeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3), // Добавлен BottomNavBar
    );
  }
}
