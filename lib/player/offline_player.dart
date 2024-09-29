import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:hugeicons/hugeicons.dart'; // Убедитесь, что библиотека установлена
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class EpisodePlayer extends StatefulWidget {
  final String episode;
  final String dir;
  final String name;
  final String time;

  const EpisodePlayer({super.key, required this.episode, required this.dir, required this.name, this.time = '0'});

  @override
  _EpisodePlayerState createState() => _EpisodePlayerState();
}

class _EpisodePlayerState extends State<EpisodePlayer> {
  late VideoPlayerController _controller;
  late String _currentEpisode;
  late String _startTime;
  late String _dir;
  bool _controlsVisible = true;
  bool _skipButtonVisible = true;
  bool _isFirstEpisode = false;
  bool _isLastEpisode = false;
  late List<int> _episodeList;
  Timer? _hideControlsTimer;
  late ValueNotifier<bool> _isPlaying;
  Timer? _playbackPositionTimer;
  late ValueNotifier<Duration> _currentPositionNotifier;

  @override
  void initState() {
    super.initState();
    _dir = widget.dir;
    _currentEpisode = widget.episode;
    _startTime = widget.time;
    _episodeList = [];
    _currentPositionNotifier = ValueNotifier(Duration.zero);
    _isPlaying = ValueNotifier<bool>(false);
    _initializePlayer();
    _setLandscapeMode();
    _startHideControlsTimer();
    _fetchEpisodeList(); // Получаем список эпизодов
  }

  static Future<List<int>> fetchEpisodes(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        final List<int> episodeNumbers = [];

        final files = dir.listSync();
        for (var file in files) {
          if (file is File) {
            final filename = path.basename(file.path);
            final episodeMatch = RegExp(r'E(\d+)\.mp4');

            final match = episodeMatch.firstMatch(filename);
            if (match != null) {
              final episodeNumber = int.parse(match.group(1)!);
              episodeNumbers.add(episodeNumber);
            }
          }
        }

        episodeNumbers.sort();
        return episodeNumbers;
      } else {
        throw Exception('Directory does not exist: $dirPath');
      }
    } catch (e) {
      throw Exception('Failed to load episodes: $e');
    }
  }

  Future<void> _fetchEpisodeList() async {
    final dirPath = _dir;
    final episodeList = await fetchEpisodes(dirPath);

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
      '$_dir/E$_currentEpisode.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.seekTo(_controller.value.position + Duration(seconds: time));
        _controller.play();
        _isPlaying.value = _controller.value.isPlaying;
        _controller.addListener(_updatePlaybackPosition);
        _startPlaybackPositionTimer();
        _startTime = '0';
      }).catchError((error) {
        print('Error initializing video player: $error');
      });
  }

  void _updatePlaybackPosition() {
    if (_controller.value.isInitialized) {
      final currentPosition = _controller.value.position;
      final duration = _controller.value.duration;

      _currentPositionNotifier.value = currentPosition;

      if (currentPosition >= duration) {
        _autoContinue();
      }
    }
  }

  void _startPlaybackPositionTimer() {
    _playbackPositionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updatePlaybackPosition();
    });
  }

  void _setLandscapeMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      _skipButtonVisible = true;
    });
    _controller.dispose();
    _initializePlayer();
    _updateEpisodeStatus();
  }

  void _skipForward() {
    setState(() {
      _skipButtonVisible = false;
      _controller.seekTo(_controller.value.position + const Duration(seconds: 90));
    });
  }

  void _toggleControls() {
    setState(() {
      // Показываем контроллеры, если видео на паузе
      if (!_controller.value.isPlaying) {
        _hideControlsTimer?.cancel();
        _controlsVisible = true;
      } else {
        // Скрываем контроллеры, если видео воспроизводится
        _controlsVisible = !_controlsVisible;
        _startHideControlsTimer();
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    _isPlaying.dispose();
    _hideControlsTimer?.cancel();
    _playbackPositionTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    var name = widget.name;
    if (name.length > 25) {
      name = '${name.substring(0, 25)}...';
    }

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            // Левая часть экрана: перемотка на 5 секунд назад
            _controller.seekTo(
              _controller.value.position - const Duration(seconds: 5),
            );
          } else {
            // Правая часть экрана: перемотка на 5 секунд вперед
            _controller.seekTo(
              _controller.value.position + const Duration(seconds: 5),
            );
          }
        },
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
            // Полупрозрачные контролы
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: isDarkTheme
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4),
                child: Column(
                  children: [
                    Container(
                      color: isDarkTheme ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.7),
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
                          // Кнопки управления воспроизведением
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_isFirstEpisode)
                                  IconButton(
                                    iconSize: 48,
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedPrevious,
                                      color: isDarkTheme ? Colors.white : Colors.black,
                                    ),
                                    onPressed: _previousEpisode,
                                  ),
                                const SizedBox(width: 20),
                                IconButton(
                                  iconSize: 64,
                                  icon: HugeIcon(
                                    icon: _controller.value.isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay,
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_controller.value.isPlaying) {
                                        _controller.pause();
                                      } else {
                                        _controller.play();
                                      }
                                      _isPlaying.value = _controller.value.isPlaying;
                                    });
                                  },
                                ),
                                const SizedBox(width: 20),
                                if (!_isLastEpisode)
                                  IconButton(
                                    iconSize: 48,
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedNext, // Замените на соответствующий HugeIcon
                                      color: isDarkTheme ? Colors.white : Colors.black,
                                    ),
                                    onPressed: _nextEpisode,
                                  ),
                              ],
                            ),
                          ),
                          // Прогресс-бар
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VideoControls(
                              controller: _controller,
                              isDarkTheme: isDarkTheme,
                            ),
                          ),
                          // Текст с текущей позицией и общей длительностью
                          Positioned(
                            bottom: 60,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder<Duration>(
                                  valueListenable: _currentPositionNotifier,
                                  builder: (context, value, child) {
                                    return Text(
                                      _formatDuration(value),
                                      style: TextStyle(
                                        color: isDarkTheme ? Colors.white : Colors.black,
                                      ),
                                    );
                                  },
                                ),
                                ValueListenableBuilder<Duration>(
                                  valueListenable: _currentPositionNotifier,
                                  builder: (context, value, child) {
                                    final duration = _controller.value.duration;
                                    return Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: isDarkTheme ? Colors.white : Colors.black,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Кнопка "Пропустить вперед"
                          if (_skipButtonVisible)
                            Positioned(
                              right: 20,
                              bottom: 100,
                              child: ElevatedButton.icon(
                                onPressed: _skipForward,
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedForward01, // Замените на соответствующий HugeIcon
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                                label: Text(
                                  localizations.skip,
                                  style: TextStyle(
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkTheme
                                      ? Colors.grey[800]
                                      : Colors.grey[300], // Цвет фона кнопки
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  const VideoControls({super.key, required this.controller, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: VideoProgressIndicator(
        controller,
        allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: Colors.redAccent,
          bufferedColor: Colors.grey,
          backgroundColor: isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }
}
