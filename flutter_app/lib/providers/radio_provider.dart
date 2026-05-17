import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_config.dart';

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

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  RadioConfig? get config => _config;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String? get error => _error;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isBuffering => _audioPlayer.processingState == ProcessingState.buffering;

  RadioProvider() {
    _initPlayer();
    _initDeviceId();
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
        defaultValue: 'http://172.20.10.3:3000',
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
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    // Listen to processing state for buffering
    _audioPlayer.processingStateStream.listen((state) {
      notifyListeners();
    });
  }

  // Fetch configuration from API
  Future<void> fetchConfig(String apiUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$apiUrl/api/config'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _config = RadioConfig.fromJson(data);
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load configuration';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Play the radio stream
  Future<void> play() async {
    if (_config == null || _config!.streamUrl.isEmpty) {
      _error = 'No stream URL configured';
      notifyListeners();
      return;
    }

    try {
      _error = null;
      notifyListeners();

      await _audioPlayer.setUrl(
        _config!.streamUrl,
      );
      
      await _audioPlayer.play();
      
      // Start listener tracking
      _startHeartbeat();
    } catch (e) {
      _error = 'Failed to play stream: $e';
      notifyListeners();
    }
  }

  // Pause the radio stream
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
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
      await _audioPlayer.stop();
      _stopHeartbeat();
    } catch (e) {
      _error = 'Failed to stop: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopHeartbeat();
    _audioPlayer.dispose();
    super.dispose();
  }
}
