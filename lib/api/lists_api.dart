import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lists_model.dart';
import '../utils/constants.dart';

class ListsAPI {
  static Future<UserListsModel?> fetchlists(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/lists'),
        body: json.encode({"username": username}),
        headers: {"Content-Type": "application/json"}
      );

      // Логирование ответа
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserListsModel.fromJson(jsonResponse);
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }

  static Future<bool> updateAnimeList(String username, String anime_id, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/update_list'),
        body: json.encode({
          "anime_id": anime_id,
          "action": action,
          "username": username,
        }),
        headers: {"Content-Type": "application/json"},
      );

      // Логирование ответа
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('List updated successfully');
        return true;
      } else {
        print('Failed to update list');
        return false;
      }
    } catch (e) {
      print('Exception caught: $e');
      return false;
    }
  }
}
