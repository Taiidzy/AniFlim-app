import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft02, color: isDarkTheme ? Colors.white : Colors.black, size: 24.0),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // Вернуться на предыдущий экран
          },
        ),
        title: Text(localizations.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.globalSettings, style: const TextStyle(fontSize: 20)),
            SwitchListTile(
              title: Text(localizations.darkTheme, style: const TextStyle(fontSize: 16)),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            const SizedBox(height: 20),
            Text(localizations.language, style: const TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: localeProvider.locale.languageCode,
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  localeProvider.setLocale(newLanguage);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'ru',
                  child: Text('Русский'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(localizations.playerSettings, style: const TextStyle(fontSize: 20)),
            SwitchListTile(
              title: Text(localizations.autocontinue, style: const TextStyle(fontSize: 16)),
              value: localeProvider.autocontinue,
              onChanged: (value) {
                localeProvider.setAutocontinue(value);
              },
            ),
          ],
        ),
      ),
      //  bottomNavigationBar: BottomNavBar(currentIndex: 4), // Устанавливаем индекс для "Settings"
    );
  }
}
