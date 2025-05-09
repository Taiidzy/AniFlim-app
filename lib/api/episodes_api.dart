import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:AniFlim/models/episodes_model.dart';
import 'package:AniFlim/utils/constants.dart';

class EpisodesAPI {
  static Future<List<Episode>> fetchAnimeEpisodes(String animeId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/anime/releases/$animeId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> episodesJson = data['episodes'];

        final List<Episode> episodes = episodesJson
            .map((e) => Episode.fromJson(e as Map<String, dynamic>))
            .toList();

        return episodes;
      } else {
        throw Exception('Failed to load episodes, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load episodes: $e');
    }
  }
}