import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

import 'package:AniFlim/screens/anime_online_screen.dart';
import 'package:AniFlim/models/anime_model.dart';
import 'package:AniFlim/utils/constants.dart';
import 'package:AniFlim/utils/resolution.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final bool isCurrentAnime;

  const AnimeCard({
    super.key, 
    required this.anime,
    this.isCurrentAnime = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        if (!isCurrentAnime) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeOnlineScreen(animeId: anime.id),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkTheme 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isCurrentAnime ? Border.all(
            color: Colors.blue,
            width: 2,
          ) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Верхняя часть с изображением
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: Resolution.getChildAspectRatio(context),
                  child: Image.network(
                    storageApi + anime.img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    filterQuality: FilterQuality.medium,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isDarkTheme 
                                ? Colors.grey[900]!
                                : Colors.grey[300]!,
                              isDarkTheme 
                                ? Colors.grey[800]!
                                : Colors.grey[400]!,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isDarkTheme 
                                ? Colors.grey[900]!
                                : Colors.grey[300]!,
                              isDarkTheme 
                                ? Colors.grey[800]!
                                : Colors.grey[400]!,
                            ],
                          ),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAlert02,
                            color: isDarkTheme ? Colors.white70 : Colors.black54,
                            size: 32.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Нижняя часть с текстом
            Container(
              height: 48, // Фиксированная высота для текстовой части
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.grey[900] : Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                anime.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Индикатор текущего аниме
            if (isCurrentAnime)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Текущее',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
