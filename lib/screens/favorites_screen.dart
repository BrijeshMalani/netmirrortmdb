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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TVProvider>(context, listen: false);

    await Future.wait([
      movieProvider.loadFavoriteMovies(),
      tvProvider.loadFavoriteTV(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
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
        children: [_buildFavoriteMovies(), _buildFavoriteTV()],
      ),
    );
  }

  Widget _buildFavoriteMovies() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading && movieProvider.favoriteMovies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (movieProvider.favoriteMovies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No favorite movies yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any movie to add it to favorites',
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
                onRefresh: () => movieProvider.loadFavoriteMovies(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: movieProvider.favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.favoriteMovies[index];
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
                        movieProvider.addToFavorites(movie.id, false);
                      },
                      onWatchlist: () {
                        movieProvider.addToWatchlist(
                          movie.id,
                          !movieProvider.watchlistMovies.any((m) => m.id == movie.id),
                        );
                      },
                      isFavorite: true,
                      isInWatchlist: movieProvider.watchlistMovies.any(
                        (m) => m.id == movie.id,
                      ),
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

  Widget _buildFavoriteTV() {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        if (tvProvider.isLoading && tvProvider.favoriteTV.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tvProvider.favoriteTV.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No favorite TV shows yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any TV show to add it to favorites',
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
                onRefresh: () => tvProvider.loadFavoriteTV(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: tvProvider.favoriteTV.length,
                  itemBuilder: (context, index) {
                    final tvShow = tvProvider.favoriteTV[index];
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
                        tvProvider.addToFavorites(tvShow.id, false);
                      },
                      onWatchlist: () {
                        tvProvider.addToWatchlist(
                          tvShow.id,
                          !tvProvider.watchlistTV.any((t) => t.id == tvShow.id),
                        );
                      },
                      isFavorite: true,
                      isInWatchlist: tvProvider.watchlistTV.any(
                        (t) => t.id == tvShow.id,
                      ),
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
