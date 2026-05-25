import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_config.dart';
import '../main.dart'; // For audioHandler

class RadioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RadioConfig? _config;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _heartbeatTimer;
  String? _deviceId;
  Timer? _sleepTimer;
  Duration? _sleepTimerDuration;
  bool _isSleepTimerActive = false;
  
  // Stream subscriptions to prevent memory leaks
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<ProcessingState> _processingStateSubscription;

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  RadioConfig? get config => _config;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String? get error => _error;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isBuffering => _audioPlayer.processingState == ProcessingState.buffering;
  bool get isSleepTimerActive => _isSleepTimerActive;
  Duration? get sleepTimerDuration => _sleepTimerDuration;

  RadioProvider() {
    _initPlayer();
    _initDeviceId();
  }

  // Call this AFTER audioHandler is initialized in main()
  void setupAudioHandlerListener() {
    if (audioHandler != null) {
      print('🔗 Setting up audioHandler playback state listener');
      
      // Reset playing state on startup (audioHandler may have stale state)
      _isPlaying = false;
      notifyListeners();
      
      audioHandler!.playbackState.listen((playbackState) {
        print('🔊 AudioHandler playback state changed: playing=${playbackState.playing}');
        _isPlaying = playbackState.playing;
        notifyListeners();
      });
    }
  }

  Future<void> _initDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString('device_id');
      
      if (_deviceId == null) {
        _deviceId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + (DateTime.now().microsecondsSinceEpoch % 100000).toString();
        await prefs.setString('device_id', _deviceId!);
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });
    
    // Send first heartbeat immediately
    _sendHeartbeat();
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    if (_deviceId == null || _config == null || !_isPlaying) return;

    try {
      final apiUrl = const String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://vasfm-online.vercel.app',
      );

      await http.post(
        Uri.parse('$apiUrl/api/listener/heartbeat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': _deviceId,
          'stationName': _config!.stationName,
          'deviceType': Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other'),
        }),
      );
    } catch (e) {
      print('Heartbeat error: $e');
    }
  }

  void _initPlayer() {
    // Listen to player state changes (local player - for fallback)
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    // Listen to processing state for buffering
    _processingStateSubscription = _audioPlayer.processingStateStream.listen((state) {
      notifyListeners();
    });
  }

  // Fetch configuration from API
  Future<void> fetchConfig(String apiUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '$apiUrl/api/config';
      print('📡 Fetching config from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'VAS FM Radio App/1.0'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Config loaded successfully');
        print('   Station: ${data['stationName']}');
        print('   Stream: ${data['streamUrl']}');
        print('   Album Art: ${data['albumArtUrl']}');
        
        _config = RadioConfig.fromJson(data);
        
        // Cache config locally for offline access
        await _cacheConfig(data);
        
        // Validate stream URL
        if (_config!.streamUrl.isEmpty) {
          _error = 'Stream URL is empty. Please configure in admin dashboard.';
          print('⚠️ Warning: Stream URL is empty');
        }
        
        _isLoading = false;
        notifyListeners();
      } else {
        // Try to load cached config
        print('❌ Error: HTTP ${response.statusCode} - ${response.body}');
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString('cached_config');
        if (cachedJson != null) {
          print('📱 Using cached config');
          _config = RadioConfig.fromJson(json.decode(cachedJson));
          _error = 'Using offline config. Connect to internet for updates.';
        } else {
          // FALLBACK to hardcoded defaults (guaranteed uptime)
          print('⚠️ No cached config, using hardcoded defaults');
          _config = RadioConfig.defaultConfig();
          _error = null; // No error - app works with defaults
        }
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Network error: $e');
      // Try to load cached config
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_config');
      if (cachedJson != null) {
        print('📱 Using cached config (offline mode)');
        _config = RadioConfig.fromJson(json.decode(cachedJson));
        _error = 'Offline mode - using cached config';
      } else {
        // FALLBACK to hardcoded defaults (guaranteed uptime)
        print('⚠️ No cached config, using hardcoded defaults');
        _config = RadioConfig.defaultConfig();
        _error = null; // No error - app works with defaults
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cache config to SharedPreferences for offline access
  Future<void> _cacheConfig(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_config', json.encode(data));
      await prefs.setString('cached_config_timestamp', DateTime.now().toIso8601String());
      print('💾 Config cached locally');
    } catch (e) {
      print('Error caching config: $e');
    }
  }

  // Load cached config from SharedPreferences (PUBLIC for splash screen)
  Future<void> loadCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_config');
      
      if (cachedJson != null) {
        final data = json.decode(cachedJson);
        final timestamp = prefs.getString('cached_config_timestamp');
        print('📂 Loaded cached config from: $timestamp');
        _config = RadioConfig.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached config: $e');
    }
  }

  // Play the radio stream
  Future<void> play() async {
    if (_config == null) {
      _error = 'Configuration not loaded yet. Please wait...';
      notifyListeners();
      return;
    }

    if (_config!.streamUrl.isEmpty) {
      _error = 'No stream URL configured. Please update in admin dashboard.';
      notifyListeners();
      return;
    }

    // Validate stream URL format
    final streamUrl = _config!.streamUrl.trim();
    if (!streamUrl.startsWith('http://') && !streamUrl.startsWith('https://')) {
      _error = 'Invalid stream URL format. URL must start with http:// or https://';
      notifyListeners();
      return;
    }

    print('🎵 Attempting to play: $streamUrl');

    try {
      _error = null;
      notifyListeners();

      // Use audio_service for background playback
      if (audioHandler != null) {
        print('🔊 Using AudioService for background playback');
        await audioHandler!.setStreamUrl(
          streamUrl,
          title: _config!.stationName,
          artist: 'VAS FM Online',
          artUrl: _config!.albumArtUrl,
        );
      } else {
        // Fallback to direct player if audio_service failed to init
        print('⚠️ AudioService not available, using direct playback');
        await _audioPlayer.setUrl(
          streamUrl,
          headers: {
            'User-Agent': 'VAS FM Radio App/1.1',
            'Icy-MetaData': '1',
          },
        );
        await _audioPlayer.play();
      }
      
      print('✅ Playback started successfully');
      
      // Start listener tracking
      _startHeartbeat();
    } on PlayerException catch (e) {
      // just_audio specific errors
      print('❌ Player error: ${e.message}');
      _error = 'Failed to play stream: ${e.message}';
      notifyListeners();
    } on SocketException catch (e) {
      // Network errors
      print('❌ Network error: ${e.message}');
      _error = 'Network error: Cannot reach stream server. Check your internet connection.';
      notifyListeners();
    } catch (e) {
      // Generic errors
      print('❌ Error: $e');
      _error = 'Failed to play stream: $e';
      notifyListeners();
    }
  }

  // Pause the radio stream
  Future<void> pause() async {
    try {
      // Use audioHandler if available, otherwise use local player
      if (audioHandler != null) {
        await audioHandler!.pause();
      } else {
        await _audioPlayer.pause();
      }
      _stopHeartbeat();
    } catch (e) {
      _error = 'Failed to pause: $e';
      notifyListeners();
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // Stop the radio stream
  Future<void> stop() async {
    try {
      // Use audioHandler if available, otherwise use local player
      if (audioHandler != null) {
        await audioHandler!.stop();
      } else {
        await _audioPlayer.stop();
      }
      _stopHeartbeat();
    } catch (e) {
      _error = 'Failed to stop: $e';
      notifyListeners();
    }
  }

  void startSleepTimer(Duration duration) {
    stopSleepTimer();
    _sleepTimerDuration = duration;
    _isSleepTimerActive = true;
    notifyListeners();
    
    print('⏰ Sleep timer started: ${duration.inMinutes} minutes');
    
    _sleepTimer = Timer(duration, () {
      print('⏰ Sleep timer expired - stopping playback');
      stop();
      _isSleepTimerActive = false;
      _sleepTimerDuration = null;
      notifyListeners();
    });
  }
  
  void stopSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _isSleepTimerActive = false;
    _sleepTimerDuration = null;
    notifyListeners();
    print('⏰ Sleep timer stopped');
  }
  
  @override
  void dispose() {
    _stopHeartbeat();
    stopSleepTimer();
    
    // Cancel all stream subscriptions to prevent memory leaks
    _playerStateSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _processingStateSubscription.cancel();
    
    _audioPlayer.dispose();
    super.dispose();
  }
}
