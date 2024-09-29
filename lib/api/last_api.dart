import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/last_model.dart';
import '../utils/constants.dart';

class LastAPI {
  static Future<List<Last>> fetchLastAnime(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/last'),
        body: jsonEncode({"username": username}),
        headers: {"Content-Type": "application/json"},
      );

      // Логирование ответа
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Last.fromJson(item)).toList();
      } else {
        print('Error: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load anime: $e');
    }
  }
}
