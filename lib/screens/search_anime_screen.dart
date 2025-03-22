import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import '../api/anime_api.dart';

class SearchAnime extends SearchDelegate {

  @override
  List<Widget> buildActions(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return [
      IconButton(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedCancelCircle, color: isDarkTheme ? Colors.white : Colors.black, size: 22.0
        ),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // Отображение результатов поиска в виде сетки
  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Введите запрос"));
    }
    return FutureBuilder<List<Anime>>(
      future: AnimeAPI().searchAnime(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Ошибка: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Ничего не найдено"));
        }
        final results = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return AnimeCard(anime: results[index]);
          },
        );
      },
    );
  }

  // Отображение подсказок в виде списка
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Введите запрос"));
    }
    return FutureBuilder<List<Anime>>(
      future: AnimeAPI().searchAnime(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text("Ошибка: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Ничего не найдено"));
        }
        final suggestions = snapshot.data!;
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
      },
    );
  }
}
