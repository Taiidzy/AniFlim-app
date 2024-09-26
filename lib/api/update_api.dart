import 'dart:convert';

import 'package:http/http.dart' as http;
p;

import '../utils/constants.dart';

class UpdateAPI {
  // Проверка версии приложения на сервере
  static Future<bool> checkAppVersion(String currentVersion) async {
    var response = await http.post(
      Uri.parse('$apiBaseUrl/app/chek'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'version': currentVersion}),
    );

    if (response.statusCode == 200) {
      return true;  // Приложение актуально
    } else if (response.statusCode == 406) {
      return false;  // Приложение не актуально
    } else {
      throw Exception('Ошибка при проверке обновления');
    }
  }
}
