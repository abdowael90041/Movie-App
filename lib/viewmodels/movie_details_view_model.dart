import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../repositories/movie_repository.dart';
import '../services/firestore_service.dart';
import '../services/tmdb_service.dart';

class MovieDetailsViewModel extends ChangeNotifier {
  final MovieRepository movieRepository;
  final FirestoreService firestoreService;

  MovieDetailsViewModel({
    required this.movieRepository,
    required this.firestoreService,
  });

  Movie? movie;
  bool isLoading = true;
  bool isSaving = false;
  String? error;
  final Set<MovieListType> lists = {};

  Future<void> load(int movieId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      movie = await movieRepository.getDetails(movieId);
      await _loadMemberships();
    } on TmdbException catch (e) {
      error = e.message;
    } on FirestoreException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load this movie.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool contains(MovieListType type) => lists.contains(type);

  Future<void> toggle(MovieListType type) async {
    final currentMovie = movie;
    if (currentMovie == null || isSaving) return;

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      if (lists.contains(type)) {
        await firestoreService.deleteMovie(currentMovie.id, type);
        lists.remove(type);
      } else {
        await firestoreService.addMovie(currentMovie, type);
        lists.add(type);
      }
    } on FirestoreException catch (e) {
      error = e.message;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _loadMemberships() async {
    final currentMovie = movie;
    if (currentMovie == null) return;

    lists.clear();
    for (final type in MovieListType.values) {
      final movies = await firestoreService.getMovies(type);
      if (movies.any((item) => item.id == currentMovie.id)) {
        lists.add(type);
      }
    }
  }
}
