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

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _searchQuery = query.trim();
    });

    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final tvProvider = Provider.of<TVProvider>(context, listen: false);

    movieProvider.searchMovies(_searchQuery);
    tvProvider.searchTV(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search movies and TV shows...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              Provider.of<MovieProvider>(
                                context,
                                listen: false,
                              ).clearSearch();
                              Provider.of<TVProvider>(
                                context,
                                listen: false,
                              ).clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _searchQuery = '';
                      });
                      Provider.of<MovieProvider>(
                        context,
                        listen: false,
                      ).clearSearch();
                      Provider.of<TVProvider>(
                        context,
                        listen: false,
                      ).clearSearch();
                    }
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Movies'),
                    Tab(text: 'TV Shows'),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptyState()
          : TabBarView(
              controller: _tabController,
              children: [_buildMovieSearchResults(), _buildTVSearchResults()],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for movies and TV shows',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a title to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSearchResults() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return const LoadingShimmer(itemCount: 6);
        }

        if (movieProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No movies found for "$_searchQuery"',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  'Try a different search term',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.76,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: movieProvider.searchResults.length,
                itemBuilder: (context, index) {
                  final movie = movieProvider.searchResults[index];
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
                      movieProvider.addToWatchlist(
                        movie.id,
                        !movieProvider.watchlistMovies.any((m) => m.id == movie.id),
                      );
                    },
                    isFavorite: movieProvider.favoriteMovies.any(
                      (m) => m.id == movie.id,
                    ),
                    isInWatchlist: movieProvider.watchlistMovies.any(
                      (m) => m.id == movie.id,
                    ),
                  );
                },
              ),
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }

  Widget _buildTVSearchResults() {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        if (tvProvider.isLoading) {
          return const LoadingShimmer(itemCount: 6);
        }

        if (tvProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tv, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No TV shows found for "$_searchQuery"',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  'Try a different search term',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.76,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: tvProvider.searchResults.length,
                itemBuilder: (context, index) {
                  final tvShow = tvProvider.searchResults[index];
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
                      tvProvider.addToWatchlist(
                        tvShow.id,
                        !tvProvider.watchlistTV.any((t) => t.id == tvShow.id),
                      );
                    },
                    isFavorite: tvProvider.favoriteTV.any((t) => t.id == tvShow.id),
                    isInWatchlist: tvProvider.watchlistTV.any(
                      (t) => t.id == tvShow.id,
                    ),
                  );
                },
              ),
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }
}
