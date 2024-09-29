import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/last_model.dart';
import '../player/online_player.dart';

class LastCard extends StatelessWidget {
  final Last anime;

  const LastCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpisodePlayer(
              animeId: anime.animeId.toString(),
              episode: anime.episode,
              name: anime.name,
              time: anime.time,
            ),
          ),
        );
      },
      child: SizedBox(
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.network(
                  'https://aniflim.space/static/src/moments/${anime.animeId}/${anime.episode}/${anime.moment}',
                  fit: BoxFit.cover,
                  height: 100, // Высота изображения
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  anime.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ), // Здесь добавлена запятая
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${localizations.episode}: ${anime.episode}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
