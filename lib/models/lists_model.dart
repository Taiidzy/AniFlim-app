class ListsModel {
  final String id;
  final String episode;

  ListsModel({
    required this.id,
    required this.episode
  });

  factory ListsModel.fromJson(Map<String, dynamic> json) {
    return ListsModel(
      id: json['id'],
      episode: json['episode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episode': episode,
    };
  }
}