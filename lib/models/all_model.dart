class All {
  final String all_watched;
  final String all_watching;

  All({
    required this.all_watched,
    required this.all_watching,
  });

  factory All.fromJson(Map<String, dynamic> json) {
    return All(
        all_watched: json['all_watched'],
        all_watching: json['all_watching']
    );
  }
}