import 'lists_model.dart';

class User {
  final int id;
  final String login;
  final String avatar;
  final int totalTime;
  final int totalEpisode;
  final List<dynamic> planed;
  final List<AnimeProgressItem> watching;
  final List<AnimeProgressItem> watched;
  final List<dynamic> progress;

  User({
    required this.id,
    required this.login,
    required this.avatar,
    required this.totalTime,
    required this.totalEpisode,
    required this.planed,
    required this.watching,
    required this.watched,
    required this.progress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      login: json['login'],
      avatar: json['avatar'],
      totalTime: json['total_time'] ?? 0,
      totalEpisode: json['total_episode'] ?? 0,
      planed: json['planed'] ?? [],
      watching: (json['watching'] as List<dynamic>?)
          ?.map((item) => AnimeProgressItem.fromJson(item))
          .toList() ?? [],
      watched: (json['watched'] as List<dynamic>?)
          ?.map((item) => AnimeProgressItem.fromJson(item))
          .toList() ?? [],
      progress: json['progress'] ?? [],
    );
  }
}