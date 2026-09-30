import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../services/firestore_service.dart';
import '../viewmodels/movie_lists_view_model.dart';
import '../widgets/app_state_view.dart';
import '../widgets/movie_poster.dart';
import 'movie_details_screen.dart';

class MovieListScreen extends StatelessWidget {
  final MovieListType type;

  const MovieListScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieListsViewModel(context.read<FirestoreService>())..loadLists(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<MovieListsViewModel>();
          final list = vm.getMovies(type);

          return Scaffold(
            appBar: AppBar(title: Text(type.title)),
            body: vm.isLoading
                ? const AppLoadingView(message: 'Loading...')
                : vm.error != null
                    ? AppErrorView(
                        message: vm.error!,
                        onRetry: vm.loadLists,
                      )
                    : list.isEmpty
                        ? AppEmptyView(message: type.emptyMessage)
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final movie = list[index];
                              return _MovieListTile(
                                movie: movie,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailsScreen(movieId: movie.id),
                                    ),
                                  ).then((_) => vm.loadLists());
                                },
                                onRemove: () => vm.removeMovie(movie, type),
                              );
                            },
                          ),
          );
        },
      ),
    );
  }
}

class _MovieListTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _MovieListTile({
    required this.movie,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: MoviePoster(
          path: movie.posterPath,
          width: 60,
          height: 86,
        ),
        title: Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Rating: ${movie.rating.toStringAsFixed(1)}'),
        trailing: IconButton(
          onPressed: onRemove,
          tooltip: 'Remove',
          icon: const Icon(Icons.delete_outline),
        ),
        onTap: onTap,
      ),
    );
  }
}
