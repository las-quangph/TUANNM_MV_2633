class MovieItem {
  const MovieItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

  String? get backdropUrl => backdropPath == null
      ? null
      : 'https://image.tmdb.org/t/p/w780$backdropPath';

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ??
          (json['name'] as String?) ??
          'Untitled',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate:
          (json['release_date'] as String?) ??
          (json['first_air_date'] as String?) ??
          '',
    );
  }
}
