import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.purple,  // Цвет активной иконки
      unselectedItemColor: Colors.grey,  // Цвет неактивных иконок
      backgroundColor: Colors.white,     // Фон нижней панели
      items: [
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedHome11, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.home),
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedUserCircle, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.profile),
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedLeftToRightListBullet, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.lists),
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedDownload04, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.downloadedanime),
      ],

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/profile');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/lists');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/downloadedanime');
        }
      },
    );
  }
}
