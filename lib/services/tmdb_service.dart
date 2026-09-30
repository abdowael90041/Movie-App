import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/env.dart';
import '../core/constants/app_constants.dart';
import '../models/movie.dart';

class TmdbException implements Exception {
  final String message;

  const TmdbException(this.message);

  @override
  String toString() => message;
}

class TmdbService {
  final http.Client client;

  TmdbService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Movie>> getMovies(String endpoint) async {
    _validateApiKey();

    final uri = Uri.parse(
      '${AppConstants.tmdbBaseUrl}$endpoint',
    ).replace(queryParameters: {
      'api_key': Env.tmdbApiKey,
      'language': 'en-US',
      'page': '1',
    });

    return _sendRequest(uri);
  }

  Future<List<Movie>> searchMovies(String query) async {
    _validateApiKey();

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/search/movie')
        .replace(queryParameters: {
      'api_key': Env.tmdbApiKey,
      'language': 'en-US',
      'page': '1',
      'query': query,
      'include_adult': 'false',
    });

    return _sendRequest(uri);
  }

  Future<Movie> getMovieDetails(int movieId) async {
    _validateApiKey();

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$movieId')
        .replace(queryParameters: {
      'api_key': Env.tmdbApiKey,
      'language': 'en-US',
    });

    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) {
        throw TmdbException('TMDB request failed (${response.statusCode}).');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Movie.fromJson(json);
    } on FormatException {
      throw const TmdbException('TMDB returned an invalid response.');
    } catch (error) {
      if (error is TmdbException) rethrow;
      throw TmdbException('Network error while loading movie details.');
    }
  }

  Future<List<Movie>> _sendRequest(Uri uri) async {
    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw TmdbException('TMDB request failed (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['results'] is! List) {
        throw const TmdbException('TMDB returned an invalid response.');
      }

      final results = decoded['results'] as List<dynamic>;
      return results
          .whereType<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .toList();
    } on FormatException {
      throw const TmdbException('TMDB returned invalid JSON.');
    } catch (error) {
      if (error is TmdbException) rethrow;
      throw const TmdbException(
        'Network error. Check your internet connection.',
      );
    }
  }

  void _validateApiKey() {
    if (!Env.hasTmdbApiKey) {
      throw const TmdbException(
        'TMDB API key is missing. Run the app with --dart-define=TMDB_API_KEY=YOUR_KEY.',
      );
    }
  }

  void dispose() {
    client.close();
  }
}
