import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../api/anime_api.dart';
import '../api/user_api.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class EpisodePlayer extends StatefulWidget {
  final String episode;
  final String animeId;
  final String name;
  final String time;

  EpisodePlayer({required this.episode, required this.animeId, required this.name, this.time = '0'});

  @override
  _EpisodePlayerState createState() => _EpisodePlayerState();
}

class _EpisodePlayerState extends State<EpisodePlayer> {
  late VideoPlayerController _controller;
  late String _currentEpisode;
  late String _startTime;
  late String _animeId;
  bool _controlsVisible = true;
  bool _skipButtonVisible = true;
  bool _isFirstEpisode = false;
  bool _isLastEpisode = false;
  late List<int> _episodeList;
  late Timer _hideControlsTimer;
  late ValueNotifier<bool> _isPlaying;
  late Timer _updateTimeTimer;
  late Timer _playbackPositionTimer;
  late ValueNotifier<Duration> _currentPositionNotifier;

  @override
  void initState() {
    super.initState();
    _animeId = widget.animeId;
    _currentEpisode = widget.episode;
    _startTime = widget.time;
    _episodeList = [];
    _currentPositionNotifier = ValueNotifier(Duration.zero);
    _initializePlayer();
    _setLandscapeMode();
    _startHideControlsTimer();
    _fetchEpisodeList(); // Получаем список эпизодов
  }

  Future<void> _fetchEpisodeList() async {
    final episodeList = await AnimeAPI.fetchEpisodes(_animeId);

    setState(() {
      _episodeList = episodeList;
      _updateEpisodeStatus();
    });
  }

  void _updateEpisodeStatus() {
    final int currentEpisodeNumber = int.parse(_currentEpisode);
    final int lastEpisodeNumber = _episodeList.isNotEmpty ? _episodeList.last : 0;

    setState(() {
      _isFirstEpisode = currentEpisodeNumber == _episodeList.first;
      _isLastEpisode = currentEpisodeNumber == lastEpisodeNumber;
    });
  }

  void _autoContinue() {
    final localProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (localProvider.autocontinue) {
      if (!_isLastEpisode) {
        _nextEpisode();
        _startTime = '0';
      }
    }
  }

