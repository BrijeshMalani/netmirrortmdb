import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/tv_provider.dart';
import '../services/ad_manager.dart';
import '../widgets/WorkingNativeAdWidget.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_card.dart';
import 'movie_detail_screen.dart';
import 'tv_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWatchlist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWatchlist() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TVProvider>(context, listen: false);

    await Future.wait([
      movieProvider.loadWatchlistMovies(),
      tvProvider.loadWatchlistTV(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.movie), text: 'Movies'),
            Tab(icon: Icon(Icons.tv), text: 'TV Shows'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWatchlistMovies(), _buildWatchlistTV()],
      ),
    );
  }

  Widget _buildWatchlistMovies() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading && movieProvider.watchlistMovies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (movieProvider.watchlistMovies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No movies in watchlist yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the bookmark icon on any movie to add it to your watchlist',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => movieProvider.loadWatchlistMovies(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: movieProvider.watchlistMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.watchlistMovies[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () {
                        AdManager().showInterstitialAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      onFavorite: () {
                        movieProvider.addToFavorites(
                          movie.id,
                          !movieProvider.favoriteMovies.any((m) => m.id == movie.id),
                        );
                      },
                      onWatchlist: () {
                        movieProvider.addToWatchlist(movie.id, false);
                      },
                      isFavorite: movieProvider.favoriteMovies.any(
                        (m) => m.id == movie.id,
                      ),
                      isInWatchlist: true,
                    );
                  },
                ),
              ),
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }

  Widget _buildWatchlistTV() {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        if (tvProvider.isLoading && tvProvider.watchlistTV.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tvProvider.watchlistTV.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No TV shows in watchlist yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the bookmark icon on any TV show to add it to your watchlist',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => tvProvider.loadWatchlistTV(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: tvProvider.watchlistTV.length,
                  itemBuilder: (context, index) {
                    final tvShow = tvProvider.watchlistTV[index];
                    return TVCard(
                      tvShow: tvShow,
                      onTap: () {
                        AdManager().showInterstitialAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TVDetailScreen(tvShow: tvShow),
                          ),
                        );
                      },
                      onFavorite: () {
                        tvProvider.addToFavorites(
                          tvShow.id,
                          !tvProvider.favoriteTV.any((t) => t.id == tvShow.id),
                        );
                      },
                      onWatchlist: () {
                        tvProvider.addToWatchlist(tvShow.id, false);
                      },
                      isFavorite: tvProvider.favoriteTV.any((t) => t.id == tvShow.id),
                      isInWatchlist: true,
                    );
                  },
                ),
              ),
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }
}
