import 'dart:io'; // Для определения платформы
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Для Web
import 'package:desktop_window/desktop_window.dart'; // Для Windows/macOS
import '../api/anime_api.dart';
import '../l10n/app_localizations.dart';
import '../models/anime_model.dart';
import '../utils/helpers.dart';
import '../widgets/anime_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'search_anime_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Anime> animeList = [];

  @override
  void initState() {
    super.initState();
    fetchAnime();
    _configureWindowSize(); // Настроим размер окна на десктопе
  }

  Future<void> fetchAnime() async {
    print('fetchAnime called');
    const maxRetries = 3; // 1 основная + 2 повторные попытки
    int attempt = 0;
    bool success = false;

    while (attempt < maxRetries && !success) {
      try {
        animeList = await AnimeAPI.fetchAnimeList();
        if (mounted) {
          setState(() {});
        }
        success = true;
      } catch (e) {
        attempt++;
        print('Attempt $attempt failed: $e');
        
        if (attempt >= maxRetries) {
          if (mounted) {
            showErrorDialog(context, 'Не удалось загрузить список аниме после $maxRetries попыток.');
          }
        } else {
          // Добавляем задержку перед следующей попыткой
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }

  void _configureWindowSize() async {
    if (Platform.isMacOS || Platform.isWindows) {
      await DesktopWindow.setWindowSize(const Size(900, 600));
    }
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: SearchAnime(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Группируем аниме по дню выхода
    Map<int, List<Anime>> groupedAnime = {};
    for (var anime in animeList) {
      int day = anime.publishDayValue;
      groupedAnime.putIfAbsent(day, () => []).add(anime);
    }

    final sortedDays = groupedAnime.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(localizations.schedule, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch02,
              color: isDarkTheme ? Colors.white : Colors.black,
              size: 22.0,
            ),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings02,
              color: isDarkTheme ? Colors.white : Colors.black,
              size: 22.0,
            ),
            onPressed: () {
              if (Platform.isIOS) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              } else {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),
        ],
      ),
      body: animeList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: sortedDays.map((day) {
                final dayDescription = groupedAnime[day]!.isNotEmpty
                    ? groupedAnime[day]![0].publishDayDescription
                    : '';
                final animesForDay = groupedAnime[day]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          dayDescription,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getGridCount(context),
                          childAspectRatio: 0.65,
                        ),
                        itemCount: animesForDay.length,
                        itemBuilder: (context, index) {
                          return AnimeCard(anime: animesForDay[index]);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: kIsWeb ? null : const BottomNavBar(currentIndex: 0),
    );
  }

  int _getGridCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (Platform.isMacOS || Platform.isWindows) {
      return width > 1200 ? 4 : 3;
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 2;
    } else {
      return 2;
    }
  }
}

