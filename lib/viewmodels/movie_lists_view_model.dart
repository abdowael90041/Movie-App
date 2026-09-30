import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../services/firestore_service.dart';

class MovieListsViewModel extends ChangeNotifier {
  final FirestoreService firestoreService;

  MovieListsViewModel(this.firestoreService);

  final Map<MovieListType, List<Movie>> movies = {
    for (final type in MovieListType.values) type: [],
  };

  bool isLoading = false;
  String? error;

  List<Movie> getMovies(MovieListType type) => movies[type] ?? [];

  Future<void> loadLists() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await Future.wait(
        MovieListType.values.map(firestoreService.getMovies),
      );

      for (var index = 0; index < MovieListType.values.length; index++) {
        movies[MovieListType.values[index]] = result[index];
      }
    } on FirestoreException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load your movie lists.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMovie(Movie movie, MovieListType type) async {
    try {
      await firestoreService.deleteMovie(movie.id, type);
      movies[type]?.removeWhere((item) => item.id == movie.id);
      notifyListeners();
    } on FirestoreException catch (e) {
      error = e.message;
      notifyListeners();
    }
  }
}
