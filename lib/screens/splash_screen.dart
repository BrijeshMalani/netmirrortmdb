import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Utils/common.dart';
import '../services/ad_manager.dart';
import '../services/api_service.dart';
import '../services/app_open_ad_manager.dart';
import '../services/intro_service.dart';
import '../widgets/NativeAdService.dart';
import '../widgets/SmallNativeAdService.dart';
import 'AppInitializer.dart';
import 'intro_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  final AppOpenAdManager _appOpenAdManager = AppOpenAdManager();

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _navigateAfterDelay();
  }

  Future<void> setupRemoteConfig() async {
    final data = await ApiService.fetchAppData();
    print('API Response: $data');

    if (data != null) {
      if (data.rewardedFull.isNotEmpty) {
        print('Setting privacy policy: ${data.rewardedFull}');
        Common.privacy_policy = data.rewardedFull;
      }
      if (data.rewardedFull2.isNotEmpty) {
        print('Setting terms and conditions: ${data.rewardedFull2}');
        Common.terms_conditions = data.rewardedFull2;
      }
      if (data.startAppFull.isNotEmpty) {
        print('Setting playstore link: ${data.startAppFull}');
        Common.playstore_link = data.startAppFull;
      }
      if (data.gamezopId.isNotEmpty) {
        print('Interstitial show count: ${data.gamezopId}');
        Common.ads_int_open_count = int.parse(data.gamezopId);
      }
      if (data.rewardedFull1.isNotEmpty) {
        print('Ads Open Count: ${data.rewardedFull1}');
        Common.ads_open_count = data.rewardedFull1;
      }
      if (data.startAppRewarded.isNotEmpty) {
        print('Ads open area: ${data.startAppRewarded}');
        Common.adsopen = data.startAppRewarded;
      }

      if (data.qurekaId.isNotEmpty) {
        print('qureka link: ${data.qurekaId}');
        Common.Qurekaid = data.qurekaId;
      }
      if (data.fbFull.isNotEmpty) {
        print('download url show: ${data.fbFull}'); // 2-show
        Common.urlshow = data.fbFull;
      }
      //Google ads
      if (data.admobId.isNotEmpty) {
        print('Setting banner ad ID: ${data.admobId}');
        Common.bannar_ad_id = data.admobId;
        // Common.bannar_ad_id = "ca-app-pub-3940256099942544/6300978111";
      }
      if (data.admobFull.isNotEmpty) {
        print('Setting interstitial ad ID: ${data.admobFull}');
        Common.interstitial_ad_id = data.admobFull;
        // Common.interstitial_ad_id = "ca-app-pub-3940256099942544/1033173712";
      }
      if (data.admobFull1.isNotEmpty) {
        print('Setting interstitial ad ID1: ${data.admobFull1}');
        Common.interstitial_ad_id1 = data.admobFull1;
        // Common.interstitial_ad_id1 = "ca-app-pub-3940256099942544/1033173712";
      }
      if (data.admobFull2.isNotEmpty) {
        print('Setting interstitial ad ID2: ${data.admobFull2}');
        Common.interstitial_ad_id2 = data.admobFull2;
      }
      if (data.admobNative.isNotEmpty) {
        print('Setting native ad ID: ${data.admobNative}');
        Common.native_ad_id = data.admobNative;
        // Common.native_ad_id = "ca-app-pub-3940256099942544/2247696110";
      }
      if (data.rewardedInt.isNotEmpty) {
        print('Setting app open ad ID: ${data.rewardedInt}');
        Common.app_open_ad_id = data.rewardedInt;
        // Common.app_open_ad_id = "ca-app-pub-3940256099942544/9257395921";
      }
    }

    // Initialize Mobile Ads SDK
    await MobileAds.instance.initialize();

    Common.addOnOff = true;

    if (Common.addOnOff) {
      // Initialize only the necessary ad services
      AdManager().initialize();
      SmallNativeAdService().initialize();
      NativeAdService().initialize();
      _appOpenAdManager.loadAd();
    }
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    // Start logo animation
    _logoController.forward();

    // Start text animation after logo starts
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });

    // Start progress animation
    _progressController.forward();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppInitializer()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value * 0.1,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.deepPurple,
                                      Colors.deepPurpleAccent,
                                      Colors.purpleAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.2),
                                      blurRadius: 60,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.movie,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Animated App Name
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlideAnimation.value),
                            child: Opacity(
                              opacity: _textFadeAnimation.value,
                              child: Column(
                                children: [
                                  const Text(
                                    'NetMirror',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your Ultimate Entertainment Hub',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Loading Animation
                      _buildLoadingAnimation(),
                    ],
                  ),
                ),
              ),

              // Progress Bar
              _buildProgressBar(),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Column(
      children: [
        // Rotating dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                final delay = index * 0.2;
                final animationValue = (_progressAnimation.value - delay).clamp(
                  0.0,
                  1.0,
                );
                final scale =
                    0.5 + (0.5 * (1 - (animationValue * 2 - 1).abs()));

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),

        const SizedBox(height: 20),

        // Loading text
        Text(
          'Loading your entertainment experience...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Progress percentage
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
