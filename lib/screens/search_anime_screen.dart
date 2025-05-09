import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/models/anime_model.dart';
import 'package:AniFlim/widgets/anime_card.dart';
import 'package:AniFlim/api/anime_api.dart';

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getGridCount(context),
            childAspectRatio: _getChildAspectRatio(context),
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

  int _getGridCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      if (width > 1600) return 8;
      if (width > 1200) return 6;
      if (width > 900) return 5;
      return 4;
    } else {
      return width > 600 ? 3 : 2;
    }
  }

  double _getChildAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Platform.isMacOS || Platform.isWindows) {
      return 0.65; // Увеличим карточки на ПК
    } else if (width > 400) {
      return 0.65; // Для планшетов и больших телефонов
    } else {
      return 0.55; // Для обычных телефонов
    }
  }
}
