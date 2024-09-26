import 'package:flutter/material.dart';

import '../api/lists_api.dart';
import '../l10n/app_localizations.dart';
import '../models/lists_model.dart';
import '../utils/helpers.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/watched_anime_card.dart';
import '../widgets/watching_anime_card.dart';

class UserLists extends StatefulWidget {
  final String username;

  UserLists({required this.username});

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
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.animelists),
      ),
      body: userLists == null
          ? Center(child: CircularProgressIndicator())
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
                      backgroundColor: isWatchingSelected ? Color(0xFF2A2232) : Color(0xFF1d1b20)
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
                    backgroundColor: !isWatchingSelected ? Color(0xFF2A2232) : Color(0xFF1d1b20)
                  ),
                  child: Text(localizations.watching),
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      bottomNavigationBar: BottomNavBar(currentIndex: 2), // Устанавливаем индекс для "My Lists"
    );
  }
}
