import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieRepository {
  final TmdbService tmdbService;

  MovieRepository(this.tmdbService);

  Future<List<Movie>> getPopular() =>
      tmdbService.getMovies('/movie/popular');

  Future<List<Movie>> getNowPlaying() =>
      tmdbService.getMovies('/movie/now_playing');

  Future<List<Movie>> getTopRated() =>
      tmdbService.getMovies('/movie/top_rated');

  Future<List<Movie>> getUpcoming() =>
      tmdbService.getMovies('/movie/upcoming');

  Future<List<Movie>> getTrending() =>
      tmdbService.getMovies('/trending/movie/day');

  Future<List<Movie>> search(String query) => tmdbService.searchMovies(query);

  Future<Movie> getDetails(int id) => tmdbService.getMovieDetails(id);
}
