


import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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