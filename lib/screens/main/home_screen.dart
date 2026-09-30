import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movie.dart';
import '../../repositories/movie_repository.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/app_state_view.dart';
import '../../widgets/movie_section.dart';
import '../movie_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetails(BuildContext context, Movie movie) {
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
      create: (_) => HomeViewModel(context.read<MovieRepository>())..loadHome(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<HomeViewModel>();

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Movie App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: vm.loadHome,
              child: _buildBody(context, vm),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    if (vm.isLoading && vm.trending.isEmpty) {
      return const AppLoadingView(message: 'Loading movies...');
    }

    if (vm.error != null && vm.trending.isEmpty) {
      return AppErrorView(
        message: vm.error!,
        onRetry: vm.loadHome,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      children: [
        MovieSection(
          title: 'Trending',
          movies: vm.trending,
          onMovieTap: (movie) => _openDetails(context, movie),
        ),
        MovieSection(
          title: 'Popular',
          movies: vm.popular,
          onMovieTap: (movie) => _openDetails(context, movie),
        ),
        MovieSection(
          title: 'Now Playing',
          movies: vm.nowPlaying,
          onMovieTap: (movie) => _openDetails(context, movie),
        ),
        MovieSection(
          title: 'Top Rated',
          movies: vm.topRated,
          onMovieTap: (movie) => _openDetails(context, movie),
        ),
        MovieSection(
          title: 'Upcoming',
          movies: vm.upcoming,
          onMovieTap: (movie) => _openDetails(context, movie),
        ),
      ],
    );
  }
}
