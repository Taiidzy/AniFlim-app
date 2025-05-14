import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/models/episodes_model.dart';
import 'package:AniFlim/models/progress_model.dart';
import 'package:AniFlim/player/online_player.dart';
import 'package:AniFlim/api/episodes_api.dart';
import 'package:AniFlim/api/user_api.dart';
import 'package:AniFlim/utils/constants.dart';

class EpisodesAnime extends StatefulWidget {
  final String animeId;
  final String animename;
  final String img;

  const EpisodesAnime({
    super.key,
    required this.animeId,
    required this.animename,
    required this.img,
  });

  @override
  _EpisodesAnimeState createState() => _EpisodesAnimeState();
}

class _EpisodesAnimeState extends State<EpisodesAnime> {
  List<Episode> episodeList = [];
  late TextEditingController _searchController;
  String? token;
  ProgressModel? progress;
  Map<String, bool> loadingStates = {};
  Map<String, double> episodeSizes = {};

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    _searchController = TextEditingController();
    fetchEpisodes();

    provider.getToken().then((token) async {
      setState(() => this.token = token);
      await _getProgress();
    });
  }

  Future<void> _getProgress() async {
    try {
      final _progress = await UserAPI.fetchProgress(token!, int.parse(widget.animeId));

      setState(() {
        progress = _progress;
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(storageApi + widget.img),
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  if (episodeList.length > 24)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkTheme 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkTheme 
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                color: isDarkTheme ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: localizations.searchEpisode,
                                labelStyle: TextStyle(
                                  color: isDarkTheme ? Colors.white70 : Colors.black54,
                                ),
                                hintText: localizations.enterEpisodeNumber,
                                hintStyle: TextStyle(
                                  color: isDarkTheme ? Colors.white60 : Colors.black38,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkTheme 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkTheme 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDarkTheme 
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredEpisodes.length,
                      itemBuilder: (context, index) {
                        final episode = filteredEpisodes[index];
                        final formattedEpisodeNumber = episode.episode.toString().padLeft(2, '0');
                        final isSelected = progress != null && episode.id == progress!.episode;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkTheme 
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                      ? Colors.purple.withOpacity(0.5)
                                      : isDarkTheme 
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    '${AppLocalizations.of(context).episode}: ${episode.ordinal}',
                                    style: TextStyle(
                                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
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
                              ),
                            ),
                          ),
                        );
                      },
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
