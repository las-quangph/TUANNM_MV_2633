enum TMDBEndpoint {
  searchMovie,
  searchTV,
  movieDetail,
  movieCredits,
  movieVideos,
  tvDetail,
  tvCredits,
  tvVideos,
  trendingMovie,
  trendingTV,
  discoverMovie,
  discoverTV,
  popularMovie,
  popularTV,
  popularPerson,
  airingTodayTV,
  movieGenres,
  tvGenres
}

enum TMDBMediaType { movie, tv }

extension TMDBEndpointX on TMDBEndpoint {
  String path({int? id}) {
    switch (this) {
      case TMDBEndpoint.searchMovie:
        return '/search/movie';
      case TMDBEndpoint.searchTV:
        return '/search/tv';
      case TMDBEndpoint.movieDetail:
        return '/movie/$id';
      case TMDBEndpoint.movieCredits:
        return '/movie/$id/credits';
      case TMDBEndpoint.movieVideos:
        return '/movie/$id/videos';
      case TMDBEndpoint.tvDetail:
        return '/tv/$id';
      case TMDBEndpoint.tvCredits:
        return '/tv/$id/credits';
      case TMDBEndpoint.tvVideos:
        return '/tv/$id/videos';
      case TMDBEndpoint.trendingMovie:
        return '/trending/movie/week';
      case TMDBEndpoint.trendingTV:
        return '/trending/tv/week';
      case TMDBEndpoint.discoverMovie:
        return '/discover/movie';
      case TMDBEndpoint.discoverTV:
        return '/discover/tv';
      case TMDBEndpoint.popularMovie:
        return '/movie/popular';
      case TMDBEndpoint.popularTV:
        return '/tv/popular';
      case TMDBEndpoint.popularPerson:
        return '/person/popular';
      case TMDBEndpoint.airingTodayTV:
        return '/tv/airing_today';
      case TMDBEndpoint.movieGenres:
        return '/genre/movie/list';
      case TMDBEndpoint.tvGenres:
        return '/genre/tv/list';
    }
  }
}
