import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/user_model.dart';

class ProfileMenu extends StatefulWidget {
  final Function onLogout;


  const ProfileMenu({
    super.key,
    required this.onLogout,
  });

  @override
  _ProfileMenu createState() => _ProfileMenu();
}

class _ProfileMenu extends State<ProfileMenu> {
  late final User user;
  final String token = '';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (user != null) ...[
            CircleAvatar(
              backgroundImage: NetworkImage('http://178.173.82.2:5020/user/avatar/${user.avatar}'),
              radius: 50,
            ),
            Text(user.login),
            // Остальные элементы интерфейса
          ],
          ElevatedButton(
            onPressed: () { },
            child: Text(localizations.logout),
          ),
        ],
      ),
    );
  }
}