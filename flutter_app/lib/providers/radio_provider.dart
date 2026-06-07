import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_config.dart';
import '../main.dart'; // For audioHandler
import '../utils/performance_monitor.dart'; // Performance tracking

// Helper for debug-only logging
void _debugLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

class RadioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RadioConfig? _config;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isUserInitiatedPlay = false; // Track if user pressed play
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _heartbeatTimer;
  String? _deviceId;
  Timer? _sleepTimer;
  Duration? _sleepTimerDuration;
  bool _isSleepTimerActive = false;
  
  // Performance metrics
  DateTime? _playButtonPressedTime;
  DateTime? _streamPreparedTime;
  Duration? _lastStartupLatency;
  
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
  bool get isBuffering => _audioPlayer.processingState == ProcessingState.buffering || 
                          _audioPlayer.processingState == ProcessingState.loading;
  bool get isSleepTimerActive => _isSleepTimerActive;
  Duration? get sleepTimerDuration => _sleepTimerDuration;
  bool get isUserInitiatedPlay => _isUserInitiatedPlay;
  Duration? get lastStartupLatency => _lastStartupLatency;

  RadioProvider() {
    // Initialize with hardcoded config (no API dependency)
    _config = RadioConfig.defaultConfig();
    _initPlayer();
    _initDeviceId();
    print('✅ RadioProvider initialized with hardcoded config');
    print('   Stream: ${_config!.streamUrl}');
    print('   Station: ${_config!.stationName}');
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
        
        final wasPlaying = _isPlaying;
        _isPlaying = playbackState.playing;
        
        // Clear user-initiated play flag when audio actually starts playing
        if (!wasPlaying && _isPlaying) {
          print('✅ Playback confirmed - clearing loading state');
          _isUserInitiatedPlay = false;
        }
        
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

  // Heartbeat DISABLED - standalone app (no backend)
  void _startHeartbeat() {
    print('🔔 Heartbeat disabled (standalone mode)');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    // DISABLED - no backend in standalone mode
    return;
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

  // Fetch configuration from API (DISABLED - using hardcoded config)
  Future<void> fetchConfig(String apiUrl) async {
    // HARDCODED CONFIG - no API dependency
    // Config is already set in constructor
    print('✅ Using hardcoded config (no API call needed)');
    print('   Station: ${_config!.stationName}');
    print('   Stream: ${_config!.streamUrl}');
    print('   Album Art: ${_config!.albumArtUrl}');
    
    _isLoading = false;
    _error = null;
    notifyListeners();
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
    
    // Performance tracking: Record when user pressed play
    _playButtonPressedTime = DateTime.now();
    final perfTimer = PerformanceTimer(
      'playback_startup',
      label: 'User tap to audio playback',
    );
    _debugLog('⏱️ [PERF] Play button pressed at: ${_playButtonPressedTime!.toIso8601String()}');

    try {
      _error = null;
      _isUserInitiatedPlay = true; // Set flag for immediate UI feedback
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
      
      // Performance tracking: Calculate startup latency
      if (_playButtonPressedTime != null) {
        final playbackStartTime = DateTime.now();
        _lastStartupLatency = playbackStartTime.difference(_playButtonPressedTime!);
        _debugLog('⏱️ [PERF] Playback started at: ${playbackStartTime.toIso8601String()}');
        _debugLog('⏱️ [PERF] ⚡ Startup latency: ${_lastStartupLatency!.inMilliseconds}ms');
        
        // Record in performance monitor (debug only)
        perfTimer.stop();
        
        // Performance rating
        if (_lastStartupLatency!.inMilliseconds < 1000) {
          _debugLog('⭐ [PERF] Rating: EXCELLENT (<1s)');
        } else if (_lastStartupLatency!.inMilliseconds < 2000) {
          _debugLog('⭐ [PERF] Rating: GOOD (1-2s)');
        } else if (_lastStartupLatency!.inMilliseconds < 3000) {
          _debugLog('⭐ [PERF] Rating: ACCEPTABLE (2-3s)');
        } else {
          _debugLog('⚠️ [PERF] Rating: SLOW (>3s) - Consider optimization');
        }
      }
      
      print('✅ Playback started successfully');
      _isUserInitiatedPlay = false; // Clear flag once playback starts
      notifyListeners();
      
      // Start listener tracking
      _startHeartbeat();
    } on PlayerException catch (e) {
      // just_audio specific errors
      print('❌ Player error: ${e.message}');
      _error = 'Failed to play stream: ${e.message}';
      _isUserInitiatedPlay = false;
      
      if (_playButtonPressedTime != null) {
        final errorTime = DateTime.now();
        final errorLatency = errorTime.difference(_playButtonPressedTime!);
        _debugLog('⏱️ [PERF] Error after ${errorLatency.inMilliseconds}ms: ${e.message}');
        
        // Record failed attempt (debug only)
        if (kDebugMode) {
          PerformanceMonitor().recordMetric(
            action: 'playback_error',
            duration: errorLatency,
            label: 'Player exception',
            metadata: {'error': e.message},
          );
        }
      }
      
      notifyListeners();
    } on SocketException catch (e) {
      // Network errors
      print('❌ Network error: ${e.message}');
      _error = 'Network error: Cannot reach stream server. Check your internet connection.';
      _isUserInitiatedPlay = false;
      
      if (_playButtonPressedTime != null) {
        final errorTime = DateTime.now();
        final errorLatency = errorTime.difference(_playButtonPressedTime!);
        _debugLog('⏱️ [PERF] Network error after ${errorLatency.inMilliseconds}ms');
        
        // Record failed attempt (debug only)
        if (kDebugMode) {
          PerformanceMonitor().recordMetric(
            action: 'playback_error',
            duration: errorLatency,
            label: 'Network error',
            metadata: {'error': e.message},
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      // Generic errors
      print('❌ Error: $e');
      _error = 'Failed to play stream: $e';
      _isUserInitiatedPlay = false;
      
      if (_playButtonPressedTime != null) {
        final errorTime = DateTime.now();
        final errorLatency = errorTime.difference(_playButtonPressedTime!);
        _debugLog('⏱️ [PERF] Error after ${errorLatency.inMilliseconds}ms: $e');
        
        // Record failed attempt (debug only)
        if (kDebugMode) {
          PerformanceMonitor().recordMetric(
            action: 'playback_error',
            duration: errorLatency,
            label: 'Generic error',
            metadata: {'error': e.toString()},
          );
        }
      }
      
      notifyListeners();
    } finally {
      _playButtonPressedTime = null; // Reset tracking
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
  
  // Pre-buffer the stream for instant playback
  Future<void> preBuffer() async {
    if (_config == null || _config!.streamUrl.isEmpty) {
      return;
    }
    
    try {
      final preBufferStartTime = DateTime.now();
      _debugLog('🔊 Pre-buffering stream...');
      
      final perfTimer = PerformanceTimer(
        'pre_buffering',
        label: 'Stream pre-buffering during splash',
      );
      
      if (audioHandler != null) {
        await audioHandler!.prepareStream(
          _config!.streamUrl,
          title: _config!.stationName,
          artist: 'VAS FM Online',
          artUrl: _config!.albumArtUrl,
        );
        
        final preBufferEndTime = DateTime.now();
        final preBufferDuration = preBufferEndTime.difference(preBufferStartTime);
        _debugLog('⏱️ [PERF] Pre-buffering completed in: ${preBufferDuration.inMilliseconds}ms');
        _streamPreparedTime = preBufferEndTime;
        
        // Record in performance monitor (debug only)
        if (kDebugMode) {
          perfTimer.stop();
        }
        
        if (preBufferDuration.inMilliseconds < 1500) {
          _debugLog('⭐ [PERF] Pre-buffer: FAST (<1.5s) - Stream ready for instant playback');
        } else {
          _debugLog('⚠️ [PERF] Pre-buffer: SLOW (>1.5s) - May impact user experience');
        }
      }
    } catch (e) {
      print('⚠️ Pre-buffering failed (non-critical): $e');
    }
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
