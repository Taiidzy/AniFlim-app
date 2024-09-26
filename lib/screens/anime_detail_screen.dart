import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../l10n/app_localizations.dart';
import '../models/anime_model.dart';
import '../widgets/detail_anime.dart';
import '../widgets/episodes_anime.dart';

class AnimeDetailScreen extends StatefulWidget {
  final Anime anime;

  AnimeDetailScreen({required this.anime});

  @override
  _AnimeDetailScreenState createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  bool showDetail = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon( icon: HugeIcons.strokeRoundedArrowLeft02, color: Colors.grey, size: 24.0, ),
          onPressed: () {
            Navigator.pop(context); // Вернуться на предыдущий экран
          },
        ),
        title: Text(widget.anime.name),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showDetail = true;
                    });
                  },
                  child: Text(localizations.detail),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showDetail = false;
                    });
                  },
                  child: Text(localizations.watch),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: showDetail
                  ? DetailAnime(anime: widget.anime)
                  : EpisodesAnime(animeId: widget.anime.id, animename: widget.anime.name), // Передача anime_id
            ),
          ),
        ],
      ),
    );
  }
}
