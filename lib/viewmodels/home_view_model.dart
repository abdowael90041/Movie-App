import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/tmdb_service.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieRepository repository;

  HomeViewModel(this.repository);

  bool isLoading = false;
  String? error;

  List<Movie> popular = [];
  List<Movie> nowPlaying = [];
  List<Movie> topRated = [];
  List<Movie> upcoming = [];
  List<Movie> trending = [];

  Future<void> loadHome() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getTrending(),
        repository.getPopular(),
        repository.getNowPlaying(),
        repository.getTopRated(),
        repository.getUpcoming(),
      ]);

      trending = results[0];
      popular = results[1];
      nowPlaying = results[2];
      topRated = results[3];
      upcoming = results[4];
    } on TmdbException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Something went wrong while loading movies.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
