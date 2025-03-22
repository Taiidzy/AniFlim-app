class AnimeProgressItem {
  final String id;
  final int episode;

  AnimeProgressItem({required this.id, required this.episode});

  factory AnimeProgressItem.fromJson(Map<String, dynamic> json) {
    return AnimeProgressItem(
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