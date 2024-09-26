import 'dart:convert';

import 'package:http/http.dart' as http;
p;

import '../utils/constants.dart';

class UserAPI {
  Future<void> updateTime(String username, String animeId, String episode, String time) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/update_watch_time'),
        body: jsonEncode({"username": username, "animeId": animeId, "episode": episode, "time": time}),
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Время просмотра anime_id: $animeId для $username обновлено на таймкод: $time и эпизод: $episode');
      }
    } catch (e) {
      throw Exception('Failed to update watch time: $e');
    }
  }

  Future<void> updateMoment(String username, String animeId, String episode) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/update_moment'),
        body: jsonEncode({"username": username, "animeId": animeId, "episode": episode}),
        headers: {"Content-Type": "application/json"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Момент anime_id: $animeId для $username обновлен');
      } else {
        print('Произошла ошибка во время обновления момента');
      }
    } catch (e) {
      throw Exception('Failed to update moment: $e');
    }
  }
}
