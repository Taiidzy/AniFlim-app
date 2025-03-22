import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserAPI {
  Future<User> fetchUserData(String token) async {
    final response = await http.get(Uri.parse('$apiBaseUrl/user/info'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user data');
    }
  }
}
