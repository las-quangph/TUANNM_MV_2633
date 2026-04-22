abstract class MoviesEvent {
  const MoviesEvent();
}

class LoadMovies extends MoviesEvent {
  const LoadMovies();
}

class SearchMovies extends MoviesEvent {
  const SearchMovies(this.query);

  final String query;
}

class LoadMoreSearchMovies extends MoviesEvent {
  const LoadMoreSearchMovies();
}
