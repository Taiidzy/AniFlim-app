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
  List<DurationRange> _bufferedRanges = [];

  @override
  void initState() {
    super.initState();
    if (widget.controller.value.isInitialized) {
      _currentSliderValue = widget.controller.value.position.inSeconds.toDouble();
      _bufferedRanges = widget.controller.value.buffered;
    }
    widget.controller.addListener(_updateSlider);
  }
  
  void _updateSlider() {
    if (!_isDragging && widget.controller.value.isInitialized) {
      setState(() {
        _currentSliderValue = widget.controller.value.position.inSeconds.toDouble();
        _bufferedRanges = widget.controller.value.buffered;
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
    return Container(
      height: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          // Подложка
          Container(
            height: 4.0,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          // Буферизированные участки
          ..._bufferedRanges.map((range) {
            final start = range.start.inSeconds / duration;
            final end = range.end.inSeconds / duration;
            return Positioned(
              left: start * MediaQuery.of(context).size.width,
              child: Container(
                width: (end - start) * MediaQuery.of(context).size.width,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            );
          }).toList(),
          // Прогресс воспроизведения
          Positioned(
            left: 0,
            child: Container(
              width: (_currentSliderValue / duration) * MediaQuery.of(context).size.width,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          // Слайдер для управления
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 0.0,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 9.0,
                elevation: 0.0,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 9.0,
              ),
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
          ),
        ],
      ),
    );
  }
}