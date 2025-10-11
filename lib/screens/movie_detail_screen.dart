import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/tmdb_api_service.dart';
import '../widgets/WorkingNativeAdWidget.dart';
import 'youtube_webview_screen.dart';

// Simple cache for movie details
class MovieDetailCache {
  static final Map<String, Map<String, dynamic>> _cache = {};

  static void set(String movieId, Map<String, dynamic> data) {
    _cache[movieId] = data;
  }

  static Map<String, dynamic>? get(String movieId) {
    return _cache[movieId];
  }

  static void clear() {
    _cache.clear();
  }
}

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movieDetails;
  Map<String, dynamic>? movieCredits;
  Map<String, dynamic>? movieVideos;
  Map<String, dynamic>? movieKeywords;
  Map<String, dynamic>? movieWatchProviders;
  List<dynamic>? similarMovies;
  List<dynamic>? recommendations;
  bool isLoading = true;
  String? error;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isOverviewExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    final movieId = widget.movie.id.toString();

    // Check cache first
    final cachedData = MovieDetailCache.get(movieId);
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          movieDetails = cachedData['details'];
          movieCredits = cachedData['credits'];
          movieVideos = cachedData['videos'];
          movieKeywords = cachedData['keywords'];
          movieWatchProviders = cachedData['watchProviders'];
          similarMovies = cachedData['similarMovies'];
          recommendations = cachedData['recommendations'];
          isLoading = false;
          error = null;
        });
      }
      return;
    }

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load essential data first
      final details = await TMDBAPIService.getMovieDetails(movieId: movieId);

      // Load additional data in parallel, but don't fail if some fail
      final results = await Future.wait([
        TMDBAPIService.getMovieCredits(
          movieId: movieId,
        ).catchError((e) => <String, dynamic>{}),
        TMDBAPIService.getMovieVideos(
          movieId: movieId,
        ).catchError((e) => <String, dynamic>{}),
        TMDBAPIService.getMovieKeywords(
          movieId: movieId,
        ).catchError((e) => <String, dynamic>{}),
        TMDBAPIService.getMovieWatchProviders(
          movieId: movieId,
        ).catchError((e) => <String, dynamic>{}),
        TMDBAPIService.getSimilarMovies(
          movieId: movieId,
        ).catchError((e) => <String, dynamic>{}),
        TMDBAPIService.getMovieRecommendations(
          movieId: movieId,
        ).catchError((e) => <String, dynamic>{}),
      ]);

      if (mounted) {
        final data = {
          'details': details,
          'credits': results[0],
          'videos': results[1],
          'keywords': results[2],
          'watchProviders': results[3],
          'similarMovies': results[4]['results'],
          'recommendations': results[5]['results'],
        };

        // Cache the data
        MovieDetailCache.set(movieId, data);

        setState(() {
          movieDetails = details;
          movieCredits = results[0];
          movieVideos = results[1];
          movieKeywords = results[2];
          movieWatchProviders = results[3];
          similarMovies = results[4]['results'];
          recommendations = results[5]['results'];
          isLoading = false;
          _retryCount = 0; // Reset retry count on success
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = _getErrorMessage(e);
          isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Connection reset by peer')) {
      return 'Network connection was interrupted. Please check your internet connection and try again.';
    } else if (error.toString().contains('SocketException')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Failed to load movie details. Please try again.';
    }
  }

  Future<void> _retryLoad() async {
    if (_retryCount < _maxRetries) {
      setState(() {
        _retryCount++;
      });
      await _loadMovieDetails();
    }
  }

  // Helper method to launch video URL
  Future<void> _launchVideo(String videoUrl) async {
    try {
      if (videoUrl.isEmpty) {
        _showSnackBar('Video URL not available');
        return;
      }

      // Special handling for YouTube URLs
      if (videoUrl.contains('youtube.com')) {
        await _launchYouTubeVideo(videoUrl);
        return;
      }

      final uri = Uri.parse(videoUrl);

      // Try to launch with external application first
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to external browser
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If all else fails, try opening in browser
      try {
        final uri = Uri.parse(videoUrl);
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (fallbackError) {
        _showSnackBar('Could not open video. Please try again.');
        print('Video launch error: $e');
        print('Fallback error: $fallbackError');
      }
    }
  }

  // Special method for YouTube videos - now opens in webview
  Future<void> _launchYouTubeVideo(String videoUrl) async {
    try {
      // Navigate to YouTube webview screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YouTubeWebViewScreen(
            videoUrl: videoUrl,
            videoTitle: widget.movie.title ?? 'Movie Trailer',
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Could not open YouTube video');
      print('YouTube webview error: $e');
    }
  }

  // Helper method to show snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // Helper method to get video thumbnail
  String _getVideoThumbnail(String videoKey, String site) {
    if (site.toLowerCase() == 'youtube') {
      return 'https://img.youtube.com/vi/$videoKey/maxresdefault.jpg';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Connection Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _retryCount < _maxRetries
                              ? _retryLoad
                              : null,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            _retryCount < _maxRetries
                                ? 'Retry'
                                : 'Max Retries Reached',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_retryCount < _maxRetries) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Attempt ${_retryCount + 1}/$_maxRetries',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
            children: [
              Expanded(
                child: CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMovieInfo(),
                              const SizedBox(height: 20),
                              _buildOverview(),
                              const SizedBox(height: 20),
                              _buildKeywords(),
                              const SizedBox(height: 20),
                              _buildWatchProviders(),
                              const SizedBox(height: 20),
                              _buildCast(),
                              const SizedBox(height: 20),
                              _buildVideos(),
                              const SizedBox(height: 20),
                              _buildMovieStats(),
                              const SizedBox(height: 20),
                              _buildSimilarMovies(),
                              const SizedBox(height: 20),
                              _buildRecommendations(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ),

              const WorkingNativeAdWidget(),
            ],
          ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.movie.fullBackdropPath,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.movie, size: 50, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title ?? 'Unknown Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.movie.releaseDate != null)
                        Text(
                          widget.movie.releaseDate!.split('-').first,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      if (widget.movie.voteAverage != null) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.movie.voteAverage!.toStringAsFixed(1)} ⭐',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            final isFavorite = movieProvider.favoriteMovies.any(
              (m) => m.id == widget.movie.id,
            );
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                movieProvider.addToFavorites(widget.movie.id, !isFavorite);
              },
            );
          },
        ),
        Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            final isInWatchlist = movieProvider.watchlistMovies.any(
              (m) => m.id == widget.movie.id,
            );
            return IconButton(
              icon: Icon(
                isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                color: isInWatchlist ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                movieProvider.addToWatchlist(widget.movie.id, !isInWatchlist);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    if (movieDetails == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movieDetails!['genres'] != null)
          Wrap(
            spacing: 8,
            children: (movieDetails!['genres'] as List)
                .map(
                  (genre) => Chip(
                    label: Text(genre['name']),
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 16),
        if (movieDetails!['runtime'] != null)
          Text(
            'Duration: ${movieDetails!['runtime']} minutes',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        if (movieDetails!['budget'] != null && movieDetails!['budget'] > 0)
          Text(
            'Budget: \$${movieDetails!['budget'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        if (movieDetails!['revenue'] != null && movieDetails!['revenue'] > 0)
          Text(
            'Revenue: \$${movieDetails!['revenue'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        if (movieDetails!['status'] != null)
          Text(
            'Status: ${movieDetails!['status']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        if (movieDetails!['original_language'] != null)
          Text(
            'Original Language: ${movieDetails!['original_language'].toString().toUpperCase()}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        if (movieDetails!['production_companies'] != null &&
            (movieDetails!['production_companies'] as List).isNotEmpty)
          Text(
            'Production: ${(movieDetails!['production_companies'] as List).map((company) => company['name']).join(', ')}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildOverview() {
    final overview = widget.movie.overview ?? 'No overview available.';
    final isLongText = overview.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          isLongText && !_isOverviewExpanded
              ? '${overview.substring(0, 200)}...'
              : overview,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        if (isLongText) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isOverviewExpanded = !_isOverviewExpanded;
              });
            },
            child: Text(
              _isOverviewExpanded ? 'Show Less' : 'Show More',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCast() {
    if (movieCredits == null || movieCredits!['cast'] == null) {
      return const SizedBox.shrink();
    }

    final cast = movieCredits!['cast'] as List;
    if (cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final person = cast[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: person['profile_path'] != null
                            ? 'https://image.tmdb.org/t/p/w500${person['profile_path']}'
                            : '',
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      person['name'] ?? '',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideos() {
    if (movieVideos == null || movieVideos!['results'] == null) {
      return const SizedBox.shrink();
    }

    final videos = movieVideos!['results'] as List;
    if (videos.isEmpty) return const SizedBox.shrink();

    // Filter videos by type and site
    final trailerVideos = videos
        .where(
          (video) =>
              video['type'] == 'Trailer' &&
              (video['site'] == 'YouTube' || video['site'] == 'Vimeo'),
        )
        .toList();

    final otherVideos = videos
        .where(
          (video) =>
              video['type'] != 'Trailer' ||
              (video['site'] != 'YouTube' && video['site'] != 'Vimeo'),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Videos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (trailerVideos.isNotEmpty) ...[
          const Text(
            'Trailers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trailerVideos.length,
              itemBuilder: (context, index) {
                final video = trailerVideos[index];
                return _buildVideoCard(video, isTrailer: true);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (otherVideos.isNotEmpty) ...[
          const Text(
            'Other Videos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: otherVideos.length,
              itemBuilder: (context, index) {
                final video = otherVideos[index];
                return _buildVideoCard(video, isTrailer: false);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoCard(
    Map<String, dynamic> video, {
    required bool isTrailer,
  }) {
    final videoKey = video['key'] ?? '';
    final site = video['site'] ?? '';
    final name = video['name'] ?? 'Video';
    final type = video['type'] ?? '';

    String videoUrl = '';
    String thumbnailUrl = '';

    if (site == 'YouTube') {
      videoUrl = 'https://www.youtube.com/watch?v=$videoKey';
      thumbnailUrl = _getVideoThumbnail(videoKey, site);
    } else if (site == 'Vimeo') {
      videoUrl = 'https://vimeo.com/$videoKey';
      // Vimeo doesn't have easy thumbnail access, so we'll use a placeholder
    }

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () => _launchVideo(videoUrl),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    image: thumbnailUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(thumbnailUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image load error
                            },
                          )
                        : null,
                    color: thumbnailUrl.isEmpty ? Colors.grey[300] : null,
                  ),
                  child: Stack(
                    children: [
                      if (thumbnailUrl.isEmpty)
                        const Center(
                          child: Icon(Icons.play_circle_outline, size: 50),
                        ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            site,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getVideoTypeIcon(type),
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to watch',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVideoTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'trailer':
        return Icons.movie;
      case 'teaser':
        return Icons.preview;
      case 'clip':
        return Icons.video_library;
      case 'behind the scenes':
        return Icons.camera_alt;
      case 'featurette':
        return Icons.info;
      default:
        return Icons.play_circle_outline;
    }
  }

  Widget _buildMovieStats() {
    if (movieDetails == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Movie Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Rating',
                      '${movieDetails!['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Vote Count',
                      '${movieDetails!['vote_count']?.toString() ?? 'N/A'}',
                      Icons.how_to_vote,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Popularity',
                      '${movieDetails!['popularity']?.toStringAsFixed(0) ?? 'N/A'}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Runtime',
                      '${movieDetails!['runtime']?.toString() ?? 'N/A'} min',
                      Icons.access_time,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMovies() {
    if (similarMovies == null || similarMovies!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Movies',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarMovies!.length,
            itemBuilder: (context, index) {
              final movie = similarMovies![index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: movie['poster_path'] != null
                                ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                : '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.movie,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie['title'] ?? 'Unknown Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (movie['vote_average'] != null)
                              Text(
                                '${movie['vote_average'].toStringAsFixed(1)} ⭐',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeywords() {
    if (movieKeywords == null || movieKeywords!['keywords'] == null) {
      return const SizedBox.shrink();
    }

    final keywords = movieKeywords!['keywords'] as List;
    if (keywords.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keywords',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.take(10).map((keyword) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                keyword['name'],
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWatchProviders() {
    if (movieWatchProviders == null ||
        movieWatchProviders!['results'] == null) {
      return const SizedBox.shrink();
    }

    final results = movieWatchProviders!['results'] as Map<String, dynamic>;
    if (results.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where to Watch',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Watch provider information is not available for this movie.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Try to get providers from multiple regions
    final List<String> preferredRegions = ['US', 'IN', 'GB', 'CA', 'AU'];
    Map<String, dynamic>? selectedProviders;
    String selectedRegion = '';

    for (String region in preferredRegions) {
      if (results.containsKey(region)) {
        selectedProviders = results[region] as Map<String, dynamic>;
        selectedRegion = region;
        break;
      }
    }

    if (selectedProviders == null || selectedProviders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Where to Watch',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selectedRegion,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedProviders['flatrate'] != null)
          _buildProviderSection('Stream', selectedProviders['flatrate']),
        if (selectedProviders['rent'] != null)
          _buildProviderSection('Rent', selectedProviders['rent']),
        if (selectedProviders['buy'] != null)
          _buildProviderSection('Buy', selectedProviders['buy']),
        if (selectedProviders['ads'] != null)
          _buildProviderSection('Free with Ads', selectedProviders['ads']),
      ],
    );
  }

  Widget _buildProviderSection(String title, List providers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: providers.take(6).map((provider) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getProviderColor(title).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getProviderColor(title).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider['logo_path'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w45${provider['logo_path']}',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[300],
                          child: const Icon(Icons.tv, size: 12),
                        ),
                      ),
                    ),
                  if (provider['logo_path'] != null) const SizedBox(width: 8),
                  Text(
                    provider['provider_name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getProviderColor(title),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Color _getProviderColor(String title) {
    switch (title.toLowerCase()) {
      case 'stream':
        return Colors.green;
      case 'rent':
        return Colors.orange;
      case 'buy':
        return Colors.blue;
      case 'free with ads':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecommendations() {
    if (recommendations == null || recommendations!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations!.length,
            itemBuilder: (context, index) {
              final movie = recommendations![index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: movie['poster_path'] != null
                                ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                : '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.movie,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie['title'] ?? 'Unknown Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (movie['vote_average'] != null)
                              Text(
                                '${movie['vote_average'].toStringAsFixed(1)} ⭐',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
