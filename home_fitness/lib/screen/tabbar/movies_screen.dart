import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/movies/movies_bloc.dart';
import '../../bloc/movies/movies_event.dart';
import '../../bloc/movies/movies_state.dart';
import '../../common/ext/device_ext.dart';
import '../../model/movie_item.dart';
import '../../route/app_routes.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MoviesBloc()..add(const LoadMovies()),
      child: const _MoviesView(),
    );
  }
}

class _MoviesView extends StatefulWidget {
  const _MoviesView();

  @override
  State<_MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<_MoviesView> {
  late final PageController _featuredController;
  late final ScrollController _contentScrollController;
  Timer? _autoScrollTimer;
  int _featuredPage = 0;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.88);
    _contentScrollController = ScrollController()..addListener(_onContentScroll);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _featuredController.dispose();
    _contentScrollController
      ..removeListener(_onContentScroll)
      ..dispose();
    super.dispose();
  }

  void _onContentScroll() {
    if (!_contentScrollController.hasClients) {
      return;
    }
    final position = _contentScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<MoviesBloc>().add(const LoadMoreSearchMovies());
    }
  }

  void _syncAutoScroll(int itemCount) {
    _autoScrollTimer?.cancel();
    if (itemCount <= 1) {
      return;
    }
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_featuredController.hasClients) {
        return;
      }
      final nextPage = (_featuredPage + 1) % itemCount;
      _featuredController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  List<MovieItem> _buildFeaturedMovies(MoviesState state) {
    final featured = <MovieItem>[];
    final seenIds = <int>{};
    for (final movie in [...state.topRatedMovies, ...state.popularMovies]) {
      if (movie.posterUrl == null) {
        continue;
      }
      if (seenIds.add(movie.id)) {
        featured.add(movie);
      }
    }
    featured.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
    return featured.take(6).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: BlocBuilder<MoviesBloc, MoviesState>(
          builder: (context, state) {
            if ((state.status == MoviesStatus.loading &&
                    !state.isSearching &&
                    state.popularMovies.isEmpty) ||
                state.status == MoviesStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE7FF57)),
              );
            }

            if (state.status == MoviesStatus.failure && !state.isSearching) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    state.errorMessage ?? 'Unable to load movies.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.isPhone ? 16 : 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            final featuredMovies = state.isSearching
                ? const <MovieItem>[]
                : _buildFeaturedMovies(state);
            _syncAutoScroll(featuredMovies.length);

            final gridMovies = (state.isSearching
                    ? state.searchResults
                    : [
                        ...state.popularMovies,
                        ...state.topRatedMovies.where(
                          (movie) => !state.popularMovies.any(
                            (item) => item.id == movie.id,
                          ),
                        ),
                      ])
                .where((movie) => movie.posterUrl != null)
                .toList(growable: false);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Movies',
                    style: TextStyle(
                      color: Color(0xFFE7FF57),
                      fontSize: context.isPhone ? 30 : 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fitness-related films have the potential to inspire you to get exercise.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.isPhone ? 14 : 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MoviesSearchField(
                    initialValue: state.searchQuery,
                    onChanged: (value) {
                      context.read<MoviesBloc>().add(SearchMovies(value));
                      if (_contentScrollController.hasClients) {
                        _contentScrollController.jumpTo(0);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFE7FF57),
                      onRefresh: () async {
                        if (state.isSearching) {
                          context.read<MoviesBloc>().add(
                                SearchMovies(state.searchQuery),
                              );
                        } else {
                          context.read<MoviesBloc>().add(const LoadMovies());
                        }
                      },
                      child: _MovieGridSection(
                        controller: _contentScrollController,
                        featuredMovies: featuredMovies,
                        featuredController: _featuredController,
                        featuredPage: _featuredPage,
                        onFeaturedPageChanged: (page) {
                          if (_featuredPage == page) {
                            return;
                          }
                          setState(() {
                            _featuredPage = page;
                          });
                        },
                        title: state.isSearching
                            ? 'Search Results'
                            : 'Related to fitness',
                        movies: gridMovies,
                        showLoadingMore: state.isSearching &&
                            state.isLoadingMoreSearchResults,
                        emptyLabel: state.isSearching
                            ? 'No movies found for this search.'
                            : 'No fitness movies available.',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MoviesSearchField extends StatefulWidget {
  const _MoviesSearchField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_MoviesSearchField> createState() => _MoviesSearchFieldState();
}

class _MoviesSearchFieldState extends State<_MoviesSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _MoviesSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.isPhone ? 14 : 24,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search all movies',
        hintStyle: TextStyle(
          color: Colors.white54,
          fontSize: context.isPhone ? 14 : 24,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFE7FF57),
        ),
        filled: true,
        fillColor: const Color(0xFF232323),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FeaturedMoviesCarousel extends StatelessWidget {
  const _FeaturedMoviesCarousel({
    required this.movies,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final List<MovieItem> movies;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Rated Fitness Picks',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.isPhone ? 20 : 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: context.isPhone ? 228 : 400,
          child: PageView.builder(
            controller: controller,
            itemCount: movies.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == movies.length - 1 ? 0 : 12,
                ),
                child: _FeaturedMovieCard(movie: movie),
              );
            },
          ),
        ),
        if (movies.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              movies.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentPage ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == currentPage
                      ? const Color(0xFFE7FF57)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard({
    required this.movie,
  });

  final MovieItem movie;

  @override
  Widget build(BuildContext context) {
    final heroImageUrl = movie.posterUrl ?? movie.backdropUrl;

    return InkWell(
      onTap: () => context.push(AppRoutes.movieDetail, extra: movie),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF232323),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (heroImageUrl != null)
              Image.network(
                heroImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.isPhone ? 24 : 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isEmpty
                        ? 'No overview available.'
                        : movie.overview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.isPhone ? 13 : 23,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieGridSection extends StatelessWidget {
  const _MovieGridSection({
    required this.controller,
    required this.featuredMovies,
    required this.featuredController,
    required this.featuredPage,
    required this.onFeaturedPageChanged,
    required this.title,
    required this.movies,
    required this.showLoadingMore,
    required this.emptyLabel,
  });

  final ScrollController controller;
  final List<MovieItem> featuredMovies;
  final PageController featuredController;
  final int featuredPage;
  final ValueChanged<int> onFeaturedPageChanged;
  final String title;
  final List<MovieItem> movies;
  final bool showLoadingMore;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (featuredMovies.isNotEmpty) ...[
            _FeaturedMoviesCarousel(
              movies: featuredMovies,
              controller: featuredController,
              currentPage: featuredPage,
              onPageChanged: onFeaturedPageChanged,
            ),
            const SizedBox(height: 26),
          ],
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.isPhone ? 20 : 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                emptyLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: context.isPhone ? 14 : 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      controller: controller,
      slivers: [
        if (featuredMovies.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _FeaturedMoviesCarousel(
              movies: featuredMovies,
              controller: featuredController,
              currentPage: featuredPage,
              onPageChanged: onFeaturedPageChanged,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 26),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.isPhone ? 20 : 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.isPhone ? 3 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: context.isPhone ? 14 : 20,
            childAspectRatio: context.isPhone ? 0.56 : 0.7,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= movies.length) {
                return const _MovieLoadingCard();
              }
              return _MoviePosterCard(movie: movies[index]);
            },
            childCount: movies.length + (showLoadingMore ? 3 : 0),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}

class _MoviePosterCard extends StatelessWidget {
  const _MoviePosterCard({
    required this.movie,
  });

  final MovieItem movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.movieDetail, extra: movie),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  movie.posterUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.isPhone ? 12 : 22,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieLoadingCard extends StatelessWidget {
  const _MovieLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Color(0xFFE7FF57),
          ),
        ),
      ),
    );
  }
}
