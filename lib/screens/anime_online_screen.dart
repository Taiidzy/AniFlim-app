import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

import 'package:AniFlim/widgets/episodes_anime_online.dart';
import 'package:AniFlim/models/anime_detail_model.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/widgets/detail_anime.dart';
import 'package:AniFlim/widgets/related_seasons.dart';
import 'package:AniFlim/api/anime_api.dart';
import 'package:AniFlim/utils/constants.dart';

class AnimeOnlineScreen extends StatefulWidget {
  final String animeId;

  const AnimeOnlineScreen({super.key, required this.animeId});

  @override
  _AnimeOnlineScreenState createState() => _AnimeOnlineScreenState();
}

class _AnimeOnlineScreenState extends State<AnimeOnlineScreen> with SingleTickerProviderStateMixin {
  late AnimeDetail anime;
  late TabController _tabController;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnimeDetail();
  }

  Future<void> _loadAnimeDetail() async {
    try {
      final fetchedAnime = await AnimeAPI.fetchAnimeDetail(widget.animeId);
      setState(() {
        anime = fetchedAnime;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Ошибка')),
        body: Center(child: Text('Ошибка: $errorMessage')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(storageApi + anime.img),
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
                        child: PreferredSize(
                          preferredSize: const Size.fromHeight(kToolbarHeight + 48), // Высота AppBar + TabBar
                          child: Container(
                            height: kToolbarHeight + 48,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  leading: IconButton(
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedArrowLeft02,
                                      color: isDarkTheme ? Colors.white : Colors.black,
                                      size: 24.0,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  title: Text(
                                    anime.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkTheme ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                TabBar(
                                  controller: _tabController,
                                  indicatorColor: Colors.purple,
                                  labelColor: isDarkTheme ? Colors.white : Colors.black87,
                                  unselectedLabelColor: isDarkTheme ? Colors.white70 : Colors.black54,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  tabs: [
                                    Tab(text: localizations.detail),
                                    Tab(text: localizations.watch),
                                    Tab(
                                      child: Text(
                                        localizations.relatedAnime,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkTheme 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkTheme 
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: DetailAnime(anime: anime),
                            ),
                          ),
                        ),
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkTheme 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkTheme 
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: EpisodesAnime(animeId: anime.id, animename: anime.name, img: anime.img),
                            ),
                          ),
                        ),
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkTheme 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkTheme 
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: RelatedSeasons(
                                animeId: anime.id,
                                currentAnimeName: anime.name,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
