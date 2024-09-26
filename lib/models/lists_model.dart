class AnimeItem {
  final int anime_id;
  final String name;
  final String img_path;

  AnimeItem({required this.anime_id, required this.name, required this.img_path});

  factory AnimeItem.fromJson(Map<String, dynamic> json) {
    return AnimeItem(
      anime_id: json['anime_id'],
      name: json['name'],
      img_path: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anime_id': anime_id,
      'name': name,
      'img': img_path,
    };
  }
}

class UserListsModel {
  final List<AnimeItem> watched;
  final List<AnimeItem> watching;

  UserListsModel({required this.watched, required this.watching});

  factory UserListsModel.fromJson(Map<String, dynamic> json) {
    return UserListsModel(
      watched: (json['watched'] as List<dynamic>)
          .map((item) => AnimeItem.fromJson(item))
          .toList(),
      watching: (json['watching'] as List<dynamic>)
          .map((item) => AnimeItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watched': watched.map((item) => item.toJson()).toList(),
      'watching': watching.map((item) => item.toJson()).toList(),
    };
  }
}
