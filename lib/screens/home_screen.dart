import 'dart:io';
import 'dart:ui';

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
      extendBodyBehindAppBar: true,
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
              child: Column(
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkTheme 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          automaticallyImplyLeading: false,
                          title: Text(
                            localizations.schedule,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black87,
                            ),
                          ),
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
                      ),
                    ),
                  ),
                  Expanded(
                    child: animeList.isEmpty
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
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkTheme ? Colors.white : Colors.black87,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: kIsWeb ? null : ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkTheme 
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: isDarkTheme 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: const BottomNavBar(currentIndex: 0),
          ),
        ),
      ),
    );
  }
}

