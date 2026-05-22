import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'screens/splash_screen.dart';
import 'providers/radio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio session for background playback
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
  ));

  // Initialize just_audio_background for notifications and background playback
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.arthiumlabs.radio.channel.audio',
    androidNotificationChannelName: 'Radio playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

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
