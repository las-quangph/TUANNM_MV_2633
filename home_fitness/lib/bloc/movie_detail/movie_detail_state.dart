import '../../model/movie_detail_item.dart';
import '../../model/movie_item.dart';

enum MovieDetailStatus {
  initial,
  loading,
  success,
  failure,
}

class MovieDetailState {
  const MovieDetailState({
    required this.movie,
    this.status = MovieDetailStatus.initial,
    this.detail,
    this.errorMessage,
  });

  final MovieItem movie;
  final MovieDetailStatus status;
  final MovieDetailItem? detail;
  final String? errorMessage;

  MovieDetailState copyWith({
    MovieDetailStatus? status,
    MovieDetailItem? detail,
    bool clearDetail = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MovieDetailState(
      movie: movie,
      status: status ?? this.status,
      detail: clearDetail ? null : detail ?? this.detail,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
