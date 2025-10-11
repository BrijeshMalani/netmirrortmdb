import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_open_ad_manager.dart';
import 'widgets/SmallNativeAdService.dart';
import 'Utils/common.dart';
import 'providers/movie_provider.dart';
import 'providers/tv_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppOpenAdManager _appOpenAdManager = AppOpenAdManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize native ad service safely
    _initializeAds();
  }

  void _initializeAds() {
    try {
      // Only initialize ads if they are enabled and IDs are provided
      if (Common.addOnOff && Common.native_ad_id.isNotEmpty) {
        SmallNativeAdService().initialize();
      } else {
        print('Ads disabled or no ad IDs provided, skipping ad initialization');
      }
    } catch (e) {
      print('Error initializing ads: $e');
      // Continue without ads if initialization fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => TVProvider()),
      ],
      child: MaterialApp(
        title: 'NetMirror',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going to background
      Common.isAppInBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      // App is resuming from background
      if (Common.addOnOff &&
          Common.isAppInBackground &&
          Common.app_open_ad_id.isNotEmpty) {
        if (!_recentlyShownInterstitial()) {
          try {
            _appOpenAdManager.showAdIfAvailable();
          } catch (e) {
            print('Error showing app open ad: $e');
          }
        }
      }
      // Reset background flag after handling resume
      Common.isAppInBackground = false;
    }
  }

  bool _recentlyShownInterstitial() {
    // Check if recently opened flag is true
    if (Common.recentlyOpened) {
      return true;
    }

    // Check if interstitial ad was shown within the last 15 seconds
    if (Common.lastInterstitialAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(
        Common.lastInterstitialAdTime!,
      );
      if (timeSinceLastAd.inSeconds < 15) {
        return true;
      }
    }

    return false;
  }
}
