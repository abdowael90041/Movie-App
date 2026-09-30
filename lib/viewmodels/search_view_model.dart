import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/tmdb_service.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository repository;

  SearchViewModel(this.repository);

  Timer? _debounce;
  bool isLoading = false;
  String? error;
  List<Movie> results = [];
  String query = '';

  void onQueryChanged(String value) {
    query = value.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      results = [];
      error = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      search(query);
    });
  }

  Future<void> search(String value) async {
    if (value.trim().isEmpty) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      results = await repository.search(value.trim());
    } on TmdbException catch (e) {
      error = e.message;
      results = [];
    } catch (_) {
      error = 'Something went wrong while searching.';
      results = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
