import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/all_model.dart';
import '../utils/constants.dart';

class AllAPI {
  static Future<All?> All_anime(String username) async {
    try {
      final response = await http.post(
          Uri.parse('$apiBaseUrl/user/all_anime'),
          body: json.encode({"username": username}),
          headers: {"Content-Type": "application/json"}
      );

      // Логирование ответа
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return All.fromJson(json.decode(response.body));
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }
}