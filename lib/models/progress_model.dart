class AnimeProgress {
  final int episode;
  final double time;

  AnimeProgress({required this.episode, required this.time});

  factory AnimeProgress.fromJson(Map<String, dynamic> json) {
    return AnimeProgress(
      episode: json['episode'],
      time: double.parse(json['time'].toString()),
    );
  }
}
