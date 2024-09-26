import 'lists_model.dart';

class User {
  final int id;
  final String username;
  final String avatar;
  final UserListsModel? userLists; // Добавлен список аниме

  User({
    required this.id,
    required this.username,
    required this.avatar,
    this.userLists, // Это поле теперь может быть null
  });

  // Преобразование JSON в объект User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      username: json['username'],
      avatar: json['avatar'],
      userLists: json.containsKey('userLists') && json['userLists'] != null
          ? UserListsModel.fromJson(json['userLists'])
          : null, // Безопасная обработка отсутствия userLists
    );
  }
}