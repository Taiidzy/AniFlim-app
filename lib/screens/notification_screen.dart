import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:developer';
import '../api/notification_api.dart';
import '../models/notification_model.dart';
import '../widgets/notification_widget.dart';
import '../l10n/app_localizations.dart';
import 'anime_online_screen.dart';



class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  final NotificationAPI _notificationService = NotificationAPI();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      log("Fetching notifications...", name: 'NotificationScreen');
      final notifications = await _notificationService.fetchNotifications();
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      // Обработка ошибок
      print(e);
    }
  }

  void _navigateToDetail(NotificationItem notification) {
    if (notification.notify == 'new_anime') {
      String animeID = notification.data.split('|')[1].trim();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimeOnlineScreen(animeId: animeID),
        ),
      );
    } else if (notification.notify == 'new_episode') {
      print('Новый эпизод');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetailWidget(notification: notification),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft02, color: isDarkTheme ? Colors.white : Colors.black, size: 24.0),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // Вернуться на предыдущий экран
          },
        ),
        title: Text(localizations.notification),
      ),
      body: _notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  title: Text(notification.data.split('|')[0].trim()),
                  onTap: () => _navigateToDetail(notification),
                );
              },
            ),
    );
  }
}
