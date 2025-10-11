import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../services/ad_manager.dart';
import '../widgets/WorkingNativeAdWidget.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_shimmer.dart';
import '../models/movie.dart';
import '../services/tmdb_api_service.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // State variables for "All" tab
  List<Movie> allMovies = [];
  bool isLoadingAll = false;
  bool isLoadingMoreAll = false;
  String? errorAll;
  int currentPageAll = 1;
  int totalPagesAll = 1;
  String selectedSortByAll = 'popularity.desc';
  final ScrollController _scrollControllerAll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollControllerAll.addListener(_onScrollAll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadAllMovies();
    });
  }

  void _loadData() {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    movieProvider.loadTrendingMovies();
    movieProvider.loadPopularMovies();
    movieProvider.loadTopRatedMovies();
    movieProvider.loadFavoriteMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllerAll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_tabController.index == 0) // Show sort button only for "All" tab
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: _onSortChangedAll,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'popularity.desc',
                  child: Text('Most Popular'),
                ),
                const PopupMenuItem(
                  value: 'vote_average.desc',
                  child: Text('Top Rated'),
                ),
                const PopupMenuItem(
                  value: 'release_date.desc',
                  child: Text('Latest Release'),
                ),
                const PopupMenuItem(
                  value: 'revenue.desc',
                  child: Text('Highest Revenue'),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            setState(() {}); // Trigger rebuild to show/hide sort button
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Trending'),
            Tab(text: 'Popular'),
            Tab(text: 'Top Rated'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllMoviesList(),
          _buildMoviesList('trending'),
          _buildMoviesList('popular'),
          _buildMoviesList('topRated'),
          _buildMoviesList('favorites'),
        ],
      ),
    );
  }

  // Methods for "All" tab
  void _onScrollAll() {
    if (_scrollControllerAll.position.pixels >=
        _scrollControllerAll.position.maxScrollExtent - 200) {
      if (!isLoadingMoreAll && currentPageAll < totalPagesAll) {
        _loadMoreAllMovies();
      }
    }
  }

  Future<void> _loadAllMovies({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          allMovies.clear();
          currentPageAll = 1;
        }
        isLoadingAll = true;
        errorAll = null;
      });

      final response = await TMDBAPIService.getAllMovies(
        page: currentPageAll,
        sortBy: selectedSortByAll,
      );

      if (mounted) {
        setState(() {
          final List<dynamic> results = response['results'] ?? [];
          final List<Movie> newMovies = results
              .map((json) => Movie.fromJson(json))
              .toList();

          if (refresh) {
            allMovies = newMovies;
          } else {
            allMovies.addAll(newMovies);
          }

          currentPageAll = response['page'] ?? 1;
          totalPagesAll = response['total_pages'] ?? 1;
          isLoadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorAll = e.toString();
          isLoadingAll = false;
        });
      }
    }
  }

  Future<void> _loadMoreAllMovies() async {
    if (isLoadingMoreAll || currentPageAll >= totalPagesAll) return;

    try {
      setState(() {
        isLoadingMoreAll = true;
      });

      final nextPage = currentPageAll + 1;
      final response = await TMDBAPIService.getAllMovies(
        page: nextPage,
        sortBy: selectedSortByAll,
      );

      if (mounted) {
        setState(() {
          final List<dynamic> results = response['results'] ?? [];
          final List<Movie> newMovies = results
              .map((json) => Movie.fromJson(json))
              .toList();
          allMovies.addAll(newMovies);
          currentPageAll = response['page'] ?? nextPage;
          totalPagesAll = response['total_pages'] ?? totalPagesAll;
          isLoadingMoreAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMoreAll = false;
        });
      }
    }
  }

  void _onSortChangedAll(String? value) {
    if (value != null && value != selectedSortByAll) {
      setState(() {
        selectedSortByAll = value;
      });
      _loadAllMovies(refresh: true);
    }
  }

  Widget _buildAllMoviesList() {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (isLoadingAll && allMovies.isEmpty) {
          return const LoadingShimmer(itemCount: 6);
        }

        if (errorAll != null && allMovies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $errorAll'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadAllMovies(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (allMovies.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No movies found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadAllMovies(refresh: true),
                child: GridView.builder(
                  controller: _scrollControllerAll,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: allMovies.length + (isLoadingMoreAll ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == allMovies.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final movie = allMovies[index];
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
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }

  Widget _buildMoviesList(String type) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        List<dynamic> movies = [];
        bool isLoading = false;

        switch (type) {
          case 'trending':
            movies = movieProvider.trendingMovies;
            isLoading = movieProvider.isLoading && movies.isEmpty;
            break;
          case 'popular':
            movies = movieProvider.popularMovies;
            isLoading = movieProvider.isLoading && movies.isEmpty;
            break;
          case 'topRated':
            movies = movieProvider.topRatedMovies;
            isLoading = movieProvider.isLoading && movies.isEmpty;
            break;
          case 'favorites':
            movies = movieProvider.favoriteMovies;
            isLoading = movieProvider.isLoading && movies.isEmpty;
            break;
        }

        if (isLoading) {
          return const LoadingShimmer(itemCount: 6);
        }

        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'favorites' ? Icons.favorite_border : Icons.movie,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  type == 'favorites'
                      ? 'No favorite movies yet'
                      : 'No movies found',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (type == 'favorites')
                  const Text(
                    'Add movies to your favorites to see them here',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  switch (type) {
                    case 'trending':
                      await movieProvider.loadTrendingMovies();
                      break;
                    case 'popular':
                      await movieProvider.loadPopularMovies();
                      break;
                    case 'topRated':
                      await movieProvider.loadTopRatedMovies();
                      break;
                    case 'favorites':
                      await movieProvider.loadFavoriteMovies();
                      break;
                  }
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
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
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }
}
