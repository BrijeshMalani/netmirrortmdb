import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TMDBAPIService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '9ec474f68acd812a132e3cd089fbb4ca';
  static const String bearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ZWM0NzRmNjhhY2Q4MTJhMTMyZTNjZDA4OWZiYjRjYSIsIm5iZiI6MTc1OTU1NTI5Ni45OTEwMDAyLCJzdWIiOiI2OGUwYWVlMGVhNjg4NjgyZWIyNWE4NTYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.mZMV3flPh5OSawbPOyEUS62rW3nQWOEZOBBkT_BYeBc';
  static const String accountId = '22358118';

  static Map<String, String> get _headers => {
    'accept': 'application/json',
    'Authorization': 'Bearer $bearerToken',
  };

  static Map<String, String> get _postHeaders => {
    'accept': 'application/json',
    'content-type': 'application/json',
    'Authorization': 'Bearer $bearerToken',
  };

  // Helper method for making HTTP requests with retry logic
  static Future<Map<String, dynamic>> _makeRequestWithRetry(
    Future<http.Response> Function() request, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        final response = await request();

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 429) {
          // Rate limit - wait longer before retry
          await Future.delayed(Duration(seconds: 2 * (attempts + 1)));
          attempts++;
          continue;
        } else {
          throw HttpException('HTTP ${response.statusCode}: ${response.body}');
        }
      } on SocketException catch (e) {
        lastException = e;
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(delay * attempts);
        }
      } on HttpException catch (e) {
        lastException = e;
        attempts++;
        if (attempts < maxRetries) {
          await Future.delayed(delay * attempts);
        }
      } catch (e) {
        throw Exception('Unexpected error: $e');
      }
    }

    throw lastException ?? Exception('Failed after $maxRetries attempts');
  }

  // Guest Session APIs
  static Future<Map<String, dynamic>> createGuestSession() async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/authentication/guest_session/new'),
        headers: _headers,
      ),
    );
  }

  // Account APIs
  static Future<Map<String, dynamic>> getAccountDetails() async {
    final response = await http.get(
      Uri.parse('$baseUrl/account/$accountId'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addToFavorites({
    required int mediaId,
    required String mediaType,
    required bool favorite,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/account/$accountId/favorite'),
      headers: _postHeaders,
      body: json.encode({
        'media_type': mediaType,
        'media_id': mediaId,
        'favorite': favorite,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addToWatchlist({
    required int mediaId,
    required String mediaType,
    required bool watchlist,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/account/$accountId/watchlist'),
      headers: _postHeaders,
      body: json.encode({
        'media_type': mediaType,
        'media_id': mediaId,
        'watchlist': watchlist,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getFavoriteMovies({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/favorite/movies?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getFavoriteTV({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/favorite/tv?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getLists({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/account/$accountId/lists?page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getRatedMovies({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/rated/movies?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getRatedTV({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/rated/tv?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getRatedTVEpisodes({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/rated/tv/episodes?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getWatchlistMovies({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/watchlist/movies?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getWatchlistTV({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'created_at.asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/watchlist/tv?language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Certification APIs
  static Future<Map<String, dynamic>> getMovieCertifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/certification/movie/list'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVCertifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/certification/tv/list'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Collection APIs
  static Future<Map<String, dynamic>> getCollectionDetails({
    required String collectionId,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/collection/$collectionId?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getCollectionImages({
    required String collectionId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/collection/$collectionId/images'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getCollectionTranslations({
    required String collectionId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/collection/$collectionId/translations'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Discover APIs
  static Future<Map<String, dynamic>> discoverMovies({
    bool includeAdult = false,
    bool includeVideo = false,
    String language = 'en-US',
    int page = 1,
    String sortBy = 'popularity.desc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/discover/movie?include_adult=$includeAdult&include_video=$includeVideo&language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> discoverTV({
    bool includeAdult = false,
    bool includeNullFirstAirDates = false,
    String language = 'en-US',
    int page = 1,
    String sortBy = 'popularity.desc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/discover/tv?include_adult=$includeAdult&include_null_first_air_dates=$includeNullFirstAirDates&language=$language&page=$page&sort_by=$sortBy',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Genre APIs
  static Future<Map<String, dynamic>> getMovieGenres({
    String language = 'en',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/genre/movie/list?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVGenres({
    String language = 'en',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/genre/tv/list?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Search APIs
  static Future<Map<String, dynamic>> searchCollection({
    bool includeAdult = false,
    String language = 'en-US',
    int page = 1,
    String? query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/search/collection?include_adult=$includeAdult&language=$language&page=$page',
    );
    final response = await http.get(
      query != null
          ? uri.replace(
              queryParameters: {...uri.queryParameters, 'query': query},
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> searchCompany({
    int page = 1,
    String? query,
  }) async {
    final uri = Uri.parse('$baseUrl/search/company?page=$page');
    final response = await http.get(
      query != null
          ? uri.replace(
              queryParameters: {...uri.queryParameters, 'query': query},
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> searchMovies({
    bool includeAdult = false,
    String language = 'en-US',
    int page = 1,
    String? query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/search/movie?include_adult=$includeAdult&language=$language&page=$page',
    );
    final response = await http.get(
      query != null
          ? uri.replace(
              queryParameters: {...uri.queryParameters, 'query': query},
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> searchTV({
    bool includeAdult = false,
    String language = 'en-US',
    int page = 1,
    String? query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/search/tv?include_adult=$includeAdult&language=$language&page=$page',
    );
    final response = await http.get(
      query != null
          ? uri.replace(
              queryParameters: {...uri.queryParameters, 'query': query},
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Trending APIs
  static Future<Map<String, dynamic>> getTrendingAll({
    String timeWindow = 'day',
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/trending/all/$timeWindow?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTrendingMovies({
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/day?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTrendingPeople({
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/person/day?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTrendingTV({
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/tv/day?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // TV APIs
  static Future<Map<String, dynamic>> getTVAiringToday({
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/airing_today?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVOnTheAir({
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/on_the_air?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVPopular({
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/popular?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVTopRated({
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/top_rated?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // TV Series Details APIs
  static Future<Map<String, dynamic>> getTVSeriesDetails({
    required String seriesId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/tv/$seriesId?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVSeriesAccountStates({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/account_states'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesAggregateCredits({
    required String seriesId,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/aggregate_credits?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesAlternativeTitles({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/alternative_titles'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesChanges({
    required String seriesId,
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/changes?page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesContentRatings({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/content_ratings'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesCredits({
    required String seriesId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/tv/$seriesId/credits?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVSeriesEpisodeGroups({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/episode_groups'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesExternalIds({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/external_ids'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesImages({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/images'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesKeywords({
    required String seriesId,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/tv/$seriesId/keywords'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVLatest() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/latest'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesLists({
    required String seriesId,
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/lists?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesRecommendations({
    required String seriesId,
    String language = 'en-US',
    int page = 1,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse(
          '$baseUrl/tv/$seriesId/recommendations?language=$language&page=$page',
        ),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVSeriesReviews({
    required String seriesId,
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/reviews?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesScreenedTheatrically({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/screened_theatrically'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesSimilar({
    required String seriesId,
    String language = 'en-US',
    int page = 1,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse(
          '$baseUrl/tv/$seriesId/similar?language=$language&page=$page',
        ),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVSeriesTranslations({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/translations'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeriesVideos({
    required String seriesId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/tv/$seriesId/videos?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVSeriesWatchProviders({
    required String seriesId,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/tv/$seriesId/watch/providers'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> addTVSeriesRating({
    required String seriesId,
    required double value,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tv/$seriesId/rating'),
      headers: _postHeaders,
      body: json.encode({'value': value}),
    );
    return json.decode(response.body);
  }

  // TV Season APIs
  static Future<Map<String, dynamic>> getTVSeasonDetails({
    required String seriesId,
    required String seasonNumber,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/tv/$seriesId/season/$seasonNumber?language=$language',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVSeasonVideos({
    required String seriesId,
    required String seasonNumber,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/tv/$seriesId/season/$seasonNumber/videos?language=$language',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // TV Episode APIs
  static Future<Map<String, dynamic>> getTVEpisodeChanges({
    required String episodeId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/episode/$episodeId/changes'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVEpisodeCredits({
    required String seriesId,
    required String seasonNumber,
    required String episodeNumber,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/tv/$seriesId/season/$seasonNumber/episode/$episodeNumber/credits?language=$language',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVEpisodeExternalIds({
    required String seriesId,
    required String seasonNumber,
    required String episodeNumber,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/tv/$seriesId/season/$seasonNumber/episode/$episodeNumber/external_ids',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVEpisodeImages({
    required String seriesId,
    required String seasonNumber,
    required String episodeNumber,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/tv/$seriesId/season/$seasonNumber/episode/$episodeNumber/images',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVEpisodeVideos({
    required String seriesId,
    required String seasonNumber,
    required String episodeNumber,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/tv/$seriesId/season/$seasonNumber/episode/$episodeNumber/videos?language=$language',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // TV Episode Groups APIs
  static Future<Map<String, dynamic>> getTVEpisodeGroupDetails({
    required String tvEpisodeGroupId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/episode_group/$tvEpisodeGroupId'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Movie APIs
  static Future<Map<String, dynamic>> getAllMovies({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'popularity.desc',
    bool includeAdult = false,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse(
          '$baseUrl/discover/movie?page=$page&language=$language&sort_by=$sortBy&include_adult=$includeAdult',
        ),
        headers: _headers,
      ),
    );
  }

  // Series APIs
  static Future<Map<String, dynamic>> getAllSeries({
    int page = 1,
    String language = 'en-US',
    String sortBy = 'popularity.desc',
    bool includeAdult = false,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse(
          '$baseUrl/discover/tv?page=$page&language=$language&sort_by=$sortBy&include_adult=$includeAdult',
        ),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getMovieDetails({
    required String movieId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/movie/$movieId?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getMovieCredits({
    required String movieId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/movie/$movieId/credits?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getMovieVideos({
    required String movieId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getSimilarMovies({
    required String movieId,
    String language = 'en-US',
    int page = 1,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse(
          '$baseUrl/movie/$movieId/similar?language=$language&page=$page',
        ),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getMovieImages({
    required String movieId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/images'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getMovieReviews({
    required String movieId,
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/movie/$movieId/reviews?language=$language&page=$page',
      ),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getMovieRecommendations({
    required String movieId,
    String language = 'en-US',
    int page = 1,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse(
          '$baseUrl/movie/$movieId/recommendations?language=$language&page=$page',
        ),
        headers: _headers,
      ),
    );
  }

  // Watch Provider APIs
  static Future<Map<String, dynamic>> getAvailableRegions({
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/watch/providers/regions?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getMovieProviders({
    String language = 'en-US',
    String? watchRegion,
  }) async {
    final uri = Uri.parse('$baseUrl/watch/providers/movie?language=$language');
    final response = await http.get(
      watchRegion != null
          ? uri.replace(
              queryParameters: {
                ...uri.queryParameters,
                'watch_region': watchRegion,
              },
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVProviders({
    String language = 'en-US',
    String? watchRegion,
  }) async {
    final uri = Uri.parse('$baseUrl/watch/providers/tv?language=$language');
    final response = await http.get(
      watchRegion != null
          ? uri.replace(
              queryParameters: {
                ...uri.queryParameters,
                'watch_region': watchRegion,
              },
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getMovieWatchProviders({
    required String movieId,
    String language = 'en-US',
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/movie/$movieId/watch/providers?language=$language'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getTVWatchProviders({
    required String seriesId,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/watch/providers?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Additional Movie APIs for better details
  static Future<Map<String, dynamic>> getMovieAlternativeTitles({
    required String movieId,
    String? country,
  }) async {
    final uri = Uri.parse('$baseUrl/movie/$movieId/alternative_titles');
    final response = await http.get(
      country != null
          ? uri.replace(
              queryParameters: {...uri.queryParameters, 'country': country},
            )
          : uri,
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getMovieKeywords({
    required String movieId,
  }) async {
    return await _makeRequestWithRetry(
      () => http.get(
        Uri.parse('$baseUrl/movie/$movieId/keywords'),
        headers: _headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> getMovieReleaseDates({
    required String movieId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/release_dates'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Additional TV APIs for better details
  static Future<Map<String, dynamic>> getTVAlternativeTitles({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/alternative_titles'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVKeywords({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/keywords'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVContentRatings({
    required String seriesId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/content_ratings'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Rating APIs
  static Future<Map<String, dynamic>> addMovieRating({
    required String movieId,
    required double rating,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/movie/$movieId/rating'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: json.encode({'value': rating}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addTVRating({
    required String seriesId,
    required double rating,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tv/$seriesId/rating'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: json.encode({'value': rating}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteMovieRating({
    required String movieId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/movie/$movieId/rating'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTVRating({
    required String seriesId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tv/$seriesId/rating'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTVReviews({
    required String seriesId,
    String language = 'en-US',
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$seriesId/reviews?language=$language&page=$page'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  // Person APIs
  static Future<Map<String, dynamic>> getPersonDetails({
    required String personId,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/person/$personId?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getPersonMovieCredits({
    required String personId,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/person/$personId/movie_credits?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getPersonTVCredits({
    required String personId,
    String language = 'en-US',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/person/$personId/tv_credits?language=$language'),
      headers: _headers,
    );
    return json.decode(response.body);
  }
}
