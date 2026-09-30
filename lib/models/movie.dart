class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double rating;
  final int? runtime;
  final List<String> genres;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.rating,
    this.runtime,
    this.genres = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final genreNames = (json['genres'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((genre) => genre['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        [];

    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? 'Unknown title',
      overview: json['overview']?.toString() ?? '',
      posterPath: json['poster_path']?.toString() ?? '',
      backdropPath: json['backdrop_path']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
      runtime: (json['runtime'] as num?)?.toInt(),
      genres: genreNames,
    );
  }

  factory Movie.fromFirestore(Map<String, dynamic> data) {
    return Movie(
      id: (data['id'] as num?)?.toInt() ?? 0,
      title: data['title']?.toString() ?? 'Unknown title',
      overview: data['overview']?.toString() ?? '',
      posterPath: data['posterPath']?.toString() ?? '',
      backdropPath: data['backdropPath']?.toString() ?? '',
      releaseDate: data['releaseDate']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      runtime: (data['runtime'] as num?)?.toInt(),
      genres: List<String>.from(data['genres'] as List<dynamic>? ?? const []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate,
      'rating': rating,
      'runtime': runtime,
      'genres': genres,
    };
  }
}
