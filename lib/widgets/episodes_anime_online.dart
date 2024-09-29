import 'package:flutter/material.dart';
import '../api/episodes_api.dart';
import '../l10n/app_localizations.dart';
import '../models/episodes_model.dart';
import '../player/online_player.dart';

class EpisodesAnime extends StatefulWidget {
  final String animeId;
  final String animename;

  const EpisodesAnime({super.key, required this.animeId, required this.animename});

  @override
  _EpisodesAnimeState createState() => _EpisodesAnimeState();
}

class _EpisodesAnimeState extends State<EpisodesAnime> {
  List<Episodes> episodeList = [];

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    try {
      final int animeId = int.parse(widget.animeId);
      final episodes = await EpisodesAPI.fetchAnimeEpisodes(animeId);
      setState(() {
        episodeList = episodes; // Присвоение пустого списка, если episodes == null
      });
    } catch (e) {
      print("Error getting list of anime episodes for anime ${widget.animeId}, error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: episodeList.length,
        itemBuilder: (context, index) {
          final episode = episodeList[index];
          final formattedEpisodeNumber = episode.episode.toString().padLeft(2, '0');
          return ListTile(
            title: Text('${localizations.episode}: $formattedEpisodeNumber'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodePlayer(
                    episode: formattedEpisodeNumber,
                    animeId: widget.animeId,
                    name: widget.animename,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
