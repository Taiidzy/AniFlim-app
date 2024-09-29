import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../api/download_api.dart';
import '../widgets/episodes_anime_offline.dart';

class AnimeOfflineScreen extends StatefulWidget {
  final List<String> animeInfo; // Уточнено, что animeInfo - это список

  const AnimeOfflineScreen({super.key, required this.animeInfo}); // Добавлена точка с запятой

  @override
  _AnimeOfflineScreenState createState() => _AnimeOfflineScreenState(); // Используем стрелочную функцию
}

class _AnimeOfflineScreenState extends State<AnimeOfflineScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft02, color: isDarkTheme ? Colors.white : Colors.black, size: 24.0),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/downloadedanime'); // Вернуться на предыдущий экран
          },
        ),
        title: Text(widget.animeInfo[1]), // Заголовок для AppBar
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: Colors.redAccent, size: 22.0),
            onPressed: () async {
              await DownloadAnime.deleteAnime(widget.animeInfo[0]); // Удаляем по animeId
              Navigator.pushReplacementNamed(context, '/downloadedanime'); // Возвращаемся к предыдущему экрану после удаления
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: EpisodesAnime(dir: widget.animeInfo[3], animename: widget.animeInfo[1],),
              )
          )
        ],
      ),
    );
  }
}