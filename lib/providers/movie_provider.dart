import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/api_response.dart';
import '../services/tmdb_api_service.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _favoriteMovies = [];
  List<Movie> _watchlistMovies = [];
  List<Movie> _ratedMovies = [];
  List<Movie> _discoveredMovies = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get favoriteMovies => _favoriteMovies;
  List<Movie> get watchlistMovies => _watchlistMovies;
  List<Movie> get ratedMovies => _ratedMovies;
  List<Movie> get discoveredMovies => _discoveredMovies;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  Future<void> loadTrendingMovies() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getTrendingMovies();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _trendingMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPopularMovies() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.discoverMovies();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _popularMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTopRatedMovies() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.discoverMovies(
        sortBy: 'vote_average.desc',
      );
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _topRatedMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final response = await TMDBAPIService.searchMovies(query: query);
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _searchResults = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFavoriteMovies() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getFavoriteMovies();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _favoriteMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWatchlistMovies() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getWatchlistMovies();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _watchlistMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRatedMovies() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getRatedMovies();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _ratedMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToFavorites(int movieId, bool favorite) async {
    try {
      await TMDBAPIService.addToFavorites(
        mediaId: movieId,
        mediaType: 'movie',
        favorite: favorite,
      );
      if (favorite) {
        // Add to local favorites if not already present
        if (!_favoriteMovies.any((movie) => movie.id == movieId)) {
          final movie = _trendingMovies.firstWhere((m) => m.id == movieId);
          _favoriteMovies.add(movie);
        }
      } else {
        // Remove from local favorites
        _favoriteMovies.removeWhere((movie) => movie.id == movieId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToWatchlist(int movieId, bool watchlist) async {
    try {
      await TMDBAPIService.addToWatchlist(
        mediaId: movieId,
        mediaType: 'movie',
        watchlist: watchlist,
      );
      if (watchlist) {
        // Add to local watchlist if not already present
        if (!_watchlistMovies.any((movie) => movie.id == movieId)) {
          final movie = _trendingMovies.firstWhere((m) => m.id == movieId);
          _watchlistMovies.add(movie);
        }
      } else {
        // Remove from local watchlist
        _watchlistMovies.removeWhere((movie) => movie.id == movieId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> discoverMovies({
    String? genre,
    String? sortBy,
    String? year,
  }) async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.discoverMovies(
        includeAdult: false,
        includeVideo: false,
        language: 'en-US',
        page: 1,
        sortBy: sortBy ?? 'popularity.desc',
      );
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => Movie.fromJson(json),
      );
      _discoveredMovies = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
