import 'package:flutter/material.dart';

import 'package:AniFlim/models/user_model.dart';

class EditProfileDialog extends StatelessWidget {
  final User user;

  const EditProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать профиль'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: ''),
          )
          // TODO: Добавить кнопу для изменения аватара, удаления аккаунта, изменения пароля
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            // Сохраните изменения и закройте диалог
            Navigator.pop(context);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}