import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movie_list_type.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/movie_lists_view_model.dart';
import '../../widgets/app_state_view.dart';
import '../movie_list_screen.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieListsViewModel(context.read<FirestoreService>())..loadLists(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<MovieListsViewModel>();

          return Scaffold(
            appBar: AppBar(title: const Text('My Lists')),
            body: vm.isLoading
                ? const AppLoadingView(message: 'Loading your lists...')
                : vm.error != null
                    ? AppErrorView(
                        message: vm.error!,
                        onRetry: vm.loadLists,
                      )
                    : RefreshIndicator(
                        onRefresh: vm.loadLists,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: MovieListType.values.map((type) {
                            final count = vm.getMovies(type).length;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  child: Icon(_icon(type)),
                                ),
                                title: Text(
                                  type.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text('$count movies'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieListScreen(type: type),
                                    ),
                                  ).then((_) => vm.loadLists());
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
          );
        },
      ),
    );
  }

  IconData _icon(MovieListType type) {
    switch (type) {
      case MovieListType.favorites:
        return Icons.favorite;
      case MovieListType.watched:
        return Icons.visibility;
      case MovieListType.watching:
        return Icons.play_circle;
      case MovieListType.wantToWatch:
        return Icons.bookmark;
    }
  }
}
