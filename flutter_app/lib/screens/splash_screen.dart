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
  }

  Future<void> _initializeApp() async {
    // Get API URL from environment or use default
    // You can change this to your DigitalOcean App Platform URL
    const String apiUrl = String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://vasfm-online.vercel.app',
    );

    // Small delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Fetch configuration
    final radioProvider = context.read<RadioProvider>();
    await radioProvider.fetchConfig(apiUrl);

    if (!mounted) return;

    // Navigate to now playing screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const NowPlayingScreen(),
      ),
    );
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
              const Color(0xFF6A229C).withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/logo-512.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image not found
                      return const Icon(
                        Icons.radio,
                        size: 80,
                        color: Color(0xFF6A229C),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // App Name
              Text(
                'VAS FM',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Media VAS',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 50),
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