  void _initializePlayer() {
    int time = int.parse(_startTime.split('.')[0]);
    _controller = VideoPlayerController.network(
      '$apiBaseUrl/anime/stream/$_animeId/$_currentEpisode',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.seekTo(_controller.value.position + Duration(seconds: time));
        _controller.play(); // Автоматически воспроизводить видео после инициализации
        _isPlaying = ValueNotifier<bool>(_controller.value.isPlaying);
        _isPlaying.value = _controller.value.isPlaying;
        _controller.addListener(_updatePlaybackPosition);
        _startUpdateTimeTimer();
        _startPlaybackPositionTimer(); // Таймер для обновления позиции каждую секунду
        _startTime = '0';
      }).catchError((error) {
        // Обработка ошибок
        print('Error initializing video player: $error');
      });
  }

  void _updatePlaybackPosition() {
    // Убедитесь, что позиция и длительность известны
    if (_controller.value.isInitialized) {
      final currentPosition = _controller.value.position;
      final duration = _controller.value.duration;

      _currentPositionNotifier.value = currentPosition; // Обновляем значение позиции

      // Если воспроизведение завершено, выполните автопереход
      if (currentPosition >= duration) {
        _autoContinue();
      }
    }
  }

  void _startPlaybackPositionTimer() {
    _playbackPositionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updatePlaybackPosition();
    });
  }

  void _startUpdateTimeTimer() {
    UserAPI userAPI = UserAPI();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    _updateTimeTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (user != null && _controller.value.isPlaying) {
        int episode = int.parse(_currentEpisode);
        int positionInSeconds = _controller.value.position.inSeconds;

        await userAPI.updateTime(
          user.username,
          _animeId,
          episode.toString(),
          positionInSeconds.toString(),
        );

        if (timer.tick % 6 == 0) { // Обновление каждые 30 секунд
          await userAPI.updateMoment(user.username, _animeId, _currentEpisode.toString());
        }
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _updateTimeTimer.cancel(); // Останавливаем таймер
      } else {
        _controller.play();
        _startUpdateTimeTimer(); // Запускаем таймер снова
      }
    });
  }

  void _setLandscapeMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // Полный экран, без строки состояния
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _nextEpisode() {
    setState(() {
      int episodeNumber = int.parse(_currentEpisode) + 1;
      _currentEpisode = episodeNumber.toString().padLeft(2, '0');
      _loadEpisode(_currentEpisode);
    });
  }

  void _previousEpisode() {
    setState(() {
      int episodeNumber = int.parse(_currentEpisode);
      if (episodeNumber > 1) {
        episodeNumber--;
        _currentEpisode = episodeNumber.toString().padLeft(2, '0');
        _loadEpisode(_currentEpisode);
      }
    });
  }

  void _loadEpisode(String episodeNumber) {
    setState(() {
      _skipButtonVisible = true; // Показываем кнопку "Пропустить" при изменении эпизода
    });
    _controller.dispose();
    _initializePlayer();
    _updateEpisodeStatus(); // Обновляем статус кнопок
  }

  void _skipForward() {
    setState(() {
      _skipButtonVisible = false;
      _controller.seekTo(_controller.value.position + Duration(seconds: 90));
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    _resetHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer.cancel();
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isPlaying.dispose();
    _hideControlsTimer.cancel();
    _updateTimeTimer.cancel();
    _playbackPositionTimer.cancel(); // Останавливаем таймер для обновления позиции
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Вернуть систему к обычному состоянию
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _currentPositionNotifier.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    var name = widget.name;
    if (name.length > 25) {
      name = name.substring(0, 25) + '...';
    }

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            OrientationBuilder(
              builder: (context, orientation) {
                return Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                      : Center(child: CircularProgressIndicator()),
                );
              },
            ),
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  Container(
                    color: isDarkTheme ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.7),
                    child: AppBar(
                      title: Center(child: Text('$name | ${localizations.episode}: $_currentEpisode', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black))),
                      backgroundColor: isDarkTheme ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      elevation: 0,
                      toolbarHeight: 50, // Уменьшенная высота AppBar
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: isDarkTheme ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                VideoControls(controller: _controller, isDarkTheme: isDarkTheme),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!_isFirstEpisode) // Скрываем кнопку "Предыдущая серия" для первого эпизода
                                      IconButton(
                                        icon: Icon(Icons.skip_previous, color: isDarkTheme ? Colors.white : Colors.black),
                                        onPressed: _previousEpisode,
                                      ),
                                    IconButton(
                                      icon: Icon(
                                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: isDarkTheme ? Colors.white : Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (_controller.value.isPlaying) {
                                            _controller.pause();
                                          } else {
                                            _controller.play();
                                          }
                                        });
                                      },
                                    ),
                                    if (!_isLastEpisode) // Скрываем кнопку "Следующая серия" для последнего эпизода
                                      IconButton(
                                        icon: Icon(Icons.skip_next, color: isDarkTheme ? Colors.white : Colors.black),
                                        onPressed: _nextEpisode,
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                                    style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_skipButtonVisible)
                          Positioned(
                            left: 80,
                            bottom: 10, // Позиция выше прогресс-бара
                            child: ElevatedButton(
                              onPressed: _skipForward,
                              child: Text(localizations.skip, style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkTheme ? Colors.grey[800] : Colors.grey[300], // Цвет фона кнопки
                                minimumSize: Size(125, 40), // Увеличенный размер кнопки
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isDarkTheme;

  VideoControls({required this.controller, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: VideoProgressIndicator(
        controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: Colors.red,
          bufferedColor: Colors.grey,
          backgroundColor: isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
        ),
        padding: EdgeInsets.symmetric(vertical: 20.0), // Увеличенный размер прогресс-бара
      ),
    );
  }
}