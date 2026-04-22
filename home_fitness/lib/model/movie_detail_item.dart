class MovieDetailItem {
  const MovieDetailItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.backdropPath,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.runtimeMinutes,
    required this.genres,
    this.trailerUrl,
  });

  final int id;
  final String title;
  final String overview;
  final String? backdropPath;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;
  final int runtimeMinutes;
  final List<String> genres;
  final String? trailerUrl;

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

  String? get backdropUrl => backdropPath == null
      ? null
      : 'https://image.tmdb.org/t/p/w780$backdropPath';

  String? get heroImageUrl => posterUrl ?? backdropUrl;

  factory MovieDetailItem.fromTmdb({
    required Map<String, dynamic> details,
    String? trailerUrl,
  }) {
    final genres = ((details['genres'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => (item['name'] as String?) ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return MovieDetailItem(
      id: (details['id'] as num?)?.toInt() ?? 0,
      title: (details['title'] as String?) ?? 'Untitled',
      overview: (details['overview'] as String?) ?? '',
      backdropPath: details['backdrop_path'] as String?,
      posterPath: details['poster_path'] as String?,
      voteAverage: (details['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: (details['release_date'] as String?) ?? '',
      runtimeMinutes: (details['runtime'] as num?)?.toInt() ?? 0,
      genres: genres,
      trailerUrl: trailerUrl,
    );
  }
}
