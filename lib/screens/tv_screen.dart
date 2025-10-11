import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tv_provider.dart';
import '../services/ad_manager.dart';
import '../widgets/WorkingNativeAdWidget.dart';
import '../widgets/tv_card.dart';
import '../widgets/loading_shimmer.dart';
import '../models/tv_show.dart';
import '../services/tmdb_api_service.dart';
import 'tv_detail_screen.dart';

class TVScreen extends StatefulWidget {
  const TVScreen({Key? key}) : super(key: key);

  @override
  State<TVScreen> createState() => _TVScreenState();
}

class _TVScreenState extends State<TVScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // State variables for "All" tab
  List<TVShow> allTVShows = [];
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
    _tabController = TabController(length: 6, vsync: this);
    _scrollControllerAll.addListener(_onScrollAll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadAllTV();
    });
  }

  void _loadData() {
    final tvProvider = Provider.of<TVProvider>(context, listen: false);
    tvProvider.loadTrendingTV();
    tvProvider.loadPopularTV();
    tvProvider.loadTopRatedTV();
    tvProvider.loadAiringTodayTV();
    tvProvider.loadFavoriteTV();
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
        title: const Text('TV Shows'),
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
                  value: 'first_air_date.desc',
                  child: Text('Latest Release'),
                ),
                const PopupMenuItem(
                  value: 'vote_count.desc',
                  child: Text('Most Voted'),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          onTap: (index) {
            setState(() {}); // Trigger rebuild to show/hide sort button
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Trending'),
            Tab(text: 'Popular'),
            Tab(text: 'Top Rated'),
            Tab(text: 'Airing Today'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTVList(),
          _buildTVList('trending'),
          _buildTVList('popular'),
          _buildTVList('topRated'),
          _buildTVList('airingToday'),
          _buildTVList('favorites'),
        ],
      ),
    );
  }

  // Methods for "All" tab
  void _onScrollAll() {
    if (_scrollControllerAll.position.pixels >=
        _scrollControllerAll.position.maxScrollExtent - 200) {
      if (!isLoadingMoreAll && currentPageAll < totalPagesAll) {
        _loadMoreAllTV();
      }
    }
  }

  Future<void> _loadAllTV({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          allTVShows.clear();
          currentPageAll = 1;
        }
        isLoadingAll = true;
        errorAll = null;
      });

      final response = await TMDBAPIService.getAllSeries(
        page: currentPageAll,
        sortBy: selectedSortByAll,
      );

      if (mounted) {
        setState(() {
          final List<dynamic> results = response['results'] ?? [];
          final List<TVShow> newTVShows = results
              .map((json) => TVShow.fromJson(json))
              .toList();

          if (refresh) {
            allTVShows = newTVShows;
          } else {
            allTVShows.addAll(newTVShows);
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

  Future<void> _loadMoreAllTV() async {
    if (isLoadingMoreAll || currentPageAll >= totalPagesAll) return;

    try {
      setState(() {
        isLoadingMoreAll = true;
      });

      final nextPage = currentPageAll + 1;
      final response = await TMDBAPIService.getAllSeries(
        page: nextPage,
        sortBy: selectedSortByAll,
      );

      if (mounted) {
        setState(() {
          final List<dynamic> results = response['results'] ?? [];
          final List<TVShow> newTVShows = results
              .map((json) => TVShow.fromJson(json))
              .toList();
          allTVShows.addAll(newTVShows);
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
      _loadAllTV(refresh: true);
    }
  }

  Widget _buildAllTVList() {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        if (isLoadingAll && allTVShows.isEmpty) {
          return const LoadingShimmer(itemCount: 6);
        }

        if (errorAll != null && allTVShows.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $errorAll'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadAllTV(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (allTVShows.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tv, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No TV shows found',
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
                onRefresh: () => _loadAllTV(refresh: true),
                child: GridView.builder(
                  controller: _scrollControllerAll,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: allTVShows.length + (isLoadingMoreAll ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == allTVShows.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final tvShow = allTVShows[index];
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
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }

  Widget _buildTVList(String type) {
    return Consumer<TVProvider>(
      builder: (context, tvProvider, child) {
        List<dynamic> tvShows = [];
        bool isLoading = false;

        switch (type) {
          case 'trending':
            tvShows = tvProvider.trendingTV;
            isLoading = tvProvider.isLoading && tvShows.isEmpty;
            break;
          case 'popular':
            tvShows = tvProvider.popularTV;
            isLoading = tvProvider.isLoading && tvShows.isEmpty;
            break;
          case 'topRated':
            tvShows = tvProvider.topRatedTV;
            isLoading = tvProvider.isLoading && tvShows.isEmpty;
            break;
          case 'airingToday':
            tvShows = tvProvider.airingTodayTV;
            isLoading = tvProvider.isLoading && tvShows.isEmpty;
            break;
          case 'favorites':
            tvShows = tvProvider.favoriteTV;
            isLoading = tvProvider.isLoading && tvShows.isEmpty;
            break;
        }

        if (isLoading) {
          return const LoadingShimmer(itemCount: 6);
        }

        if (tvShows.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'favorites' ? Icons.favorite_border : Icons.tv,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  type == 'favorites'
                      ? 'No favorite TV shows yet'
                      : 'No TV shows found',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (type == 'favorites')
                  const Text(
                    'Add TV shows to your favorites to see them here',
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
                      await tvProvider.loadTrendingTV();
                      break;
                    case 'popular':
                      await tvProvider.loadPopularTV();
                      break;
                    case 'topRated':
                      await tvProvider.loadTopRatedTV();
                      break;
                    case 'airingToday':
                      await tvProvider.loadAiringTodayTV();
                      break;
                    case 'favorites':
                      await tvProvider.loadFavoriteTV();
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
                  itemCount: tvShows.length,
                  itemBuilder: (context, index) {
                    final tvShow = tvShows[index];
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
            ),

            const WorkingNativeAdWidget(),
          ],
        );
      },
    );
  }
}
