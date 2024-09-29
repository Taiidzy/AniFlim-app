import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../api/lists_api.dart';
import '../l10n/app_localizations.dart';
import '../models/lists_model.dart';
import '../utils/helpers.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/watched_anime_card.dart';
import '../widgets/watching_anime_card.dart';

class UserLists extends StatefulWidget {
  final String username;

  const UserLists({super.key, required this.username});

  @override
  _UserListsState createState() => _UserListsState();
}

class _UserListsState extends State<UserLists> {
  UserListsModel? userLists;
  bool isWatchingSelected = true;

  @override
  void initState() {
    super.initState();
    fetchLists(widget.username);
  }

  Future<void> fetchLists(String username) async {
    try {
      UserListsModel? lists = await ListsAPI.fetchlists(username);
      setState(() {
        userLists = lists;
      });
    } catch (e) {
      showErrorDialog(context, 'Failed to load anime list.');
    }
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
      body: userLists == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isWatchingSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: !isDarkTheme ? isWatchingSelected ? Colors.grey : Colors.white : isWatchingSelected ? const Color(0xFF2A2232) : const Color(0xFF1d1b20)
                  ),
                  child: Text(localizations.watched),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isWatchingSelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isDarkTheme ? !isWatchingSelected ? Colors.grey : Colors.white : !isWatchingSelected ? const Color(0xFF2A2232) : const Color(0xFF1d1b20)
                  ),
                  child: Text(localizations.watching),
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Количество столбцов
                childAspectRatio: 0.65, // Соотношение сторон
              ),
              itemCount: isWatchingSelected
                  ? userLists!.watching.length
                  : userLists!.watched.length,
              itemBuilder: (context, index) {
                return isWatchingSelected
                    ? WatchingCard(watching: userLists!.watching[index])
                    : WatchedCard(watched: userLists!.watched[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), // Устанавливаем индекс для "My Lists"
    );
  }
}
