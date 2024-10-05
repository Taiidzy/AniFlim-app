import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/update_api.dart';
import '../widgets/update_widget.dart';

class UpdateUtils {
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
