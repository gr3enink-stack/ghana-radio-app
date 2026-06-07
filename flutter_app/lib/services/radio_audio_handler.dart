import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

// Helper for debug-only logging
void _debugLog(String message) {
  if (kDebugMode) {
    print(message);
  }
}

/// Custom AudioHandler for VAS FM Radio background playback
class RadioAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  
  RadioAudioHandler() {
    // Listen to player state changes and update media session
    _player.playbackEventStream.listen((event) {
      _debugLog('🔊 Player state changed: ${event.processingState}, playing: ${_player.playing}');
      
      playbackState.add(PlaybackState(
        controls: [
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[event.processingState]!,
        playing: _player.playing,
        updatePosition: event.updatePosition,
        bufferedPosition: event.bufferedPosition,
      ));
      
      _debugLog('✅ PlaybackState updated - notification should show');
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      if (mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });
  }

  @override
  Future<void> play() async {
    _debugLog('⏱️ [PERF] AudioHandler.play() called');
    final playStartTime = DateTime.now();
    
    await _player.play();
    
    final playEndTime = DateTime.now();
    final playDuration = playEndTime.difference(playStartTime);
    _debugLog('⏱️ [PERF] AudioHandler.play() completed in: ${playDuration.inMilliseconds}ms');
    _debugLog('✅ Player playing state: ${_player.playing}');
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  /// Set the stream URL and start playing
  Future<void> setStreamUrl(String url, {String? title, String? artist, String? artUrl}) async {
    final setStreamStartTime = DateTime.now();
    _debugLog('⏱️ [PERF] setStreamUrl() called');
    
    final mediaItem = MediaItem(
      id: 'vas_fm_stream',
      title: title ?? 'VAS FM Online',
      artist: artist ?? 'VAS FM Radio',
      artUri: artUrl != null && artUrl.isNotEmpty ? Uri.parse(artUrl) : null,
      duration: Duration.zero,
    );
    
    // Set media item FIRST - this triggers the notification
    this.mediaItem.add(mediaItem);
    _debugLog('📱 MediaItem set: ${mediaItem.title} by ${mediaItem.artist}');

    // Pre-prepare the stream with optimized buffer settings
    await _player.setUrl(
      url,
      headers: {
        'User-Agent': 'VAS FM Radio App/1.1',
        'Icy-MetaData': '1',
      },
    );
    
    _debugLog('⏱️ [PERF] Stream URL set, calling play()...');
    
    // Start playback immediately after preparation
    await play();
    
    final setStreamEndTime = DateTime.now();
    final setStreamDuration = setStreamEndTime.difference(setStreamStartTime);
    _debugLog('⏱️ [PERF] setStreamUrl() total duration: ${setStreamDuration.inMilliseconds}ms');
  }
  
  /// Prepare the stream URL without playing (for pre-buffering)
  Future<void> prepareStream(String url, {String? title, String? artist, String? artUrl}) async {
    final prepareStartTime = DateTime.now();
    _debugLog('⏱️ [PERF] Pre-buffer preparation started at: ${prepareStartTime.toIso8601String()}');
    
    final mediaItem = MediaItem(
      id: 'vas_fm_stream',
      title: title ?? 'VAS FM Online',
      artist: artist ?? 'VAS FM Radio',
      artUri: artUrl != null && artUrl.isNotEmpty ? Uri.parse(artUrl) : null,
      duration: Duration.zero,
    );
    
    // Set media item
    this.mediaItem.add(mediaItem);
    _debugLog('📱 MediaItem set for pre-buffer: ${mediaItem.title}');

    await _player.setUrl(
      url,
      headers: {
        'User-Agent': 'VAS FM Radio App/1.1',
        'Icy-MetaData': '1',
      },
    );
    
    final prepareEndTime = DateTime.now();
    final prepareDuration = prepareEndTime.difference(prepareStartTime);
    _debugLog('⏱️ [PERF] Pre-buffer preparation completed in: ${prepareDuration.inMilliseconds}ms');
    print('✅ Stream pre-buffered and ready to play'); // Keep this one - important status
  }
}
