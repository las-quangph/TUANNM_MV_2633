import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/movie_detail/movie_detail_bloc.dart';
import '../bloc/movie_detail/movie_detail_event.dart';
import '../bloc/movie_detail/movie_detail_state.dart';
import '../common/ext/device_ext.dart';
import '../model/movie_item.dart';
import '../values/app_assets.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  final MovieItem movie;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieDetailBloc(movie: movie)..add(const LoadMovieDetail()),
      child: const _MovieDetailView(),
    );
  }
}

class _MovieDetailView extends StatelessWidget {
  const _MovieDetailView();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          final detail = state.detail;
          if (state.status == MovieDetailStatus.loading ||
              state.status == MovieDetailStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE7FF57)),
            );
          }
          if (state.status == MovieDetailStatus.failure || detail == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.errorMessage ?? 'Unable to load movie details.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          final trailerUrl = detail.trailerUrl;
          final hasDirectTrailer = trailerUrl != null;
          final heroImageUrl = detail.heroImageUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: context.isPhone ? 0.82 : 1.25,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (heroImageUrl != null)
                              Image.network(
                                heroImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _MovieHeroFallback(title: detail.title),
                              )
                            else
                              _MovieHeroFallback(title: detail.title),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.28),
                                    Colors.black.withValues(alpha: 0.90),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    detail.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.isPhone ? 30 : 40,
                                      fontWeight: FontWeight.w800,
                                      height: 1.02,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: topInset + 8,
                      left: 16,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          AppIcons.icBack,
                          width: context.isPhone ? 55 : 70,
                          height: context.isPhone ? 30 : 50,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _DetailChip('${detail.runtimeMinutes} min'),
                          if (detail.releaseDate.isNotEmpty)
                            _DetailChip(detail.releaseDate),
                          ...detail.genres.take(3).map(_DetailChip.new),
                        ],
                      ),
                      if (hasDirectTrailer) ...[
                        const SizedBox(height: 18),
                        SizedBox(
                          width: context.isPhone ? 180 : 250,
                          height: context.isPhone ? 46 : 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              final uri = Uri.parse(trailerUrl);
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE7FF57),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              'Watch Trailer',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: context.isPhone ? 14 : 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ] else
                        const SizedBox(height: 18),
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.isPhone ? 18 : 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        detail.overview.isEmpty
                            ? 'No overview available.'
                            : detail.overview,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: context.isPhone ? 14 : 24,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MovieHeroFallback extends StatelessWidget {
  const _MovieHeroFallback({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF141414),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white54,
              fontSize: context.isPhone ? 18 : 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: context.isPhone ? 12 : 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
