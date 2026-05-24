import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/radio_provider.dart';
import 'now_playing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
    
    // SAFETY FALLBACK: Force navigation after 20 seconds no matter what
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && Navigator.of(context).canPop() == false) {
        print('🚨 SAFETY FALLBACK: Forcing navigation after 20s timeout');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NowPlayingScreen(),
          ),
        );
      }
    });
  }

  Future<void> _initializeApp() async {
    print('🚀 Splash screen initialization started');
    
    // Get API URL from environment or use default
    const String apiUrl = String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://vasfm-online.vercel.app',
    );

    print('⏱️ Waiting 1.5s for splash display...');
    // Show splash screen for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      print('❌ Widget unmounted during delay, aborting');
      return;
    }

    print('📡 Starting config fetch...');
    
    try {
      // Fetch configuration with timeout
      final radioProvider = context.read<RadioProvider>();
      
      // CRITICAL FIX: Try to load cached config FIRST for instant startup
      print('📂 Attempting to load cached config...');
      await radioProvider.loadCachedConfig();
      
      if (radioProvider.config != null) {
        print('✅ Cached config loaded instantly');
      } else {
        print('⚠️ No cached config available');
      }
      
      // Now fetch fresh config from API (will update cache if successful)
      print('📡 Fetching fresh config from API...');
      
      // Use Future.wait with timeout for better control
      await Future.wait([
        radioProvider.fetchConfig(apiUrl),
      ]).timeout(
        const Duration(seconds: 12),  // Slightly longer than fetchConfig's 10s
        onTimeout: () {
          print('⏱️ Overall initialization timed out');
          throw Exception('Initialization timeout - config fetch took too long');
        },
      );

      if (!mounted) {
        print('❌ Widget unmounted after fetch, aborting navigation');
        return;
      }

      print('✅ Config fetch completed, navigating to NowPlayingScreen');
      // Navigate to now playing screen (even if config failed - it will show error)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NowPlayingScreen(),
        ),
      );
    } catch (e) {
      print('❌ Error during initialization: $e');
      print('🔄 Forcing navigation to error screen...');
      
      if (!mounted) {
        print('❌ Widget unmounted in catch block, cannot navigate');
        return;
      }
      
      // ALWAYS navigate - NowPlayingScreen will show error state
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NowPlayingScreen(),
        ),
      );
      print('✅ Navigation completed despite error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6A229C),
              const Color(0xFF5A1D87),
              const Color(0xFF371348),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // App Icon/Logo with animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        'assets/logo-512.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.radio,
                            size: 90,
                            color: Color(0xFF6A229C),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                // App Name with animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'VAS FM',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Media VAS',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Loading Indicator with text
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
