import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/codecs.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _isHEVCSupported = false;

  @override
  void initState() {
    super.initState();
    _checkHEVCSupport();
  }

  // Метод для проверки наличия кодека HEVC
  Future<void> _checkHEVCSupport() async {
    List<String> codecs = await Codecs.getSupportedVideoCodecs();
    setState(() {
      _isHEVCSupported = codecs.contains('video/hevc');
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon( icon: HugeIcons.strokeRoundedArrowLeft02, color: Colors.grey, size: 24.0, ),
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
            Text(localizations.style, style: TextStyle(fontSize: 18)),
            SwitchListTile(
              title: Text(localizations.darkTheme),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            SizedBox(height: 20),
            Text(localizations.style, style: TextStyle(fontSize: 18)),
            SwitchListTile(
              title: Text(localizations.autocontinue),
              value: localeProvider.autocontinue,
              onChanged: (value) {
                localeProvider.setAutocontinue(value);
              },
            ),
            SizedBox(height: 20),
            Text(localizations.codecSettings, style: TextStyle(fontSize: 18)),
            SwitchListTile(
              title: Text(localizations.enableHEVC, style: TextStyle(fontSize: 12)),
              value: localeProvider.HEVC,
              onChanged: _isHEVCSupported ? (value) {
                localeProvider.setHEVC(value);
              } : null, // Заблокировать переключатель, если HEVC не поддерживается
              subtitle: _isHEVCSupported
                  ? null
                  : Text(localizations.hevcNotSupported, style: TextStyle(color: Colors.red)),
            ),
            SizedBox(height: 20),
            Text(localizations.language, style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: localeProvider.locale.languageCode,
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  localeProvider.setLocale(newLanguage);
                }
              },
              items: [
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
          ],
        ),
      ),
      //  bottomNavigationBar: BottomNavBar(currentIndex: 4), // Устанавливаем индекс для "Settings"
    );
  }
}
