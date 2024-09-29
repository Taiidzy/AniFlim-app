import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/episodes_model.dart';
import '../utils/constants.dart';

class EpisodesAPI {
  static Future<List<Episodes>> fetchAnimeEpisodes(int animeId) async {
    try {
      final response = await http.post(Uri.parse('$apiBaseUrl/anime_data'),
          body: json.encode({"animeId": animeId}),
          headers: {"Content-Type": "application/json"}
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> decodedResponse = json.decode(decodedBody);
        return decodedResponse.map((json) => Episodes.fromJson(json)).toList();
      } else {
        return []; // Возврат пустого списка в случае ошибки
      }
    } catch (e) {
      print('Exception caught: $e');
      return []; // Возврат пустого списка в случае исключения
    }
  }
}