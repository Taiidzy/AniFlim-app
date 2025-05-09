import 'dart:convert';
import 'package:brotli/brotli.dart';
import 'package:http/http.dart' as http;

import 'package:AniFlim/models/anime_detail_model.dart';
import 'package:AniFlim/models/anime_model.dart';
import 'package:AniFlim/utils/constants.dart';

class AnimeAPI {
  // Получение списка аниме
  static Future<List<Anime>> fetchAnimeList() async {
    final url = '$apiBaseUrl/anime/schedule/week';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      print('Ошибка HTTP: ${response.statusCode}');
      throw Exception('HTTP Error ${response.statusCode}');
    }

    String decodedBody;
    if (response.headers['content-encoding']?.toLowerCase() == 'br') {
      try {
        final decompressedBytes = brotli.decode(response.bodyBytes);
        decodedBody = utf8.decode(decompressedBytes);
      } catch (e) {
        print('Ошибка декомпрессии Brotli: $e');
        throw Exception('Brotli Decompression Error');
      }
    } else {
      decodedBody = utf8.decode(response.bodyBytes);
    }

    if (decodedBody.isEmpty || decodedBody.codeUnits.every((unit) => unit == 0)) {
      throw Exception('Invalid response data');
    }

    try {
      final dynamic jsonData = json.decode(decodedBody);

      // Если сервер возвращает объект, а не массив, адаптируем парсинг
      if (jsonData is List) {
        return jsonData.map((item) => Anime.fromJson(item['release'])).toList();
      } else if (jsonData is Map) {
        // Предположим, что нужный массив лежит под ключом 'data' или аналогичным
        final List<dynamic> list = jsonData['data'];
        return list.map((item) => Anime.fromJson(item['release'])).toList();
      } else {
        throw Exception('Unexpected JSON structure');
      }
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

      if (response.statusCode != 200) {
        throw Exception('HTTP Error ${response.statusCode}');
      }

      String decodedBody;
      
      // Обработка Brotli-сжатия
      if (response.headers['content-encoding']?.toLowerCase() == 'br') {
        try {
          final decompressedBytes = brotli.decode(response.bodyBytes);
          decodedBody = utf8.decode(decompressedBytes);
        } catch (e) {
          print('Ошибка декомпрессии Brotli: $e');
          throw Exception('Brotli Decompression Error');
        }
      } else {
        decodedBody = utf8.decode(response.bodyBytes);
      }

      // Проверка валидности данных
      if (decodedBody.isEmpty || decodedBody.codeUnits.every((unit) => unit == 0)) {
        throw Exception('Invalid response data');
      }

      try {
        return AnimeDetail.fromJson(json.decode(decodedBody));
      } catch (e) {
        print('Ошибка парсинга JSON: $e');
        throw Exception('JSON Parse Error');
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

      if (response.statusCode != 200) {
        print('Ошибка HTTP: ${response.statusCode}');
        throw Exception('HTTP Error ${response.statusCode}');
      }

      String decodedBody;
      if (response.headers['content-encoding']?.toLowerCase() == 'br') {
        try {
          final decompressedBytes = brotli.decode(response.bodyBytes);
          decodedBody = utf8.decode(decompressedBytes);
        } catch (e) {
          print('Ошибка декомпрессии Brotli: $e');
          throw Exception('Brotli Decompression Error');
        }
      } else {
        decodedBody = utf8.decode(response.bodyBytes);
      }

      if (decodedBody.isEmpty || decodedBody.codeUnits.every((unit) => unit == 0)) {
        throw Exception('Invalid response data');
      }

      try {
        final dynamic jsonData = json.decode(decodedBody);

        return jsonData['episodes'];
      } catch (e) {
        print('Ошибка парсинга: $e');
        throw Exception('JSON Parse Error');
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