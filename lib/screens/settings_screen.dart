import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:AniFlim/providers/locale_provider.dart';
import 'package:AniFlim/providers/theme_provider.dart';
import 'package:AniFlim/l10n/app_localizations.dart';

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
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://pic.rutubelist.ru/video/2024-10-08/01/da/01daee6107408babfd3c400d734f36ec.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
                  isDarkTheme 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkTheme 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft02,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              size: 24.0,
                            ),
                            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                          ),
                          title: Text(
                            localizations.settings,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme ? Colors.white : Colors.black87,
                              letterSpacing: 1.2,
                            ),
                          ),
                          centerTitle: true,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkTheme 
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkTheme 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.globalSettings,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkTheme ? Colors.white : Colors.black87,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkTheme 
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.white.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: isDarkTheme 
                                                  ? Colors.white.withOpacity(0.1)
                                                  : Colors.black.withOpacity(0.1),
                                              ),
                                            ),
                                            child: SwitchListTile(
                                              title: Text(
                                                localizations.darkTheme,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              value: themeProvider.themeMode == ThemeMode.dark,
                                              onChanged: (value) {
                                                themeProvider.toggleTheme(value);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        localizations.language,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkTheme ? Colors.white : Colors.black87,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkTheme 
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.white.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: isDarkTheme 
                                                  ? Colors.white.withOpacity(0.1)
                                                  : Colors.black.withOpacity(0.1),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: DropdownButton<String>(
                                              value: localeProvider.locale.languageCode,
                                              isExpanded: true,
                                              dropdownColor: isDarkTheme 
                                                ? Colors.black.withOpacity(0.8)
                                                : Colors.white.withOpacity(0.8),
                                              style: TextStyle(
                                                color: isDarkTheme ? Colors.white70 : Colors.black87,
                                                letterSpacing: 0.5,
                                              ),
                                              underline: const SizedBox(),
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkTheme 
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkTheme 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.playerSettings,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkTheme ? Colors.white : Colors.black87,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkTheme 
                                                ? Colors.black.withOpacity(0.3)
                                                : Colors.white.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: isDarkTheme 
                                                  ? Colors.white.withOpacity(0.1)
                                                  : Colors.black.withOpacity(0.1),
                                              ),
                                            ),
                                            child: SwitchListTile(
                                              title: Text(
                                                localizations.autocontinue,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              value: localeProvider.autocontinue,
                                              onChanged: (value) {
                                                localeProvider.setAutocontinue(value);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkTheme 
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDarkTheme 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  ),
                                ),
                                // child: Padding(
                                //   padding: const EdgeInsets.all(16.0),
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         localizations.qualityDownload,
                                //         style: TextStyle(
                                //           fontSize: 20,
                                //           fontWeight: FontWeight.bold,
                                //           color: isDarkTheme ? Colors.white : Colors.black87,
                                //           letterSpacing: 1.2,
                                //         ),
                                //       ),
                                //       const SizedBox(height: 16),
                                //       ClipRect(
                                //         child: BackdropFilter(
                                //           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                //           child: Container(
                                //             decoration: BoxDecoration(
                                //               color: isDarkTheme 
                                //                 ? Colors.black.withOpacity(0.3)
                                //                 : Colors.white.withOpacity(0.3),
                                //               borderRadius: BorderRadius.circular(15),
                                //               border: Border.all(
                                //                 color: isDarkTheme 
                                //                   ? Colors.white.withOpacity(0.1)
                                //                   : Colors.black.withOpacity(0.1),
                                //               ),
                                //             ),
                                //             padding: const EdgeInsets.symmetric(horizontal: 16),
                                //             child: DropdownButton<String>(
                                //               value: localeProvider.qualityDownload,
                                //               isExpanded: true,
                                //               dropdownColor: isDarkTheme 
                                //                 ? Colors.black.withOpacity(0.8)
                                //                 : Colors.white.withOpacity(0.8),
                                //               style: TextStyle(
                                //                 color: isDarkTheme ? Colors.white70 : Colors.black87,
                                //                 letterSpacing: 0.5,
                                //               ),
                                //               underline: const SizedBox(),
                                //               onChanged: (String? newQuality) {
                                //                 if (newQuality != null) {
                                //                   localeProvider.setQualityDownload(newQuality);
                                //                 }
                                //               },
                                //               items: const [
                                //                 DropdownMenuItem(
                                //                   value: '1080p',
                                //                   child: Text('1080p'),
                                //                 ),
                                //                 DropdownMenuItem(
                                //                   value: '720p',
                                //                   child: Text('720p'),
                                //                 ),
                                //                 DropdownMenuItem(
                                //                   value: '480p',
                                //                   child: Text('480p'),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
