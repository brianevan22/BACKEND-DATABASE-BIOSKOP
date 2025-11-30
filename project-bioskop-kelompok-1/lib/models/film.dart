class Film {
  final int id;
  final String title;
  final String duration;
  final String synopsis;
  final String poster;

  const Film({required this.id, required this.title, required this.duration, required this.synopsis, required this.poster});

  // Mapping untuk database
  factory Film.fromMap(Map<String, dynamic> m) {
    return Film(
      id: m['id'] as int,
      title: m['title'] as String,
      duration: m['duration'] as String,
      synopsis: m['synopsis'] as String,
      poster: m['poster'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'synopsis': synopsis,
      'poster': poster,
    };
  }
}
