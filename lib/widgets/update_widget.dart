import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/update.dart'; // Не забудьте импортировать ваш UpdateUtils

// Функция для показа диалога обновления
Future<bool> showUpdateDialogWidget(BuildContext context) async {
  final localizations = AppLocalizations.of(context);
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.aua), // "Доступно обновление"
        content: Text(localizations.nv), // "Хотите обновить приложение?"
        actions: <Widget>[
          TextButton(
            child: Text(localizations.no), // "Нет"
            onPressed: () {
              Navigator.of(context).pop(false);  // Пользователь отказался
            },
          ),
          TextButton(
            child: Text(localizations.yes), // "Да"
            onPressed: () async {
              Navigator.of(context).pop(true);  // Пользователь согласился

              // Вызов функции загрузки и установки APK
              // await UpdateUtils.downloadAndInstallApk(context);
              await UpdateUtils.openUpdateUrl();
            },
          ),
        ],
      );
    },
  ) ?? false;
}
