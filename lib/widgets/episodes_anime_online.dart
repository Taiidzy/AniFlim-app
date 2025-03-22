import 'package:flutter/material.dart';
import '../api/episodes_api.dart';
import '../l10n/app_localizations.dart';
import '../models/episodes_model.dart';
import '../player/online_player.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    fetchEpisodes();
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
                final formattedEpisodeNumber = 
                    episode.episode.toString().padLeft(2, '0');
                return ListTile(
                  title: Text('${localizations.episode}: ${episode.ordinal}'),
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
                          time: '0',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
