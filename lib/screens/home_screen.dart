import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../api/anime_api.dart';
import '../l10n/app_localizations.dart';
import '../models/anime_model.dart';
import '../utils/helpers.dart';
import '../utils/update.dart';
import '../widgets/anime_card.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Anime> animeList = [];

  @override
  void initState() {
    super.initState();
    fetchAnime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateUtils.checkForUpdate(context);
    });
  }

  Future<void> fetchAnime() async {
    try {
      animeList = await AnimeAPI.fetchAnimeList();
      setState(() {});
    } catch (e) {
      showErrorDialog(context, 'Failed to load anime list.');
    }
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: AnimeSearchDelegate(animeList), // Создайте класс AnimeSearchDelegate
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch02, color: Colors.grey, size: 22.0),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: Colors.grey, size: 22.0),
            onPressed: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
          ),
        ],
      ),
      body: animeList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65, // Изменено значение
        ),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          return AnimeCard(anime: animeList[index]);
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0), // Устанавливаем индекс для "Home"
    );
  }
}

class AnimeSearchDelegate extends SearchDelegate {
  final List<Anime> animeList;

  AnimeSearchDelegate(this.animeList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = animeList
        .where((anime) => anime.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return AnimeCard(anime: results[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = animeList
        .where((anime) => anime.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          onTap: () {
            query = suggestions[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}
