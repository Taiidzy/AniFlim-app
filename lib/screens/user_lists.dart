import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';

class UserLists extends StatefulWidget {
  final String username;

  const UserLists({super.key, required this.username});

  @override
  _UserListsState createState() => _UserListsState();
}

class _UserListsState extends State<UserLists> {
  bool isWatchingSelected = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(localizations.animelists),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Text("1"),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // Устанавливаем индекс для "My Lists"
    );
  }
}
