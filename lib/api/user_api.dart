import 'dart:convert';
import 'package:brotli/brotli.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:AniFlim/models/anime_model.dart';

import 'package:AniFlim/models/status_anime_model.dart';
import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/models/progress_model.dart';
import 'package:AniFlim/models/user_model.dart';
import 'package:AniFlim/utils/constants.dart';

class UserAPI {
  static Future<User> fetchUserData({required String token, required UserProvider userProvider,}) async {
    final response = await http.get(
      Uri.parse('$authUrl/user/info'),
      headers: {'x-token': token},
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }

    if (response.statusCode == 401) {
      await userProvider.setToken(null);
      throw Exception('Session expired. Please login again');
    }

    throw Exception('Failed to load user data. Status: ${response.statusCode}');
  }

  static Future<bool> updateAvatar(String token, XFile pickedFile) async {
    final uri = Uri.parse('$authUrl/user/avatar');
    try {
      var request = http.MultipartRequest("PATCH", uri);
      request.headers['x-token'] = token;

      // Определяем mime-тип изображения, по умолчанию JPEG
      String mimeType = pickedFile.mimeType ?? "image/jpeg";

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pickedFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Ошибка при обновлении аватара: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Ошибка: $e");
      return false;
    }
  }

  static Future<bool> updateTimeProgress(String token, int currentTime, String episode, int animeId) async {
    final url = Uri.parse('$authUrl/user/anime/progress/update');
    try {
      final response = await http.post(
        url,
        headers: {
          'x-token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({'currentTime': currentTime, 'episode': episode, 'animeId': animeId}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<AnimeStatusModel?> fetchStatusAnime(String token, int animeId) async {
    final response = await http.post(
      Uri.parse('$authUrl/user/anime/status/get'),
      headers: {
        'x-token': token,
        'Content-Type': 'application/json',
      },
      body: json.encode({'animeid': animeId}),
    );
    if (response.statusCode == 200) {
      return AnimeStatusModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  static Future<bool> addStatusAnime(String token, int animeId) async {
    final url = Uri.parse('$authUrl/user/anime/status');
    try {
      final response = await http.post(
        url,
        headers: {
          'x-token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'animeid': animeId
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateStatusAnime(String token, String status, int animeId) async {
    final url = Uri.parse('$authUrl/user/anime/status');
    try {
      final response = await http.patch(
        url,
        headers: {
          'x-token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': status,
          'animeid': animeId
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteStatusAnime(String token, int animeId) async {
    final url = Uri.parse('$authUrl/user/anime/status');
    try {
      final response = await http.delete(
        url,
        headers: {
          'x-token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'animeid': animeId
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<ProgressModel> fetchProgress(String token, int animeId) async {
    final url = Uri.parse('$authUrl/user/anime/progress/get');
    try {
      final response = await http.post(
        url,
        headers: {
          'x-token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'animeid': animeId
        }),
      );
      if (response.statusCode == 200) {
        return ProgressModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Не удалось загрузить данные пользователя');
      }
    } catch (e) {
      throw Exception('Не удалось загрузить данные пользователя');
    }
  }

  static Future<Anime> fetchAnimeDetail(String animeId) async {
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
        return Anime.fromJson(json.decode(decodedBody));
      } catch (e) {
        print('Ошибка парсинга JSON: $e');
        throw Exception('JSON Parse Error');
      }
    } catch (e) {
      throw Exception('Failed to load anime detail: $e');
    }
  }
}
