import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/tv_provider.dart';
import '../services/ad_manager.dart';
import '../widgets/WorkingNativeAdWidget.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_card.dart';
import '../widgets/loading_shimmer.dart';
import 'movie_detail_screen.dart';
import 'tv_detail_screen.dart';
import 'favorites_screen.dart';
import 'watchlist_screen.dart';
import 'search_screen.dart';
import 'trending_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TVProvider>(context, listen: false);

    movieProvider.loadTrendingMovies();
    movieProvider.loadPopularMovies();
    tvProvider.loadTrendingTV();
    tvProvider.loadPopularTV();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NetMirror'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_up),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrendingScreen()),
              );
            },
            tooltip: 'Trending All',
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WatchlistScreen(),
                ),
              );
            },
            tooltip: 'Watchlist',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrendingMovies(),
              const SizedBox(height: 20),
              _buildTrendingTV(),
              const SizedBox(height: 20),
              _buildPopularMovies(),
              const SizedBox(height: 20),
              _buildPopularTV(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingMovies() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Trending Movies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (movieProvider.isLoading && movieProvider.trendingMovies.isEmpty)
              const LoadingShimmer(itemCount: 4, isGrid: false)
            else
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movieProvider.trendingMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.trendingMovies[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: MovieCard(
                        movie: movie,
                        onTap: () {
                          AdManager().showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                        onFavorite: () {
                          movieProvider.addToFavorites(
                            movie.id,
                            !movieProvider.favoriteMovies.any(
                              (m) => m.id == movie.id,
                            ),
                          );
                        },
                        onWatchlist: () {
                          movieProvider.addToWatchlist(
                            movie.id,
                            !movieProvider.watchlistMovies.any(
                              (m) => m.id == movie.id,
                            ),
                          );
                        },
                        isFavorite: movieProvider.favoriteMovies.any(
                          (m) => m.id == movie.id,
                        ),
                        isInWatchlist: movieProvider.watchlistMovies.any(
                          (m) => m.id == movie.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingTV() {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Trending TV Shows',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (tvProvider.isLoading && tvProvider.trendingTV.isEmpty)
              const LoadingShimmer(itemCount: 4, isGrid: false)
            else
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tvProvider.trendingTV.length,
                  itemBuilder: (context, index) {
                    final tvShow = tvProvider.trendingTV[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: TVCard(
                        tvShow: tvShow,
                        onTap: () {
                          AdManager().showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TVDetailScreen(tvShow: tvShow),
                            ),
                          );
                        },
                        onFavorite: () {
                          tvProvider.addToFavorites(
                            tvShow.id,
                            !tvProvider.favoriteTV.any(
                              (t) => t.id == tvShow.id,
                            ),
                          );
                        },
                        onWatchlist: () {
                          tvProvider.addToWatchlist(
                            tvShow.id,
                            !tvProvider.watchlistTV.any(
                              (t) => t.id == tvShow.id,
                            ),
                          );
                        },
                        isFavorite: tvProvider.favoriteTV.any(
                          (t) => t.id == tvShow.id,
                        ),
                        isInWatchlist: tvProvider.watchlistTV.any(
                          (t) => t.id == tvShow.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPopularMovies() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popular Movies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (movieProvider.isLoading && movieProvider.popularMovies.isEmpty)
              const LoadingShimmer(itemCount: 4, isGrid: false)
            else
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movieProvider.popularMovies.length,
                  itemBuilder: (context, index) {
                    final movie = movieProvider.popularMovies[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: MovieCard(
                        movie: movie,
                        onTap: () {
                          AdManager().showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                        onFavorite: () {
                          movieProvider.addToFavorites(
                            movie.id,
                            !movieProvider.favoriteMovies.any(
                              (m) => m.id == movie.id,
                            ),
                          );
                        },
                        onWatchlist: () {
                          movieProvider.addToWatchlist(
                            movie.id,
                            !movieProvider.watchlistMovies.any(
                              (m) => m.id == movie.id,
                            ),
                          );
                        },
                        isFavorite: movieProvider.favoriteMovies.any(
                          (m) => m.id == movie.id,
                        ),
                        isInWatchlist: movieProvider.watchlistMovies.any(
                          (m) => m.id == movie.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPopularTV() {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popular TV Shows',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (tvProvider.isLoading && tvProvider.popularTV.isEmpty)
              const LoadingShimmer(itemCount: 4, isGrid: false)
            else
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tvProvider.popularTV.length,
                  itemBuilder: (context, index) {
                    final tvShow = tvProvider.popularTV[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: TVCard(
                        tvShow: tvShow,
                        onTap: () {
                          AdManager().showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TVDetailScreen(tvShow: tvShow),
                            ),
                          );
                        },
                        onFavorite: () {
                          tvProvider.addToFavorites(
                            tvShow.id,
                            !tvProvider.favoriteTV.any(
                              (t) => t.id == tvShow.id,
                            ),
                          );
                        },
                        onWatchlist: () {
                          tvProvider.addToWatchlist(
                            tvShow.id,
                            !tvProvider.watchlistTV.any(
                              (t) => t.id == tvShow.id,
                            ),
                          );
                        },
                        isFavorite: tvProvider.favoriteTV.any(
                          (t) => t.id == tvShow.id,
                        ),
                        isInWatchlist: tvProvider.watchlistTV.any(
                          (t) => t.id == tvShow.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
