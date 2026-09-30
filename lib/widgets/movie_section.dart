import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final void Function(Movie movie) onMovieTap;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: movies[index],
                  onTap: () => onMovieTap(movies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
