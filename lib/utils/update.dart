import 'package:dio/dio.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/update_api.dart';
import '../widgets/update_widget.dart';

class UpdateUtils {
  // Функция для загрузки APK
  static Future<bool> downloadApk(String savePath, String fileUrl) async {
    try {
      double progressValue = 0.0;

      // Создаем Dio и ожидаем завершения загрузки
      await Dio().download(
          fileUrl,
          savePath,
          onReceiveProgress: (count, total) {
            if (total != -1) {
              final value = count / total;
              if (progressValue != value) {
                progressValue = value;
                // debugPrint("Прогресс загрузки: ${(value * 100).toStringAsFixed(0)}%");
              }
            }
          }
      );

      debugPrint("APK успешно загружен: $savePath");
      return true;
    } catch (e) {
      debugPrint('Ошибка при загрузке APK: $e');
      return false;
    }
  }

  // Функция для установки APK
  static Future<void> installApk(String savePath) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String packageName = packageInfo.packageName;

      debugPrint("Начинаем установку APK: $savePath для пакета: $packageName");

      final res = await InstallPlugin.install(savePath);

      debugPrint("install apk ${res['isSuccess'] == true ? 'success' : 'fail:${res['errorMessage'] ?? ''}'}");

    } catch (e) {
      debugPrint('Ошибка при установке APK: $e');
    }
  }

  // Функция для проверки обновлений
  static Future<bool> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      bool isUpToDate = await UpdateAPI.checkAppVersion(currentVersion);

      return !isUpToDate && (await showUpdateDialog(context));
    } catch (e) {
      debugPrint('Ошибка при проверке обновлений: $e');
      return false;
    }
  }

  // Функция для вывода диалога об обновлении
  static Future<bool> showUpdateDialog(BuildContext context) async {
    return await showUpdateDialogWidget(context);
  }

  // Функция для загрузки и установки APK
  static Future<void> downloadAndInstallApk(BuildContext context) async {
    try {
      var appDocDir = await getTemporaryDirectory();
      String savePath = '${appDocDir.path}/update.apk';
      String fileUrl = "https://aniflim.space/app";  // Здесь нужно проверить правильность ссылки

      // Загрузка APK
      debugPrint('Начинаем загрузку APK...');
      bool update = await downloadApk(savePath, fileUrl);
      debugPrint('Загрузка завершена. Результат: $update');

      // Установка APK
      if (update) {
        debugPrint('Начинаем установку APK...');
        // await installApk(savePath);
        debugPrint('Установка завершена.');
      } else {
        debugPrint('Загрузка не удалась, установка не будет выполнена.');
      }
    } catch (e) {
      debugPrint('Ошибка в процессе загрузки и установки APK: $e');
    }
  }

  // Функция для открытия URL обновления
  static Future<void> openUpdateUrl() async {
    const String updateUrl = 'https://aniflim.space/app';

    if (await canLaunchUrl(Uri.parse(updateUrl))) {
      await launchUrl(Uri.parse(updateUrl), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Не удалось открыть URL');
    }
  }
}
