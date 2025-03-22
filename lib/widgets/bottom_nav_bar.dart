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
      backgroundColor: isDarkTheme ? Color.fromRGBO(20, 20, 20, 1) : Colors.white,     // Фон нижней панели
      items: [
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedHome11, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.home),
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedUserCircle, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.profile),
        BottomNavigationBarItem(icon: HugeIcon(icon: HugeIcons.strokeRoundedLeftToRightListBullet, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0), label: localizations.lists),
      ],

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/development');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/development');
        }
      },
    );
  }
}
