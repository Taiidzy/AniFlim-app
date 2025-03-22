import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:hugeicons/hugeicons.dart';
import '../api/anime_api.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../widgets/player_settings.dart';

class EpisodePlayer extends StatefulWidget {
  final String episodeId;
  final String episode;
  final String animeId;
  final String name;
  final String time;
  final int ordinal;

  const EpisodePlayer({
    super.key,
    required this.episodeId,
    required this.ordinal,
    required this.episode,
    required this.animeId,
    required this.name,
    required this.time,
  });

  @override
  _EpisodePlayerState createState() => _EpisodePlayerState();
}

class _EpisodePlayerState extends State<EpisodePlayer> {
  bool _skipUsed = false;
  VideoPlayerController? _controller;
  late String _startTime;
  bool _controlsVisible = true;
  bool _skipButtonVisible = false;
  late Timer _hideControlsTimer;
  late ValueNotifier<bool> _isPlaying;
  Timer? _playbackPositionTimer; // Убрали late, добавили ?
  late ValueNotifier<Duration> _currentPositionNotifier;
  List<dynamic> allEpisodeInfo = [];
  Map<String, dynamic> episodeInfo = {};
  bool _isFirstEpisode = false;
  bool _isLastEpisode = false;
  late int _currentOrdinal;
  late int _openingStart;
  late int _openingStop;
  late int _endingStart;
  late int _endingStop;
  String? _currentQuality; // Добавляем для отслеживания текущего качества
  Duration? _lastPosition; // Сохраняем позицию при смене качества

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    if (_currentQuality != localeProvider.quality) {
      _currentQuality = localeProvider.quality;
      _lastPosition = _controller?.value.position;
      _loadEpisode(_currentOrdinal);
    }
  }

  @override
  void initState() {
    super.initState();
    _startTime = widget.time;
    _currentPositionNotifier = ValueNotifier(Duration.zero);
    _isPlaying = ValueNotifier(false);
    _setLandscapeMode();
    _startHideControlsTimer();
    _currentOrdinal = widget.ordinal;
    
    _fetchEpisodeList().then((_) {
      if (mounted) {
        _updateEpisodeStatus();
        _loadEpisode(_currentOrdinal);
      }
    });
  }

  Future<void> _fetchEpisodeList() async {
    final episodeList = await AnimeAPI.fetchEpisode(widget.animeId);
    if (mounted) {
      setState(() => allEpisodeInfo = episodeList);
    }
  }

  void _updateEpisodeStatus() {
    final isFirst = _currentOrdinal == 1;
    final isLast = _currentOrdinal == allEpisodeInfo.length;

    if (isFirst != _isFirstEpisode || isLast != _isLastEpisode) {
      setState(() {
        _isFirstEpisode = isFirst;
        _isLastEpisode = isLast;
      });
    }
  }

  void _loadEpisode(int episodeNumber) {
    _skipUsed = false; // Сбрасываем флаг при каждой загрузке
    if (episodeNumber < 1 || episodeNumber > allEpisodeInfo.length) return;

    // Сохраняем текущее состояние воспроизведения
    final wasPlaying = _controller?.value.isPlaying ?? false;
    final currentPosition = _controller?.value.position ?? _lastPosition;

    // Освобождаем старый контроллер
    if (_controller != null) {
      _controller!.removeListener(_updatePlaybackPosition);
      _controller!.dispose();
      _controller = null;
    }

    setState(() {
      _currentOrdinal = episodeNumber;
      episodeInfo = allEpisodeInfo[episodeNumber - 1];
      _skipButtonVisible = false;
      
      final opening = episodeInfo['opening'] is Map<String, dynamic> 
          ? episodeInfo['opening'] 
          : <String, dynamic>{};
      _openingStart = (opening['start'] as int?) ?? 0;
      _openingStop = (opening['stop'] as int?) ?? 0;
      
      final ending = episodeInfo['ending'] is Map<String, dynamic> 
          ? episodeInfo['ending'] 
          : <String, dynamic>{};
      _endingStart = (ending['start'] as int?) ?? 0;
      _endingStop = (ending['stop'] as int?) ?? 0;
    });
    
    _updateEpisodeStatus();
    _initializePlayer().then((_) {
      if (!mounted) return;
      
      // Восстанавливаем позицию и состояние воспроизведения
      if (currentPosition != null) {
        _controller!.seekTo(currentPosition);
      }
      if (wasPlaying) {
        _controller!.play();
        _isPlaying.value = true;
      }
    });
  }

  void _autoContinue() {
    final localProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (localProvider.autocontinue && !_isLastEpisode) {
      _loadEpisode(_currentOrdinal + 1);
    }
  }

  Future<void> _initializePlayer() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (episodeInfo.isEmpty || !episodeInfo.containsKey('hls_480')) return;

    String videoUrl = episodeInfo[localeProvider.quality];
    int time = _lastPosition?.inSeconds ?? int.parse(_startTime.split('.')[0]);

    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        if (!mounted) return;
        _controller!.addListener(_updatePlaybackPosition); // Добавляем слушатель
        setState(() {});
        _controller!.seekTo(Duration(seconds: time)).then((_) {
          if (_lastPosition == null) {
            _controller!.play();
            _isPlaying.value = true;
          }
          _startPlaybackPositionTimer();
        });
      });
  }

  void _updatePlaybackPosition() {
    if (_controller != null && _controller!.value.isInitialized) {
      final currentPosition = _controller!.value.position;
      final duration = _controller!.value.duration;
      
      _currentPositionNotifier.value = currentPosition;

      if (!_skipUsed && currentPosition.inSeconds >= _openingStart && currentPosition.inSeconds <= _openingStop) {
        setState(() => _skipButtonVisible = true);
      }
      
      if (currentPosition >= duration) {
        _autoContinue();
      }
      _autoSkipOpening(currentPosition);
      _marathonMode(currentPosition);
    }
  }

  void _marathonMode(Duration currentPosition) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final localProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentSeconds = currentPosition.inSeconds;
    final duration = _controller!.value.duration;

    // Пропуск опенинга
    if (localProvider.marathonMode && 
        currentSeconds >= _openingStart &&
        currentSeconds <= _openingStop &&
        !_skipUsed) {
      _skipUsed = true;
      _controller!.seekTo(Duration(seconds: _openingStop));
      if (mounted) setState(() => _skipButtonVisible = false);
    }

    // Пропуск эндинга
    if (localProvider.marathonMode && 
        currentSeconds >= _endingStart &&
        currentSeconds <= _endingStop - 5) {
      _controller!.seekTo(Duration(seconds: _endingStop));
    }

    // Автопродолжение
    if (localProvider.marathonMode && 
      currentPosition + const Duration(seconds: 1) >= duration) {
      _loadEpisode(_currentOrdinal + 1);
    }
  }

  void _autoSkipOpening(Duration currentPosition) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final localProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentSeconds = currentPosition.inSeconds;

    if (localProvider.autoSkipOpening && 
        currentSeconds >= _openingStart &&
        currentSeconds <= _openingStop &&
        !_skipUsed) {
      _skipUsed = true;
      _controller!.seekTo(Duration(seconds: _openingStop));
      if (mounted) setState(() => _skipButtonVisible = false);
    }
  }

  void _startPlaybackPositionTimer() {
    _playbackPositionTimer?.cancel();
    _playbackPositionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updatePlaybackPosition();
    });
  }

  void _setLandscapeMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  void _skipOpening() {
    if (_controller == null) return;
    setState(() {
      _skipUsed = true;
      _skipButtonVisible = false;
      // Можно сразу перейти к концу opening
      _controller!.seekTo(Duration(seconds: _openingStop));
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    _resetHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer.cancel();
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isPlaying.dispose();
    _hideControlsTimer.cancel();
    _playbackPositionTimer?.cancel();
    _currentPositionNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    var name = widget.name;
    if (name.length > 25) name = '${name.substring(0, 25)}...';

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          if (_controller == null) return;
          final screenWidth = MediaQuery.of(context).size.width;
          final offset = details.globalPosition.dx < screenWidth / 2 
              ? const Duration(seconds: -5)
              : const Duration(seconds: 5);
          _controller!.seekTo(_controller!.value.position + offset);
        },
        child: Stack(
          children: [
            Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            // Оборачиваем слой с контролами в IgnorePointer,
            // чтобы при скрытии (opacity == 0) нажатия не обрабатывались
            IgnorePointer(
              ignoring: !_controlsVisible,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Center(
                          child: Text(
                            '$name | ${localizations.episode}: $_currentOrdinal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedSettings02,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: isDarkTheme ? Colors.black : Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                                ),
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.65,
                                    child: SettingsMenu(episodeInfo: episodeInfo),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isFirstEpisode)
                                _buildControlButton(
                                  icon: HugeIcons.strokeRoundedPrevious,
                                  onPressed: () => _loadEpisode(_currentOrdinal - 1),
                                ),
                              const SizedBox(width: 30),
                              ValueListenableBuilder<bool>(
                                valueListenable: _isPlaying,
                                builder: (context, isPlaying, _) {
                                  return _buildControlButton(
                                    icon: isPlaying 
                                        ? HugeIcons.strokeRoundedPause 
                                        : HugeIcons.strokeRoundedPlay,
                                    iconSize: 32,
                                    onPressed: () {
                                      if (_controller == null) return;
                                      if (isPlaying) {
                                        _controller!.pause();
                                      } else {
                                        _controller!.play();
                                      }
                                      _isPlaying.value = !isPlaying;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 30),
                              if (!_isLastEpisode)
                                _buildControlButton(
                                  icon: HugeIcons.strokeRoundedNext,
                                  onPressed: () => _loadEpisode(_currentOrdinal + 1),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Новая полоска для перемотки (SeekBar)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _controller != null && _controller!.value.isInitialized
                            ? SeekBar(
                                controller: _controller!,
                                isDarkTheme: isDarkTheme,
                              )
                            : const SizedBox(),
                      ),
                      // Отображение текущего времени и длительности
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder<Duration>(
                              valueListenable: _currentPositionNotifier,
                              builder: (context, value, _) => Text(
                                _formatDuration(value),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            ValueListenableBuilder<Duration>(
                              valueListenable: _currentPositionNotifier,
                              builder: (context, value, _) => Text(
                                _formatDuration(_controller?.value.duration ?? Duration.zero),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Плавающая кнопка для пропуска опенинга
            if (_skipButtonVisible && _controller != null)
              Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  onPressed: _skipOpening,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedForward01,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(localizations.skip, style: const TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, double iconSize = 28, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(100), // Круговой радиус
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(10), // Отступы для кликабельной области
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isDarkTheme;

  const VideoControls({
    super.key,
    required this.controller,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: Colors.redAccent,
        bufferedColor: Colors.white70,
        backgroundColor: isDarkTheme ? Colors.white24 : Colors.black26,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}

class SeekBar extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isDarkTheme;
  const SeekBar({super.key, required this.controller, required this.isDarkTheme});

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _currentSliderValue = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Инициализируем значение с текущей позиции видео, если оно уже доступно
    if (widget.controller.value.isInitialized) {
      _currentSliderValue = widget.controller.value.position.inSeconds.toDouble();
    }
    widget.controller.addListener(_updateSlider);
  }
  
  void _updateSlider() {
    if (!_isDragging && widget.controller.value.isInitialized) {
      setState(() {
        _currentSliderValue = widget.controller.value.position.inSeconds.toDouble();
      });
    }
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_updateSlider);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration.inSeconds.toDouble();
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.redAccent,
        inactiveTrackColor: widget.isDarkTheme ? Colors.white24 : Colors.black26,
        thumbColor: Colors.white,
        overlayColor: Colors.white.withOpacity(0.2),
        trackHeight: 4.0,
      ),
      child: Slider(
        min: 0,
        max: duration > 0 ? duration : 1,
        value: _currentSliderValue.clamp(0, duration),
        onChanged: (value) {
          setState(() {
            _currentSliderValue = value;
          });
        },
        onChangeStart: (value) {
          _isDragging = true;
        },
        onChangeEnd: (value) {
          _isDragging = false;
          widget.controller.seekTo(Duration(seconds: value.toInt()));
        },
      ),
    );
  }
}
