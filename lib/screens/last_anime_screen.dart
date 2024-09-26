import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/last_api.dart';
import '../l10n/app_localizations.dart';
import '../models/last_model.dart';
import '../providers/user_provider.dart';
import '../utils/helpers.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/last_anime_card.dart';

class LastAnime extends StatefulWidget {
  @override
  _LastAnime createState() => _LastAnime();
}

class _LastAnime extends State<LastAnime> {
  List<Last> animeList = [];
  
  @override
  void initState() {
    super.initState();
    fetchLast();
  }

  Future<void> fetchLast() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.user?.username;

    if (username == null) {
      showErrorDialog(context, 'Username is null.');
      return;
    }

    try {
      animeList = await LastAPI.fetchLastAnime(username);

      if (animeList.isNotEmpty) {
        String time = animeList[0].time;
        print('First anime time: $time');
      } else {
        print('No anime data available.');
      }

      setState(() {});
      print('Successfully fetched last anime. Data: ${animeList.last.time}');
    } catch (e) {
      showErrorDialog(context, 'Failed to load Last list.');
    }
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.lastanime),
      ),
      body: animeList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85, // Изменено значение
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          return LastCard(anime: animeList[index]);
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3), // Устанавливаем индекс для "lastanime"
    );
  }
}