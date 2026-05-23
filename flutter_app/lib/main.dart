import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'screens/splash_screen.dart';
import 'providers/radio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize audio session for background playback with timeout
    final session = await AudioSession.instance.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ Audio session initialization timed out, continuing anyway');
        throw Exception('Audio session timeout');
      },
    );
    
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    )).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        print('⚠️ Audio session configuration timed out');
      },
    );
  } catch (e) {
    print('⚠️ Audio session error (continuing): $e');
    // Continue anyway - app can still work without perfect audio session
  }

  try {
    // Initialize just_audio_background for notifications and background playback
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.arthiumlabs.radio.channel.audio',
      androidNotificationChannelName: 'Radio playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ JustAudioBackground init timed out, continuing anyway');
      },
    );
  } catch (e) {
    print('⚠️ JustAudioBackground error (continuing): $e');
    // Continue anyway - app can still work without background notifications
  }

  print('✅ App initialization complete, launching...');
  runApp(const RadioPlayerApp());
}

class RadioPlayerApp extends StatelessWidget {
  const RadioPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioProvider(),
      child: MaterialApp(
        title: 'VAS FM Online',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF6A229C),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6A229C),
            brightness: Brightness.light,
            primary: const Color(0xFF6A229C),
            secondary: const Color(0xFFFCDE2B),
            surface: const Color(0xFFF9FAFB),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6A229C),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A229C),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        darkTheme: ThemeData(
          primaryColor: const Color(0xFF6A229C),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6A229C),
            brightness: Brightness.dark,
            primary: const Color(0xFF6A229C),
            secondary: const Color(0xFFFCDE2B),
            surface: const Color(0xFF371348),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF371348),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6A229C),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A229C),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
