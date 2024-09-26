import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/all_model.dart';
import '../models/user_model.dart';

class ProfileMenu extends StatelessWidget {
  final User user;
  final All all;
  final Function onLogout;

  ProfileMenu({required this.user, required this.all, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center( // Оборачиваем в Center
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Центрируем содержимое по вертикали
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://aniflim.space/' + user.avatar),
            radius: 50,
          ),
          SizedBox(height: 16),
          Text(user.username, style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          Text('${localizations.all_watched}: ${all.all_watched}', style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          Text('${localizations.all_watching}: ${all.all_watching}', style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onLogout();
            },
            child: Text(localizations.logout),
          ),
        ],
      ),
    );
  }
}
