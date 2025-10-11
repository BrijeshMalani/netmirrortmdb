import 'package:flutter/foundation.dart';
import '../models/tv_show.dart';
import '../models/api_response.dart';
import '../services/tmdb_api_service.dart';

class TVProvider with ChangeNotifier {
  List<TVShow> _trendingTV = [];
  List<TVShow> _popularTV = [];
  List<TVShow> _topRatedTV = [];
  List<TVShow> _airingTodayTV = [];
  List<TVShow> _onTheAirTV = [];
  List<TVShow> _searchResults = [];
  List<TVShow> _favoriteTV = [];
  List<TVShow> _watchlistTV = [];
  List<TVShow> _ratedTV = [];
  List<TVShow> _discoveredTV = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<TVShow> get trendingTV => _trendingTV;
  List<TVShow> get popularTV => _popularTV;
  List<TVShow> get topRatedTV => _topRatedTV;
  List<TVShow> get airingTodayTV => _airingTodayTV;
  List<TVShow> get onTheAirTV => _onTheAirTV;
  List<TVShow> get searchResults => _searchResults;
  List<TVShow> get favoriteTV => _favoriteTV;
  List<TVShow> get watchlistTV => _watchlistTV;
  List<TVShow> get ratedTV => _ratedTV;
  List<TVShow> get discoveredTV => _discoveredTV;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  Future<void> loadTrendingTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getTrendingTV();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _trendingTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPopularTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getTVPopular();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _popularTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTopRatedTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getTVTopRated();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _topRatedTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAiringTodayTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getTVAiringToday();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _airingTodayTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOnTheAirTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getTVOnTheAir();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _onTheAirTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchTV(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final response = await TMDBAPIService.searchTV(query: query);
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _searchResults = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFavoriteTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getFavoriteTV();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _favoriteTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWatchlistTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getWatchlistTV();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _watchlistTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRatedTV() async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.getRatedTV();
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _ratedTV = apiResponse.results;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToFavorites(int tvId, bool favorite) async {
    try {
      await TMDBAPIService.addToFavorites(
        mediaId: tvId,
        mediaType: 'tv',
        favorite: favorite,
      );
      if (favorite) {
        // Add to local favorites if not already present
        if (!_favoriteTV.any((tv) => tv.id == tvId)) {
          final tv = _trendingTV.firstWhere((t) => t.id == tvId);
          _favoriteTV.add(tv);
        }
      } else {
        // Remove from local favorites
        _favoriteTV.removeWhere((tv) => tv.id == tvId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addToWatchlist(int tvId, bool watchlist) async {
    try {
      await TMDBAPIService.addToWatchlist(
        mediaId: tvId,
        mediaType: 'tv',
        watchlist: watchlist,
      );
      if (watchlist) {
        // Add to local watchlist if not already present
        if (!_watchlistTV.any((tv) => tv.id == tvId)) {
          final tv = _trendingTV.firstWhere((t) => t.id == tvId);
          _watchlistTV.add(tv);
        }
      } else {
        // Remove from local watchlist
        _watchlistTV.removeWhere((tv) => tv.id == tvId);
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

  Future<void> discoverTV({String? genre, String? sortBy, String? year}) async {
    _setLoading(true);
    try {
      final response = await TMDBAPIService.discoverTV(
        includeAdult: false,
        includeNullFirstAirDates: false,
        language: 'en-US',
        page: 1,
        sortBy: sortBy ?? 'popularity.desc',
      );
      final apiResponse = ApiResponse.fromJson(
        response,
        (json) => TVShow.fromJson(json),
      );
      _discoveredTV = apiResponse.results;
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
