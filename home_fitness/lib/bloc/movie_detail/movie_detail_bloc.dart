import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/tmdb_service.dart';
import '../../model/movie_item.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc({
    required MovieItem movie,
    TmdbService? tmdbService,
  })  : _tmdbService = tmdbService ?? TmdbService(),
        super(MovieDetailState(movie: movie)) {
    on<LoadMovieDetail>(_onLoadMovieDetail);
  }

  final TmdbService _tmdbService;

  Future<void> _onLoadMovieDetail(
    LoadMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MovieDetailStatus.loading,
        clearErrorMessage: true,
      ),
    );
    try {
      final detail = await _tmdbService.getMovieDetail(state.movie.id);
      emit(
        state.copyWith(
          status: MovieDetailStatus.success,
          detail: detail,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MovieDetailStatus.failure,
          errorMessage: 'Unable to load movie details.',
        ),
      );
    }
  }
}
