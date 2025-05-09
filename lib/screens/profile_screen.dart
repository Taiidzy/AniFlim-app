import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myprofile, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProfileMenu(onLogout: onLogout, token: token),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
