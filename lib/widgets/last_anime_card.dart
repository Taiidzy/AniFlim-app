import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/last_model.dart';
import '../screens/anime_player.dart';

class LastCard extends StatelessWidget {
  final Last anime;

  LastCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
        height: 180,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.network(
                  'https://aniflim.space/static/src/moments/${anime.animeId}/${anime.episode}/${anime.moment}',
                  fit: BoxFit.cover,
                  height: 125, // Высота изображения
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  anime.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ), // Здесь добавлена запятая
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${localizations.episode}: ${anime.episode}',
                  style: TextStyle(
                    fontSize: 16,
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
