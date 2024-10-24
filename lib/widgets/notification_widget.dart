import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationDetailWidget extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обновление приложения'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.data, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(notification.description ?? '', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
