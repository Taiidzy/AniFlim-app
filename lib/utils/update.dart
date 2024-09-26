import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/update_api.dart';
import '../widgets/update_widget.dart';

class UpdateUtils {
  // Функция для проверки обновлений
  static Future<void> checkForUpdate(BuildContext context) async {
    // Получаем текущую версию приложения
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // Проверяем обновление через API
    bool isUpToDate = await UpdateAPI.checkAppVersion(currentVersion);

    // Если приложение не актуально, показываем диалог
    if (!isUpToDate) {
      bool shouldUpdate = await showUpdateDialog(context);
      if (shouldUpdate) {
        // Если пользователь соглашается, открываем URL обновления
        await downloadAndInstallApk(context);
      }
    }
  }
  // Функция для загрузки и установки APK
  static Future<void> downloadAndInstallApk(BuildContext context) async {
    // Открываем URL для обновления
    await openUpdateUrl();
  }

  // Загрузка APK
  static Future<void> openUpdateUrl() async {
    const updateUrl = 'https://aniflim.space/app';

    if (await canLaunchUrl(Uri.parse(updateUrl))) {
      await launchUrl(Uri.parse(updateUrl), mode: LaunchMode.externalApplication);
    } else {
      if (kDebugMode) {
        print('Не удаётся открыть URL');
      }
    }
  }
}
