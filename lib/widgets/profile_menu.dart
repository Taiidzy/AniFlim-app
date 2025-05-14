import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:AniFlim/providers/user_provider.dart';
import 'package:AniFlim/main.dart' show navigatorKey;
import 'package:AniFlim/l10n/app_localizations.dart';
import 'package:AniFlim/dialogs/edit_profile.dart';
import 'package:AniFlim/utils/calculate_time.dart';
import 'package:AniFlim/models/user_model.dart';
import 'package:AniFlim/api/user_api.dart';
import 'package:provider/provider.dart';


class ProfileMenu extends StatefulWidget {
  final VoidCallback onLogout;
  final String token;

  const ProfileMenu({
    super.key,
    required this.onLogout,
    required this.token,
  });

  @override
  _ProfileMenuState createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  late Future<User> userInfo;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userInfo = UserAPI.fetchUserData(token: widget.token, userProvider: userProvider);
  }

  Future<void> _changeAvatar(User user) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final success = await UserAPI.updateAvatar(widget.token, pickedFile);
      if (success) {
        // evict старое изображение
        final url = 'http://178.173.82.2:5020/user/avatar/${user.login}';
        await NetworkImage(url).evict();
        setState(() {
          userInfo = UserAPI.fetchUserData(token: widget.token, userProvider: userProvider);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при обновлении аватара")),
        );
      }
    }
  }


  Widget _buildStatColumn(String label, String value, IconData icon) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkTheme ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<User>(
      future: userInfo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          if (snapshot.error.toString().contains('Session expired')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.setToken(null);
              navigatorKey.currentState?.pushReplacementNamed('/login');
            });
          }
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Нет данных'));
        } else {
          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Аватар
                      Positioned(
                        top: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: isDarkTheme 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: isDarkTheme 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.3),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage: NetworkImage(
                                  user.avatar.isNotEmpty
                                      ? 'http://178.173.82.2:5020/user/avatar/${user.login}'
                                      : 'http://178.173.82.2:5020/static/avatars/default.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Имя пользователя
                      Positioned(
                        top: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                              child: Text(
                                user.login,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Кнопки управления
                      Positioned(
                        top: 16,
                        left: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
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
                              child: IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white),
                                onPressed: widget.onLogout,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
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
                              child: IconButton(
                                icon: const Icon(HugeIcons.strokeRoundedUserEdit01, color: Colors.white),
                                onPressed: () => _changeAvatar(user),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Статистика пользователя
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildStatColumn(localizations.totalTime, calculateTotalTime(user.totalTime, context), HugeIcons.strokeRoundedTimeSchedule),
                          _buildStatColumn(localizations.episodes, user.totalEpisode.toString(), HugeIcons.strokeRoundedFilm01),
                          _buildStatColumn(localizations.planned, user.planned.length.toString(), HugeIcons.strokeRoundedLeftToRightListBullet),
                          _buildStatColumn(localizations.watching, user.watching.length.toString(), HugeIcons.strokeRoundedTextCheck),
                          _buildStatColumn(localizations.watched, user.watched.length.toString(), HugeIcons.strokeRoundedPlayList),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      },
    );
  }

  void showEditDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(user: user),
    );
  }
}