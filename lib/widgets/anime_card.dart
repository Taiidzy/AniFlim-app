import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/screens/anime_online_screen.dart';
import 'package:AniFlim/models/anime_model.dart';

import 'package:AniFlim/utils/constants.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;

  const AnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeOnlineScreen(animeId: anime.id),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: Image.network(
                storageApi + anime.img,
                fit: BoxFit.cover,
                height: 260,
                width: double.infinity,
                filterQuality: FilterQuality.none,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert02,
                    color: isDarkTheme ? Colors.white : Colors.black,
                    size: 22.0,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity, // Занимает всю ширину
                child: Text(
                  anime.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, // Теперь будет работать
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
