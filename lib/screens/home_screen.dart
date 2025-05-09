import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:AniFlim/screens/search_anime_screen.dart';
import 'package:AniFlim/screens/settings_screen.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/widgets/bottom_nav_bar.dart';
import 'package:AniFlim/models/anime_model.dart';
import 'package:AniFlim/widgets/anime_card.dart';
import 'package:AniFlim/utils/resolution.dart';
import 'package:AniFlim/api/anime_api.dart';
import 'package:AniFlim/utils/helpers.dart';

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
  }

  Future<void> fetchAnime() async {
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
        centerTitle: true,
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
                          crossAxisCount: Resolution.getGridCount(context),
                          childAspectRatio: Resolution.getChildAspectRatio(context),
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
}

