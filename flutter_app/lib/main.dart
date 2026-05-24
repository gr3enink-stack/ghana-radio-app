import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'screens/splash_screen.dart';
import 'providers/radio_provider.dart';
import 'services/radio_audio_handler.dart';

// Global audio handler instance
RadioAudioHandler? audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio_service for background playback
  try {
    print('🔊 Initializing AudioService...');
    audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.arthiumlabs.radio.channel.audio',
        androidNotificationChannelName: 'VAS FM Radio',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );
    print('✅ AudioService initialized successfully');
  } catch (e) {
    print('⚠️ AudioService init failed: $e');
  }

  try {
    // Initialize audio session for playback
    final session = await AudioSession.instance.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ Audio session initialization timed out');
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
    
    print('✅ Audio session initialized successfully');
  } catch (e) {
    print('⚠️ Audio session error (continuing): $e');
  }

  print('✅ App initialization complete, launching...');
  runApp(const RadioPlayerApp());
}

class RadioPlayerApp extends StatelessWidget {
  const RadioPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = RadioProvider();
        // Setup audioHandler listener after provider is created
        provider.setupAudioHandlerListener();
        return provider;
      },
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
