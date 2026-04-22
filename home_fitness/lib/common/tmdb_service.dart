import 'package:tmdb_api/tmdb_api.dart';

import '../model/movie_detail_item.dart';
import '../model/movie_item.dart';

class TmdbService {
  TmdbService({
    TMDB? tmdb,
  }) : _tmdb = tmdb;

  final TMDB? _tmdb;

  static const _apiKey = '8551e209c37970947c9af1454b763bb1';
  static const _readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4NTUxZTIwOWMzNzk3MDk0N2M5YWYxNDU0Yjc2M2JiMSIsIm5iZiI6MTc0NDU5NzU4MC4xODQsInN1YiI6IjY3ZmM3MjRjZWMyMmJhM2I0OWQ5NzI4YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FW5sYzlWjppSRLr-iWAcsgRBOpdaFS6kJYRW_i5iw34';

  bool get isConfigured => _tmdb != null || _apiKey.isNotEmpty;

  TMDB get _client =>
      _tmdb ??
      TMDB(
        ApiKeys(_apiKey, _readAccessToken),
        logConfig: const ConfigLogger(
          showLogs: false,
          showErrorLogs: true,
        ),
      );

  Future<List<MovieItem>> getPopularMovies() async {
    final responses = await Future.wait([
      _client.v3.search.queryMovies('rocky'),
      _client.v3.search.queryMovies('creed'),
      _client.v3.search.queryMovies('warrior'),
      _client.v3.search.queryMovies('southpaw'),
      _client.v3.search.queryMovies('fitness documentary'),
    ]);
    final movies = _mergeAndFilterMovies(responses);
    return _filterMoviesWithTrailer(
      movies,
      minResults: 8,
    );
  }

  Future<List<MovieItem>> getTopRatedMovies() async {
    final responses = await Future.wait([
      _client.v3.search.queryMovies('free solo'),
      _client.v3.search.queryMovies('rush'),
      _client.v3.search.queryMovies('coach carter'),
      _client.v3.search.queryMovies('million dollar baby'),
      _client.v3.search.queryMovies('ford v ferrari'),
    ]);
    final movies = _mergeAndFilterMovies(responses);
    return _filterMoviesWithTrailer(
      movies,
      minResults: 8,
    );
  }

  Future<PaginatedMovieResults> searchAllMovies(
    String query, {
    int page = 1,
  }) async {
    final response = await _client.v3.search.queryMovies(
      query,
      page: page,
    );
    final results = _parseMovies(response)
        .where((movie) => movie.posterUrl != null)
        .toList(growable: false);
    final totalPages = (response['total_pages'] as num?)?.toInt() ?? page;
    return PaginatedMovieResults(
      movies: results,
      page: page,
      hasMore: page < totalPages,
    );
  }

  Future<MovieDetailItem> getMovieDetail(int movieId) async {
    final details = await _client.v3.movies.getDetails(movieId);
    final videos = await _client.v3.movies.getVideos(movieId);
    final trailerUrl = _resolveTrailerUrl(videos);
    return MovieDetailItem.fromTmdb(
      details: Map<String, dynamic>.from(details),
      trailerUrl: trailerUrl,
    );
  }

  Future<List<MovieItem>> _filterMoviesWithTrailer(
    List<MovieItem> movies, {
    required int minResults,
  }) async {
    if (movies.isEmpty) {
      return const [];
    }

    final candidates = movies.take(18).toList(growable: false);
    final checks = await Future.wait(
      candidates.map((movie) async {
        try {
          final videos = await _client.v3.movies.getVideos(movie.id);
          return _resolveTrailerUrl(videos) == null ? null : movie;
        } catch (_) {
          return null;
        }
      }),
    );

    final withTrailer = checks.whereType<MovieItem>().toList(growable: false);
    if (withTrailer.length >= minResults) {
      return withTrailer;
    }

    // If TMDB returns too few themed movies with videos, keep some fallback
    // items so the section does not collapse entirely.
    return [
      ...withTrailer,
      ...movies.where((movie) => !withTrailer.any((item) => item.id == movie.id)),
    ].take(minResults).toList(growable: false);
  }

  List<MovieItem> _parseMovies(Map response) {
    final results = response['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map>()
        .map((item) => MovieItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<MovieItem> _mergeAndFilterMovies(List<Map> responses) {
    const themeKeywords = [
      'fitness',
      'workout',
      'gym',
      'sport',
      'sports',
      'boxing',
      'rocky',
      'creed',
      'warrior',
      'southpaw',
      'running',
      'cycling',
      'bicycle',
      'bike',
      'martial',
      'fight',
      'athlete',
      'training',
      'exercise',
      'soccer',
      'football',
      'basketball',
      'baseball',
      'racing',
      'ferrari',
      'formula',
      'tennis',
      'swim',
      'olympic',
    ];

    final merged = <MovieItem>[];
    final seenIds = <int>{};

    for (final response in responses) {
      for (final movie in _parseMovies(response)) {
        if (!seenIds.add(movie.id)) {
          continue;
        }

        final haystack =
            '${movie.title} ${movie.overview}'.toLowerCase();
        final matchesTheme = themeKeywords.any(haystack.contains);
        if (matchesTheme) {
          merged.add(movie);
        }
      }
    }

    return merged;
  }

  String? _resolveTrailerUrl(Map videos) {
    final results = videos['results'];
    if (results is! List) {
      return null;
    }

    final normalizedVideos = results
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    Map<String, dynamic>? selected = _selectPreferredVideo(
      normalizedVideos,
      allowedTypes: const ['trailer'],
      requireOfficial: true,
      site: 'youtube',
    );
    selected ??= _selectPreferredVideo(
      normalizedVideos,
      allowedTypes: const ['trailer', 'teaser', 'clip', 'featurette'],
      site: 'youtube',
    );
    selected ??= _selectPreferredVideo(
      normalizedVideos,
      allowedTypes: const ['trailer', 'teaser', 'clip', 'featurette'],
      site: 'vimeo',
    );

    final key = selected?['key'] as String?;
    if (selected == null || key == null || key.isEmpty) {
      return null;
    }

    final site = (selected['site'] as String?)?.toLowerCase();
    if (site == 'vimeo') {
      return 'https://vimeo.com/$key';
    }
    return 'https://www.youtube.com/watch?v=$key';
  }

  Map<String, dynamic>? _selectPreferredVideo(
    List<Map<String, dynamic>> videos, {
    required List<String> allowedTypes,
    required String site,
    bool requireOfficial = false,
  }) {
    for (final item in videos) {
      final itemSite = (item['site'] as String?)?.toLowerCase();
      final itemType = (item['type'] as String?)?.toLowerCase();
      final isOfficial = item['official'] == true;
      if (itemSite != site || !allowedTypes.contains(itemType)) {
        continue;
      }
      if (requireOfficial && !isOfficial) {
        continue;
      }
      return item;
    }
    return null;
  }
}

class PaginatedMovieResults {
  const PaginatedMovieResults({
    required this.movies,
    required this.page,
    required this.hasMore,
  });

  final List<MovieItem> movies;
  final int page;
  final bool hasMore;
}
