import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/anime_model.dart';
import '../models/progress_model.dart';
import '../utils/constants.dart';

class AnimeAPI {
  // Получение списка аниме
  static Future<List<Anime>> fetchAnimeList() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/home'));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> decodedResponse = json.decode(decodedBody);
        print('decodedResponse: $decodedResponse');

        // Преобразование JSON в объекты Anime
        List<Anime> animeList = decodedResponse.map((json) => Anime.fromJson(json)).toList();
        print('animeList: $animeList');

        // Фильтрация аниме по значению release
        animeList = animeList.where((anime) => anime.release == 1).toList();

        return animeList;
      } else {
        throw Exception('Failed to load anime');
      }
    } catch (e) {
      throw Exception('Failed to load anime: $e');
    }
  }


  // Получение детальной информации об аниме
  static Future<Anime> fetchAnimeDetail(String animeId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/anime'),
        body: json.encode({"animeId": animeId}),
        headers: {"Content-Type": "application/json"}
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Anime.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to load anime detail');
      }
    } catch (e) {
      throw Exception('Failed to load anime detail: $e');
    }
  }

  static Future<List<int>> fetchEpisodes(String animeId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/anime_data'),
        body: json.encode({"animeId": animeId}),
        headers: {"Content-Type": "application/json"}
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<int> episodeList = data
            .map((e) => int.parse(e['episode'].toString()))
            .toList();
        return episodeList;
      } else {
        // Возвращаем пустой список или выбрасываем исключение
        throw Exception('Failed to load episodes, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load episodes: $e');
    }
  }

  static Future<List<AnimeProgress>> fetchProgress(String animeId, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/progress'),
        body: json.encode({"animeId": animeId, "username": username}),
        headers: {"Content-Type": "application/json"},
      );

      // Логирование ответа
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<AnimeProgress> progress = (data['progress'] as List<dynamic>)
            .map((e) => AnimeProgress.fromJson(e))
            .toList();
        return progress;
      } else {
        throw Exception('Failed to load progress, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load progress: $e');
    }
  }
}