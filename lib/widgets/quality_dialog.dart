import 'package:flutter/material.dart';
import 'dart:ui';

class QualityDialog extends StatelessWidget {
  final String animeName;

  const QualityDialog({
    super.key,
    required this.animeName,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDarkTheme 
        ? Colors.black.withOpacity(0.9)
        : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Выберите качество',
        style: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QualityButton(
            quality: '1080p',
            onPressed: () {
              print('Выбрано качество 1080p для $animeName');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _QualityButton(
            quality: '720p',
            onPressed: () {
              print('Выбрано качество 720p для $animeName');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _QualityButton(
            quality: '480p',
            onPressed: () {
              print('Выбрано качество 480p для $animeName');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _QualityButton extends StatelessWidget {
  final String quality;
  final VoidCallback onPressed;

  const _QualityButton({
    required this.quality,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkTheme 
              ? Colors.black.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkTheme 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            ),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: isDarkTheme ? Colors.white : Colors.black87,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              quality,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 