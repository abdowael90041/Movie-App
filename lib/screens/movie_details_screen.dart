import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/movie_list_type.dart';
import '../repositories/movie_repository.dart';
import '../services/firestore_service.dart';
import '../viewmodels/movie_details_view_model.dart';
import '../widgets/app_state_view.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailsViewModel(
        movieRepository: context.read<MovieRepository>(),
        firestoreService: context.read<FirestoreService>(),
      )..load(movieId),
      child: const _MovieDetailsBody(),
    );
  }
}

class _MovieDetailsBody extends StatelessWidget {
  const _MovieDetailsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovieDetailsViewModel>();

    if (vm.isLoading && vm.movie == null) {
      return const Scaffold(
        body: AppLoadingView(message: 'Loading movie details...'),
      );
    }

    if (vm.movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorView(message: vm.error ?? 'Movie not found.'),
      );
    }

    final movie = vm.movie!;

    return Scaffold(
      appBar: AppBar(title: const Text('Movie Details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          if (movie.backdropPath.isNotEmpty)
            Image.network(
              '${AppConstants.tmdbBackdropBaseUrl}${movie.backdropPath}',
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 210),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (movie.posterPath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.movie_outlined),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 120,
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.movie_outlined),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text('Rating: ${movie.rating.toStringAsFixed(1)}'),
                          const SizedBox(height: 6),
                          Text(
                            movie.releaseDate.isEmpty
                                ? 'Release date: Unknown'
                                : 'Release date: ${movie.releaseDate}',
                          ),
                          if (movie.runtime != null) ...[
                            const SizedBox(height: 6),
                            Text('Runtime: ${movie.runtime} min'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (movie.genres.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres
                        .map((genre) => Chip(label: Text(genre)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 22),
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview.isEmpty
                      ? 'No overview available.'
                      : movie.overview,
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'My Lists',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...MovieListType.values.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton.icon(
                      onPressed: vm.isSaving ? null : () async {
                        await vm.toggle(type);
                        if (!context.mounted || vm.error == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vm.error!)),
                        );
                      },
                      icon: Icon(_icon(type)),
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          vm.contains(type)
                              ? 'Remove from ${type.title}'
                              : 'Add to ${type.title}',
                        ),
                      ),
                    ),
                  ),
                ),
                if (vm.isSaving)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(MovieListType type) {
    switch (type) {
      case MovieListType.favorites:
        return Icons.favorite_border;
      case MovieListType.watched:
        return Icons.visibility_outlined;
      case MovieListType.watching:
        return Icons.play_circle_outline;
      case MovieListType.wantToWatch:
        return Icons.bookmark_border;
    }
  }
}
