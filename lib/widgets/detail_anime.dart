import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/anime_api.dart';
import '../api/lists_api.dart';
import '../l10n/app_localizations.dart';
import '../models/anime_model.dart';
import '../providers/user_provider.dart';
import '../player/online_player.dart';

class DetailAnime extends StatefulWidget {
  final Anime anime;

  const DetailAnime({super.key, required this.anime});

  @override
  _DetailAnimeState createState() => _DetailAnimeState();
}

class _DetailAnimeState extends State<DetailAnime> {
  bool isWatching = false;
  bool isWatched = false;

  @override
  void initState() {
    super.initState();
    _checkAnimeStatus();
  }

  void _checkAnimeStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userLists = userProvider.user?.userLists;

    print(userLists);

    if (userLists != null) {
      setState(() {
        isWatching = userLists.watching.any((item) => item.anime_id == int.parse(widget.anime.id));
        isWatched = userLists.watched.any((item) => item.anime_id == int.parse(widget.anime.id));
      });

      try {
        final progress = await AnimeAPI.fetchProgress(widget.anime.id, userProvider.user!.username);
        for (var p in progress) {
          print('Episode: ${p.episode}, Time: ${p.time}');
          showEpisodeDialog(context, p.episode.toString(), p.time.toString());
                }
      } catch (e) {
        print('Failed to load progress: $e');
      }
    }
  }

  Future<void> _updateList(String action) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.user?.username;

    if (username != null) {
      await ListsAPI.updateAnimeList(username, widget.anime.id, action);

      // Получаем обновленные списки
      final updatedLists = await ListsAPI.fetchlists(username);
      if (updatedLists != null) {
        // Обновляем UserProvider новыми списками
        userProvider.setUser(userProvider.user, userLists: updatedLists);

        // Обновляем статус аниме
        _checkAnimeStatus();
      }
        }
  }



  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Если пользователь не авторизован, возвращаем только информацию об аниме без кнопок
    if (userProvider.user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network('https://aniflim.space/${widget.anime.img}'),
          const SizedBox(height: 16.0),
          Text(
            widget.anime.name,
            style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
              '${localizations.voiceover}: ${widget.anime.voiceover}',
              style: const TextStyle(fontSize: 16.0)
          ),
          const SizedBox(height: 16.0),
          Text(
              '${localizations.outin}: ${widget.anime.release_date}',
              style: const TextStyle(fontSize: 16.0)
          ),
          const SizedBox(height: 16.0),
          Text(
              '${localizations.status}: ${widget.anime.status}',
              style: const TextStyle(fontSize: 16.0)
          ),
          const SizedBox(height: 16.0),
          Text(
              '${localizations.studio}: ${widget.anime.studio}',
              style: const TextStyle(fontSize: 16.0)
          ),
          const SizedBox(height: 16.0),
          Text(
              '${localizations.genres}: ${widget.anime.genres}',
              style: const TextStyle(fontSize: 16.0)
          ),
          const SizedBox(height: 16.0),
          Text(
              '${localizations.description}: ${widget.anime.description}',
              style: const TextStyle(fontSize: 16.0)
          ),
        ],
      );
    }

    // Если пользователь авторизован, рендерим информацию об аниме и кнопки
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network('https://aniflim.space/${widget.anime.img}'),
        const SizedBox(height: 16.0),
        Text(
          widget.anime.name,
          style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 16.0),
        if (!isWatching && !isWatched)
          ElevatedButton(
            onPressed: () => _updateList('add'),
            child: Text(localizations.addtolist),
          ),
        if (isWatching)
          ElevatedButton(
            onPressed: () => _updateList('watched'),
            child: Text(localizations.watched),
          ),
        if (isWatching || isWatched)
          ElevatedButton(
            onPressed: () => _updateList('remove'),
            child: Text(localizations.removefromlist),
          ),
        if (!isWatching && isWatched)
          ElevatedButton(
            onPressed: () => _updateList('watching'),
            child: Text(localizations.watching),
          ),
        const SizedBox(height: 16.0),
        Text(
            '${localizations.outin}: ${widget.anime.release_date}',
            style: const TextStyle(fontSize: 16.0)
        ),
        const SizedBox(height: 16.0),
        Text(
            '${localizations.status}: ${widget.anime.status}',
            style: const TextStyle(fontSize: 16.0)
        ),
        const SizedBox(height: 16.0),
        Text(
            '${localizations.studio}: ${widget.anime.studio}',
            style: const TextStyle(fontSize: 16.0)
        ),
        const SizedBox(height: 16.0),
        Text(
            '${localizations.genres}: ${widget.anime.genres}',
            style: const TextStyle(fontSize: 16.0)
        ),
        const SizedBox(height: 16.0),
        Text(
            '${localizations.description}: ${widget.anime.description}',
            style: const TextStyle(fontSize: 16.0)
        )
      ],
    );
  }

  void showEpisodeDialog(BuildContext context, String episode, String time) {
    final localizations = AppLocalizations.of(context);
    final formattedEpisodeNumber = episode.padLeft(2, '0'); // 'episode' уже строка
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.continueWatching),
          content: Text('${localizations.episode}: $episode'),
          actions: [
            TextButton(
              child: Text(localizations.continueWatch),
              onPressed: () {
                // Закрываем диалог
                Navigator.of(context).pop();
                // Переходим на новый экран после закрытия диалога
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpisodePlayer(
                      episode: formattedEpisodeNumber,
                      animeId: widget.anime.id,
                      name: widget.anime.name,
                      time: time,
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: Text(localizations.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
