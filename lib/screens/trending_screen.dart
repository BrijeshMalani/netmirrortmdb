import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/ad_manager.dart';
import '../services/tmdb_api_service.dart';
import '../widgets/WorkingNativeAdWidget.dart';
import 'movie_detail_screen.dart';
import 'tv_detail_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  List<dynamic> trendingItems = [];
  bool isLoading = true;
  String? error;
  String selectedTimeWindow = 'day';

  @override
  void initState() {
    super.initState();
    _loadTrendingContent();
  }

  Future<void> _loadTrendingContent() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await TMDBAPIService.getTrendingAll(
        timeWindow: selectedTimeWindow,
      );

      if (mounted) {
        setState(() {
          trendingItems = response['results'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _onTimeWindowChanged(String? value) {
    if (value != null && value != selectedTimeWindow) {
      setState(() {
        selectedTimeWindow = value;
      });
      _loadTrendingContent();
    }
  }

  String _getMediaType(dynamic item) {
    return item['media_type'] ?? 'unknown';
  }

  String _getTitle(dynamic item) {
    return item['title'] ?? item['name'] ?? 'Unknown Title';
  }

  String _getReleaseDate(dynamic item) {
    return item['release_date'] ?? item['first_air_date'] ?? '';
  }

  String _getPosterPath(dynamic item) {
    return item['poster_path'] ?? '';
  }

  double _getVoteAverage(dynamic item) {
    return (item['vote_average'] ?? 0.0).toDouble();
  }

  String _getOverview(dynamic item) {
    return item['overview'] ?? '';
  }

  void _navigateToDetail(dynamic item) {
    final mediaType = _getMediaType(item);

    if (mediaType == 'movie') {
      final movie = Movie(
        id: item['id'],
        title: item['title'] ?? '',
        overview: item['overview'] ?? '',
        posterPath: item['poster_path'] ?? '',
        backdropPath: item['backdrop_path'] ?? '',
        releaseDate: item['release_date'] ?? '',
        voteAverage: (item['vote_average'] ?? 0.0).toDouble(),
        adult: item['adult'] ?? false,
        genreIds: List<int>.from(item['genre_ids'] ?? []),
        originalLanguage: item['original_language'] ?? '',
        originalTitle: item['original_title'] ?? '',
        popularity: (item['popularity'] ?? 0.0).toDouble(),
        video: item['video'] ?? false,
        voteCount: item['vote_count'] ?? 0,
      );

      AdManager().showInterstitialAd();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailScreen(movie: movie),
        ),
      );
    } else if (mediaType == 'tv') {
      final tvShow = TVShow(
        id: item['id'],
        name: item['name'] ?? '',
        overview: item['overview'] ?? '',
        posterPath: item['poster_path'] ?? '',
        backdropPath: item['backdrop_path'] ?? '',
        firstAirDate: item['first_air_date'] ?? '',
        voteAverage: (item['vote_average'] ?? 0.0).toDouble(),
        genreIds: List<int>.from(item['genre_ids'] ?? []),
        originCountry: List<String>.from(item['origin_country'] ?? []),
        originalLanguage: item['original_language'] ?? '',
        originalName: item['original_name'] ?? '',
        popularity: (item['popularity'] ?? 0.0).toDouble(),
        voteCount: item['vote_count'] ?? 0,
      );

      AdManager().showInterstitialAd();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TVDetailScreen(tvShow: tvShow)),
      );
    } else if (mediaType == 'person') {
      // For people, we could show a person detail screen or just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Person: ${item['name'] ?? 'Unknown'}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _onTimeWindowChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'day', child: Text('Today')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingShimmer()
          : error != null
          ? _buildErrorWidget()
          : _buildTrendingContent(),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTrendingContent,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingContent() {
    if (trendingItems.isEmpty) {
      return const Center(child: Text('No trending content found'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trendingItems.length,
            itemBuilder: (context, index) {
              final item = trendingItems[index];
              final mediaType = _getMediaType(item);

              return _buildTrendingItem(item, mediaType);
            },
          ),
        ),

        const WorkingNativeAdWidget(),
      ],
    );
  }

  Widget _buildTrendingItem(dynamic item, String mediaType) {
    final title = _getTitle(item);
    final releaseDate = _getReleaseDate(item);
    final posterPath = _getPosterPath(item);
    final voteAverage = _getVoteAverage(item);
    final overview = _getOverview(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: posterPath.isNotEmpty
                      ? 'https://image.tmdb.org/t/p/w500$posterPath'
                      : 'https://via.placeholder.com/150x200?text=No+Image',
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getMediaTypeColor(mediaType),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getMediaTypeLabel(mediaType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Release date
                    if (releaseDate.isNotEmpty)
                      Text(
                        _formatDate(releaseDate),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Overview
                    Expanded(
                      child: Text(
                        overview,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Color _getMediaTypeColor(String mediaType) {
    switch (mediaType) {
      case 'movie':
        return Colors.blue;
      case 'tv':
        return Colors.green;
      case 'person':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMediaTypeLabel(String mediaType) {
    switch (mediaType) {
      case 'movie':
        return 'MOVIE';
      case 'tv':
        return 'TV SHOW';
      case 'person':
        return 'PERSON';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
