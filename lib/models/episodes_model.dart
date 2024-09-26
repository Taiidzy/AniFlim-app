class Episodes {
  final int episode;
  final String file;
  
  Episodes({
    required this.episode,
    required this.file
  });
  
  factory Episodes.fromJson(Map<String, dynamic> json) {
    return Episodes(
        episode: json['episode'],
        file: json['file']
    );
  }
}