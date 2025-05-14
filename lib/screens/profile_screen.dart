import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/widgets/bottom_nav_bar.dart';
import 'package:AniFlim/widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  final String token;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.token,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://pic.rutubelist.ru/video/2024-10-08/01/da/01daee6107408babfd3c400d734f36ec.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkTheme 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          title: Text(
                            localizations.myprofile,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black87,
                              letterSpacing: 1.2,
                            ),
                          ),
                          centerTitle: true,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ProfileMenu(onLogout: onLogout, token: token),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkTheme 
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: isDarkTheme 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: const BottomNavBar(currentIndex: 1),
          ),
        ),
      ),
    );
  }
}
