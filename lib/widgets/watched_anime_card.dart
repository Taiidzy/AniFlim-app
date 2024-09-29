import 'package:flutter/material.dart';
import '../api/anime_api.dart';
import '../models/anime_model.dart';
import '../models/lists_model.dart';

class WatchedCard extends StatelessWidget {
  final AnimeItem watched;

  const WatchedCard({super.key, required this.watched});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
          List<Anime> animeList = await AnimeAPI.fetchAnimeList();
          Anime? selectedAnime = animeList.firstWhere(
              (anime) => anime.id == watched.anime_id.toString()
          );
          Navigator.pushNamed(context, '/animeDetail', arguments: selectedAnime,);
        },
      child: SizedBox(
        height: 300,
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
                  'https://aniflim.space/${watched.img_path}',
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  watched.name,
                  style: const TextStyle(
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
