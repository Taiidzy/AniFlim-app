import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationDetailWidget extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailWidget({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Обновление приложения'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.data, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(notification.description ?? '', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
