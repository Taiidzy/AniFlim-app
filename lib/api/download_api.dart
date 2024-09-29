import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:archive/archive.dart';
import '../providers/locale_provider.dart';
import '../utils/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // Импортируйте flutterLocalNotificationsPlugin из main.dart

class DownloadAnime {
  static Future<void> downloadAnime(String animeId, String name, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    bool isHEVCEnabled = localeProvider.HEVC;

    // URL для скачивания аниме с учётом кодека HEVC
    String downloadUrl = '$hevcUrl/anime/download/$animeId';
    if (isHEVCEnabled) {
      downloadUrl = '$hevcUrl/anime/download/$animeId?codec=true';
    }

    // Сохранение архива во временную директорию
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/anime_$animeId.zip';
    final file = File(tempPath);

    try {
      print('downloadUrl: $downloadUrl');
      // Скачивание данных с использованием потоков
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await request.send();

      // Открываем поток для записи в файл
      final fileStream = file.openWrite();

      // Отладка: Начало процесса скачивания
      print('Starting download and saving to $tempPath');

      response.stream.listen(
            (chunk) {
          fileStream.add(chunk);
        },
        onDone: () async {
          print('Download complete. Extracting archive...');

          // После завершения скачивания — разархивируем
          final appDir = await getApplicationDocumentsDirectory();
          final animeDir = Directory('${appDir.path}/anime/$animeId/');
          animeDir.createSync(recursive: true);
          final archive = ZipDecoder().decodeBytes(await file.readAsBytes());

          for (final file in archive) {
            if (file.isFile) {
              final filePath = '${animeDir.path}/${file.name}';
              File(filePath)
                ..createSync(recursive: true)
                ..writeAsBytesSync(file.content as List<int>);
            }
          }

          // Удаляем архив после разархивирования
          print('Extraction complete, deleting archive.');
          await file.delete();

          // Сохранение данных в SharedPreferences
          prefs.setStringList('anime_$animeId', [
            animeId,
            name,
            '${appDir.path}/anime/$animeId/poster.jpg',
            '${appDir.path}/anime/$animeId'
          ]);

          // Уведомление пользователя о завершении
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аниме успешно скачено!')),
          );
          await showDownloadCompleteNotification(name);
          print('Anime directory path: ${animeDir.path}');
        },
        onError: (e) {
          print('Download error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка скачивания аниме: $e')),
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  static Future<void> deleteAnime(String animeId) async {
    final prefs = await SharedPreferences.getInstance();

    // Удаляем данные по ключу
    await prefs.remove('anime_$animeId');

    // Удаляем файлы, связанные с аниме
    final appDir = await getApplicationDocumentsDirectory();
    final animeDir = Directory('${appDir.path}/anime/$animeId/');

    // Проверяем, существует ли директория, и если да, удаляем её
    if (await animeDir.exists()) {
      try {
        await animeDir.delete(recursive: true);
        print('Anime files deleted: ${animeDir.path}');
      } catch (e) {
        print('Error deleting anime files: $e');
      }
    } else {
      print('Anime directory does not exist: ${animeDir.path}');
    }
  }

  static Future<void> showDownloadCompleteNotification(String animeName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_channel', // ID канала
      'Завершение загрузки', // Имя канала
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID уведомления
      'Загрузка завершена', // Заголовок
      'Аниме "$animeName" успешно загружено.', // Текст уведомления
      platformChannelSpecifics,
      payload: 'Загрузка завершена',
    );
  }
}
