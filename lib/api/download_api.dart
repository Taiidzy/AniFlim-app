import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:archive/archive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/locale_provider.dart';
import '../utils/constants.dart';
import '../main.dart';

class DownloadAnime {
  static Future<void> downloadAnime(String animeId, String name, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    bool isHEVCEnabled = localeProvider.HEVC;

    String downloadUrl = '$hevcUrl/anime/download/$animeId';
    if (isHEVCEnabled) {
      downloadUrl = '$hevcUrl/anime/download/$animeId?codec=true';
    }

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/anime_$animeId.zip';
    final file = File(tempPath);

    try {
      print('downloadUrl: $downloadUrl');

      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await request.send();

      // Получаем размер файла из заголовков ответа
      final totalBytes = response.contentLength ?? 0;

      // Открываем поток для записи в файл
      final fileStream = file.openWrite();

      // Инициализируем уведомление с прогрессом
      await showProgressNotification(name, 0, 'Начало загрузки аниме...');

      int lastProgress = 0;
      int receivedBytes = 0;
      response.stream.listen(
            (chunk) {
          receivedBytes += chunk.length;
          int progress = ((receivedBytes / totalBytes) * 100).toInt();
          fileStream.add(chunk);

          if (progress - lastProgress >= 1) {
            print("Прогресс загрузки аниме: $progress");
            showProgressNotification(name, progress, 'Загрузка аниме... $progress%');
            lastProgress = progress;
          }
        },
        onDone: () async {
          print('Download complete. Extracting archive...');

          await showProgressNotification(name, 100, 'Загрузка завершена. Распаковка...');

          final appDir = await getApplicationDocumentsDirectory();
          final animeDir = Directory('${appDir.path}/anime/$animeId/');
          animeDir.createSync(recursive: true);
          final archive = ZipDecoder().decodeBytes(await file.readAsBytes());

          int extractedFiles = 0;
          final totalFiles = archive.length;

          for (final file in archive) {
            if (file.isFile) {
              final filePath = '${animeDir.path}/${file.name}';
              File(filePath)
                ..createSync(recursive: true)
                ..writeAsBytesSync(file.content as List<int>);

              // Обновляем прогресс распаковки
              extractedFiles++;
              final progress = ((extractedFiles / totalFiles) * 100).toInt();
              print("Прогресс распаковки аниме: $progress");
              showProgressNotification(name, progress, 'Распаковка файлов... $progress%');
            }
          }

          print('Extraction complete, deleting archive.');
          await file.delete();

          prefs.setStringList('anime_$animeId', [
            animeId,
            name,
            '${appDir.path}/anime/$animeId/poster.jpg',
            '${appDir.path}/anime/$animeId'
          ]);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аниме успешно скачено!')),
          );

          // Уведомление о завершении
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

  // Уведомление о прогрессе
  static Future<void> showProgressNotification(String animeName, int progress, String message) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'progress_channel',
      'Прогресс загрузки',
      channelDescription: 'Уведомление о прогрессе загрузки аниме',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );
    final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID уведомления
      'Загрузка аниме "$animeName"', // Заголовок
      message, // Текст уведомления
      platformChannelSpecifics,
      payload: 'progress',
    );
  }

  // Уведомление о завершении загрузки
  static Future<void> showDownloadCompleteNotification(String animeName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_channel',
      'Завершение загрузки',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Загрузка завершена',
      'Аниме "$animeName" успешно загружено.',
      platformChannelSpecifics,
      payload: 'Загрузка завершена',
    );
  }
}
