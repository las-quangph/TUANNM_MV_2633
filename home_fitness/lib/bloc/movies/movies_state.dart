import '../../model/movie_item.dart';

enum MoviesStatus {
  initial,
  loading,
  success,
  failure,
}

class MoviesState {
  const MoviesState({
    this.status = MoviesStatus.initial,
    this.popularMovies = const [],
    this.topRatedMovies = const [],
    this.searchQuery = '',
    this.searchResults = const [],
    this.searchPage = 1,
    this.hasMoreSearchResults = false,
    this.isLoadingMoreSearchResults = false,
    this.errorMessage,
  });

  final MoviesStatus status;
  final List<MovieItem> popularMovies;
  final List<MovieItem> topRatedMovies;
  final String searchQuery;
  final List<MovieItem> searchResults;
  final int searchPage;
  final bool hasMoreSearchResults;
  final bool isLoadingMoreSearchResults;
  final String? errorMessage;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  MoviesState copyWith({
    MoviesStatus? status,
    List<MovieItem>? popularMovies,
    List<MovieItem>? topRatedMovies,
    String? searchQuery,
    List<MovieItem>? searchResults,
    int? searchPage,
    bool? hasMoreSearchResults,
    bool? isLoadingMoreSearchResults,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MoviesState(
      status: status ?? this.status,
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      searchPage: searchPage ?? this.searchPage,
      hasMoreSearchResults:
          hasMoreSearchResults ?? this.hasMoreSearchResults,
      isLoadingMoreSearchResults:
          isLoadingMoreSearchResults ?? this.isLoadingMoreSearchResults,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
