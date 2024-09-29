import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../l10n/app_localizations.dart';
import '../player/offline_player.dart';

class EpisodesAnime extends StatefulWidget {
  final String dir;
  final String animename;

  const EpisodesAnime({super.key, required this.dir, required this.animename});

  @override
  _EpisodesAnimeState createState() => _EpisodesAnimeState();
}

class _EpisodesAnimeState extends State<EpisodesAnime> {

  List _episodeList = [];

  static Future<List<int>> fetchEpisodes(String dirPath) async {
    try {
      final dir = Directory(dirPath); // Создаем объект Directory по указанному пути
      if (await dir.exists()) {
        final List<int> episodeNumbers = []; // Список для хранения номеров эпизодов

        // Перебираем файлы в директории
        final files = dir.listSync();
        for (var file in files) {
          if (file is File) {
            final filename = path.basename(file.path); // Получаем имя файла
            final episodeMatch = RegExp(r'E(\d+)\.mp4'); // Регулярное выражение для определения номера эпизода

            // Проверяем, совпадает ли имя файла с форматом
            final match = episodeMatch.firstMatch(filename);
            if (match != null) {
              final episodeNumber = int.parse(match.group(1)!); // Извлекаем номер эпизода
              episodeNumbers.add(episodeNumber); // Добавляем номер в список
            }
          }
        }

        // Сортируем номера эпизодов
        episodeNumbers.sort();
        return episodeNumbers; // Возвращаем отсортированный список
      } else {
        throw Exception('Directory does not exist: $dirPath');
      }
    } catch (e) {
      throw Exception('Failed to load episodes: $e');
    }
  }

  Future<void> _fetchEpisodeList() async {
    final dirPath = widget.dir; // Замените _dir на путь к вашей локальной директории
    final episodeList = await fetchEpisodes(dirPath); // Получаем список эпизодов

    setState(() {
      _episodeList = episodeList; // Обновляем состояние
    });
    print('episodeList: $episodeList');
  }

  @override
  void initState() {
    super.initState();
    _fetchEpisodeList(); // Получаем список эпизодов
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: _episodeList.length,
        itemBuilder: (context, index) {
          final episode = _episodeList[index];
          final formattedEpisodeNumber = episode.toString().padLeft(2, '0');
          return ListTile(
            title: Text('${localizations.episode}: $formattedEpisodeNumber'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EpisodePlayer(
                    episode: formattedEpisodeNumber,
                    dir: widget.dir,
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
