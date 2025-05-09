import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/widgets/episodes_anime_online.dart';
import 'package:AniFlim/models/anime_detail_model.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/widgets/detail_anime.dart';
import 'package:AniFlim/api/anime_api.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: isDarkTheme ? Colors.white : Colors.black,
            size: 24.0,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(anime.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          tabs: [
            Tab(text: localizations.detail),
            Tab(text: localizations.watch),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DetailAnime(anime: anime),
          EpisodesAnime(animeId: anime.id, animename: anime.name),
        ],
      ),
    );
  }
}
