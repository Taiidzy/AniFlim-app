import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:archive/archive_io.dart';
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
      log('downloadUrl: $downloadUrl', name: 'DownloadAnime');

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
            log('Прогресс загрузки аниме: $progress', name: 'DownloadAnime');
            showProgressNotification(name, progress, 'Загрузка аниме... $progress%');
            lastProgress = progress;
          }
        },
        onDone: () async {
          log('Download complete. Extracting archive...', name: 'DownloadAnime');

          await showProgressNotification(name, 100, 'Загрузка завершена. Распаковка...');

          await extractAnimeArchive(tempPath, animeId, name);

          // Удаляем архив после распаковки
          log('Extraction complete, deleting archive.', name: 'DownloadAnime');
          await file.delete();

          prefs.setStringList('anime_$animeId', [
            animeId,
            name,
            '${(await getApplicationDocumentsDirectory()).path}/anime/$animeId/poster.jpg',
            '${(await getApplicationDocumentsDirectory()).path}/anime/$animeId'
          ]);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аниме успешно скачено!')),
          );

          // Уведомление о завершении
          await showDownloadCompleteNotification(name);
          log('Anime directory path: ${(await getApplicationDocumentsDirectory()).path}/anime/$animeId', name: 'DownloadAnime');
        },
        onError: (e) {
          log('Download error: $e', name: 'DownloadAnime');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка скачивания аниме: $e')),
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      log('Error: $e', name: 'DownloadAnime');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  static Future<void> extractAnimeArchive(String archivePath, String animeId, String name) async {
    final appDir = await getApplicationDocumentsDirectory();
    final animeDir = Directory('${appDir.path}/anime/$animeId/');
    animeDir.createSync(recursive: true);

    // Открываем файл архива как поток
    final inputStream = InputFileStream(archivePath);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    int extractedFiles = 0;
    final totalFiles = archive.files.length;

    for (final file in archive.files) {
      if (file.isFile) {
        final filePath = '${animeDir.path}/${file.name}';
        final outputStream = OutputFileStream(filePath);
        file.writeContent(outputStream);

        extractedFiles++;
        final progress = ((extractedFiles / totalFiles) * 100).toInt();
        log("Прогресс распаковки аниме: $progress", name: 'extractAnimeArchive');
        showProgressNotification(name, progress, 'Распаковка файлов... $progress%');
      }
    }

    inputStream.close();
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
        log('Anime files deleted: ${animeDir.path}', name: 'DeleteAnime');
      } catch (e) {
        log('Error deleting anime files: $e', name: 'DeleteAnime');
      }
    } else {
      log('Anime directory does not exist: ${animeDir.path}', name: 'DeleteAnime');
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
