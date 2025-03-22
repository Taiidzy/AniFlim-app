import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';
import '../utils/constants.dart';

class AnimeAPI {
  // Получение списка аниме
  static Future<List<Anime>> fetchAnimeList() async {
    final url = '$apiBaseUrl/anime/schedule/week';
    final response = await http.get(Uri.parse(url));
    
    print('fetchAnimeList - Ответ: ${response.body}');

    if (response.statusCode != 200) {
      print('Ошибка HTTP: ${response.statusCode}');
      throw Exception('HTTP Error ${response.statusCode}');
    }

    final decodedBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    // Проверка на битые данные
    if (decodedBody.isEmpty || decodedBody.codeUnits.every((unit) => unit == 0)) {
      throw Exception('Invalid response data');
    }

    try {
      final List<dynamic> decodedResponse = json.decode(decodedBody);
      return decodedResponse.map((item) => Anime.fromJson(item['release'])).toList();
    } catch (e) {
      print('Ошибка парсинга: $e');
      throw Exception('JSON Parse Error');
    }
  }

  // Получение детальной информации об аниме
  static Future<AnimeDetail> fetchAnimeDetail(String animeId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/anime/releases/$animeId'),
        headers: {"Content-Type": "application/json"}
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return AnimeDetail.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to load anime detail');
      }
    } catch (e) {
      throw Exception('Failed to load anime detail: $e');
    }
  }

  static Future<dynamic> fetchEpisode(String animeId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/anime/releases/$animeId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['episodes'];
      } else {
        throw Exception('Failed to load episode, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Full error details: $e');
      throw Exception('Failed to load episode: $e');
    }
  }

  Future<List<Anime>> searchAnime(String query) async {
    final response = await http.get(Uri.parse('$apiBaseUrl/app/search/releases?query=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки данных');
    }
  }
}