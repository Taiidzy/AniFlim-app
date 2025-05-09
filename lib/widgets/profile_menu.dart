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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isDarkTheme ? Colors.white : Colors.black, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: isDarkTheme ? Colors.white : Colors.black),
        ),
      ],
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
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Фоновая картинка
                      Positioned.fill(
                        child: Image.network(
                          'https://pic.rutubelist.ru/video/2024-10-08/01/da/01daee6107408babfd3c400d734f36ec.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Затемнение фона
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      // Блюр для плавного перехода
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ),
                      // Имя пользователя
                      Positioned(
                        top: 80,
                        child: Text(
                          user.login,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      // Аватар по центру шапки
                      Positioned(
                        top: 120,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            user.avatar.isNotEmpty
                                ? 'http://178.173.82.2:5020/user/avatar/${user.login}'
                                : 'http://178.173.82.2:5020/static/avatars/default.png',
                          ),
                        ),
                      ),
                      // Кнопка выхода (слева сверху)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: Icon(Icons.logout, color: isDarkTheme ? Colors.white : Colors.black),
                          onPressed: widget.onLogout,
                        ),
                      ),
                      // Кнопка изменения аватара (справа сверху)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: Icon(HugeIcons.strokeRoundedUserEdit01, color: isDarkTheme ? Colors.white : Colors.black),
                          onPressed: () => _changeAvatar(user),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 70),
                // Статистика пользователя
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 10,
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
                ),
                const SizedBox(height: 16),
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