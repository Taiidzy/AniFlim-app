import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:video_player/video_player.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:AniFlim/providers/locale_provider.dart';
import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/widgets/player_settings.dart';
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/player/seekbar.dart';
import 'package:AniFlim/api/anime_api.dart';
import 'package:AniFlim/api/user_api.dart';

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
  int _lastSentSecond = -1;
  bool _isFullScreen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    if (_currentQuality != localeProvider.quality) {
      _currentQuality = localeProvider.quality;
      _lastPosition = _controller?.value.position;
      _loadEpisode(_currentOrdinal);
    }

    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.setPlaybackSpeed(localeProvider.playbackSpeed);
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
    final prefs = await SharedPreferences.getInstance();
    if (episodeInfo.isEmpty || !episodeInfo.containsKey('hls_480')) return;

    String videoUrl = episodeInfo[localeProvider.quality].split('?').first;
    print(videoUrl);
    int time = _lastPosition?.inSeconds ?? int.parse(_startTime.split('.')[0]);

    try {
      _controller = VideoPlayerController.network(videoUrl);
      
      // Добавляем обработчик ошибок
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          print('Ошибка видеоплеера: ${_controller!.value.errorDescription}');
          _reinitializePlayer();
        }
      });

      await _controller!.initialize();
      
      if (!mounted) return;
      
      _controller!.addListener(_updatePlaybackPosition);
      final savedVolume = prefs.getDouble('video_volume') ?? 1.0; 
      _controller!.setVolume(savedVolume);
      
      setState(() {});
      
      await _controller!.seekTo(Duration(seconds: time));
      
      if (_lastPosition == null) {
        await _controller!.play();
        _isPlaying.value = true;
      }
      
      _startPlaybackPositionTimer();
    } catch (e) {
      print('Ошибка при инициализации плеера: $e');
      _reinitializePlayer();
    }
  }

  Future<void> _reinitializePlayer() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    
    if (mounted) {
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
      await _initializePlayer();
    }
  }

  void _togglePlayPause() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await _reinitializePlayer();
      return;
    }

    try {
      if (_isPlaying.value) {
        await _controller!.pause();
      } else {
        await _controller!.play();
      }
      _isPlaying.value = !_isPlaying.value;
    } catch (e) {
      print('Ошибка при переключении воспроизведения: $e');
      await _reinitializePlayer();
    }
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
      _updateTimePosition(currentPosition);
    }
  }

  void _updateTimePosition(Duration currentPosition) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final token = Provider.of<UserProvider>(context, listen: false).currentToken;

    if (token == null) return;

    final currentSecond = currentPosition.inSeconds;
    
    if (_controller!.value.isPlaying && currentSecond != _lastSentSecond) {
      final int animeId = int.parse(widget.animeId.toString());
      UserAPI.updateTimeProgress(token, currentSecond, widget.episodeId, animeId);
      _lastSentSecond = currentSecond;
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

  Future<void> _toggleFullScreen() async {
    _isFullScreen = !_isFullScreen;
    await DesktopWindow.toggleFullScreen();
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
    final isDesktop = (defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.windows);
    var name = widget.name;
    if (name.length > 25) name = '${name.substring(0, 25)}...';

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: MouseRegion(
        onEnter: (_) {
          setState(() {
            _controlsVisible = true;
          });
          _resetHideControlsTimer();
        },
        onHover: (_) {
          setState(() {
            _controlsVisible = true;
          });
          _resetHideControlsTimer();
        },
        cursor: isDesktop 
            ? (_controlsVisible ? SystemMouseCursors.basic : SystemMouseCursors.none)
            : SystemMouseCursors.basic,
        child: GestureDetector(
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
              Positioned.fill(
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              // Контролы поверх видео
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
                                      onPressed: _togglePlayPause,
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
                        // Полоска перемотки
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
                        // Регулятор громкости и кнопка "на весь экран" – располагаются слева внизу
                        
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              if (_controlsVisible && isDesktop && _controller != null && _controller!.value.isInitialized)
              Positioned(
                bottom: 100,
                left: 20,
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(HugeIcons.strokeRoundedVolumeLow, color: Colors.white, size: 20),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.2),
                            activeTrackColor: Colors.redAccent,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                              elevation: 0.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 8.0,
                            ),
                          ),
                          child: Slider(
                            min: 0.0,
                            max: 1.0,
                            value: _controller!.value.volume,
                            onChanged: (newVolume) {
                              setState(() {
                                _controller!.setVolume(newVolume);
                              });
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setDouble('video_volume', newVolume);
                              });
                            },
                          ),
                        ),
                      ),
                      Icon(HugeIcons.strokeRoundedVolumeHigh, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              // Кнопка "Пропустить", справа внизу
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
              if (isDesktop && _controller != null)
              Positioned(
                bottom: 100,
                right: 20,
                child: IconButton(
                  icon: HugeIcon(
                    icon: _isFullScreen ? HugeIcons.strokeRoundedSquareArrowShrink02 : HugeIcons.strokeRoundedSquareArrowExpand01,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: _isFullScreen ? 'Выйти из полноэкранного' : 'Полноэкранный',
                  onPressed: _toggleFullScreen,
                ),
              ),
            ],
          ),
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
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
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