import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/models/episodes_model.dart';
import 'package:AniFlim/models/progress_model.dart';
import 'package:AniFlim/player/online_player.dart';
import 'package:AniFlim/api/episodes_api.dart';
import 'package:AniFlim/api/user_api.dart';

class EpisodesAnime extends StatefulWidget {
  final String animeId;
  final String animename;

  const EpisodesAnime({
    super.key,
    required this.animeId,
    required this.animename,
  });

  @override
  _EpisodesAnimeState createState() => _EpisodesAnimeState();
}

class _EpisodesAnimeState extends State<EpisodesAnime> {
  List<Episode> episodeList = [];
  late TextEditingController _searchController;
  String? token;
  ProgressModel? progress;


  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    _searchController = TextEditingController();
    fetchEpisodes();

    provider.getToken().then((token) async {
      setState(() => this.token = token);
      await _getProgress(); // Добавляем await для асинхронного вызова
    });
  }

  Future<void> _getProgress() async {
    try {
      final _progress = await UserAPI.fetchProgress(token!, int.parse(widget.animeId));

      setState(() {
        progress = _progress; // Убираем явное приведение типа, так как _progress уже ProgressModel?
      });
    } catch (e) {
      print("Error fetching progress: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Episode> get filteredEpisodes {
    final searchText = _searchController.text;
    if (searchText.isEmpty) return episodeList;
    
    return episodeList.where((episode) {
      return episode.episode.toString().contains(searchText);
    }).toList();
  }

  Future<void> fetchEpisodes() async {
    try {
      final episodes = await EpisodesAPI.fetchAnimeEpisodes(widget.animeId);
      setState(() {
        episodeList = episodes;
      });
    } catch (e) {
      print("Error getting episodes for ${widget.animeId}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          if (episodeList.length > 24)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: localizations.searchEpisode,
                  hintText: localizations.enterEpisodeNumber,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEpisodes.length,
              itemBuilder: (context, index) {
                final episode = filteredEpisodes[index];
                final formattedEpisodeNumber = episode.episode.toString().padLeft(2, '0');

                // Проверяем, если progress уже получен и ID эпизода совпадает с ID прогресса
                final isSelected = progress != null && episode.id == progress!.episode;

                return Container(
                  // Если isSelected == true, устанавливаем фиолетовую обводку, иначе прозрачную
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.transparent,
                      width: 2, // можно варьировать ширину обводки по необходимости
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('${AppLocalizations.of(context).episode}: ${episode.ordinal}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EpisodePlayer(
                            episode: formattedEpisodeNumber,
                            episodeId: episode.id,
                            ordinal: episode.ordinal,
                            name: widget.animename,
                            animeId: widget.animeId,
                            time: progress != null ? progress!.currenttime.toString() : '0',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
