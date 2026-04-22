import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/tmdb_service.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc({
    TmdbService? tmdbService,
  })  : _tmdbService = tmdbService ?? TmdbService(),
        super(const MoviesState()) {
    on<LoadMovies>(_onLoadMovies);
    on<SearchMovies>(_onSearchMovies);
    on<LoadMoreSearchMovies>(_onLoadMoreSearchMovies);
  }

  final TmdbService _tmdbService;

  Future<void> _onLoadMovies(
    LoadMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MoviesStatus.loading,
        clearErrorMessage: true,
      ),
    );

    if (!_tmdbService.isConfigured) {
      emit(
        state.copyWith(
          status: MoviesStatus.failure,
          errorMessage: 'Missing TMDB configuration. Run with TMDB_API_KEY.',
        ),
      );
      return;
    }

    try {
      final popularMovies = await _tmdbService.getPopularMovies();
      final topRatedMovies = await _tmdbService.getTopRatedMovies();
      emit(
        state.copyWith(
          status: MoviesStatus.success,
          popularMovies: popularMovies,
          topRatedMovies: topRatedMovies,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MoviesStatus.failure,
          errorMessage: 'Unable to load movies from TMDB.',
        ),
      );
    }
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchQuery: '',
          searchResults: const [],
          searchPage: 1,
          hasMoreSearchResults: false,
          isLoadingMoreSearchResults: false,
          clearErrorMessage: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: MoviesStatus.loading,
        searchQuery: query,
        clearErrorMessage: true,
      ),
    );

    try {
      final results = await _tmdbService.searchAllMovies(query, page: 1);
      emit(
        state.copyWith(
          status: MoviesStatus.success,
          searchQuery: query,
          searchResults: results.movies,
          searchPage: results.page,
          hasMoreSearchResults: results.hasMore,
          isLoadingMoreSearchResults: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MoviesStatus.failure,
          searchQuery: query,
          isLoadingMoreSearchResults: false,
          errorMessage: 'Unable to search movies from TMDB.',
        ),
      );
    }
  }

  Future<void> _onLoadMoreSearchMovies(
    LoadMoreSearchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    if (!state.isSearching ||
        state.isLoadingMoreSearchResults ||
        !state.hasMoreSearchResults) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingMoreSearchResults: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final nextPage = state.searchPage + 1;
      final results = await _tmdbService.searchAllMovies(
        state.searchQuery,
        page: nextPage,
      );
      final merged = [
        ...state.searchResults,
        ...results.movies.where(
          (movie) => !state.searchResults.any((item) => item.id == movie.id),
        ),
      ];
      emit(
        state.copyWith(
          status: MoviesStatus.success,
          searchResults: merged,
          searchPage: results.page,
          hasMoreSearchResults: results.hasMore,
          isLoadingMoreSearchResults: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMoreSearchResults: false,
          errorMessage: 'Unable to load more movies.',
        ),
      );
    }
  }
}
