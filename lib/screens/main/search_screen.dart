import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movie.dart';
import '../../repositories/movie_repository.dart';
import '../../viewmodels/search_view_model.dart';
import '../../widgets/app_state_view.dart';
import '../../widgets/movie_card.dart';
import '../movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetails(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(context.read<MovieRepository>()),
      child: Builder(
        builder: (context) {
          final vm = context.watch<SearchViewModel>();

          return Scaffold(
            appBar: AppBar(title: const Text('Search Movies')),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    onChanged: vm.onQueryChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by movie title',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.clear();
                                vm.onQueryChanged('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildResults(context, vm)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchViewModel vm) {
    if (vm.isLoading) return const AppLoadingView(message: 'Searching...');

    if (vm.error != null) {
      return AppErrorView(message: vm.error!);
    }

    if (vm.query.isEmpty) {
      return const AppEmptyView(message: 'Type a movie name to start searching.');
    }

    if (vm.results.isEmpty) {
      return const AppEmptyView(message: 'No movies found for this search.');
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: 0.58,
      ),
      itemCount: vm.results.length,
      itemBuilder: (context, index) {
        final movie = vm.results[index];
        return MovieCard(
          movie: movie,
          onTap: () => _openDetails(movie),
        );
      },
    );
  }
}
