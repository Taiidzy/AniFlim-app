import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/download_api.dart';
import '../api/anime_api.dart';
import '../l10n/app_localizations.dart';
import '../models/anime_model.dart';
import '../widgets/detail_anime.dart';
import '../widgets/episodes_anime_online.dart';

class AnimeOnlineScreen extends StatefulWidget {
  final String animeId;

  const AnimeOnlineScreen({Key? key, required this.animeId}) : super(key: key);

  @override
  _AnimeOnlineScreenState createState() => _AnimeOnlineScreenState();
}

class _AnimeOnlineScreenState extends State<AnimeOnlineScreen> {
  Anime? anime; // Переменная для хранения данных об аниме
  bool showDetail = true;
  bool isDownloading = false;
  bool isDownloaded = false;
  bool isLoading = true; // Добавил состояние загрузки
  String? errorMessage; // Сообщение об ошибке

  @override
  void initState() {
    super.initState();
    _loadAnimeDetail();
    _checkIfDownloaded(); // Проверка на наличие аниме в списке
  }

  Future<void> _loadAnimeDetail() async {
    try {
      // Вызов функции для получения данных об аниме
      final fetchedAnime = await AnimeAPI.fetchAnimeDetail(widget.animeId);
      setState(() {
        anime = fetchedAnime;
        isLoading = false; // Завершаем загрузку
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false; // Завершаем загрузку с ошибкой
      });
    }
  }

  Future<void> _checkIfDownloaded() async {
    bool result = await isAnimeInList(widget.animeId);
    setState(() {
      isDownloaded = result;
    });
  }

  Future<bool> isAnimeInList(String animeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Получаем список по ключу 'anime_$animeId'
    List<String>? animeData = prefs.getStringList('anime_$animeId');

    // Если список не пустой и содержит это animeId
    if (animeData != null && animeData.isNotEmpty && animeData.contains(animeId)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Отображаем индикатор загрузки или ошибку, если есть
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Загрузка...'),
        ),
        body: const Center(child: CircularProgressIndicator()), // Идет загрузка
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ошибка'),
        ),
        body: Center(child: Text('Ошибка: $errorMessage')), // Показываем ошибку
      );
    }

    // Если данные загружены успешно, отображаем контент
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: isDarkTheme ? Colors.white : Colors.black,
            size: 24.0,
          ),
          onPressed: () {
            Navigator.pop(context); // Вернуться на предыдущий экран
          },
        ),
        title: Text(anime?.name ?? 'Аниме'), // Используем данные об аниме
        actions: [
          isDownloaded
              ? const HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: Color(0xFF7ED321),
                  size: 24.0,
                )
              : isDownloading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDownload04,
                        color: isDarkTheme ? Colors.white : Colors.black,
                        size: 22.0,
                      ),
                      onPressed: () async {
                        setState(() {
                          isDownloading = true;
                        });
                        await DownloadAnime.downloadAnime(
                            anime!.id, anime!.name, context);
                        setState(() {
                          isDownloading = false;
                          isDownloaded = true;
                        });
                      },
                    ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showDetail = true;
                    });
                  },
                  child: Text(localizations.detail),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showDetail = false;
                    });
                  },
                  child: Text(localizations.watch),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: showDetail
                  ? DetailAnime(anime: anime!) // Передаем данные об аниме
                  : EpisodesAnime(
                      animeId: anime!.id, animename: anime!.name), // Передаем id и имя
            ),
          ),
        ],
      ),
    );
  }
}
