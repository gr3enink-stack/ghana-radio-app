import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Custom AudioHandler for VAS FM Radio background playback
class RadioAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  
  RadioAudioHandler() {
    // Listen to player state changes and update media session
    _player.playbackEventStream.listen((event) {
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.pause,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
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
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      if (mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  /// Set the stream URL and start playing
  Future<void> setStreamUrl(String url, {String? title, String? artist, String? artUrl}) async {
    mediaItem.add(MediaItem(
      id: 'vas_fm_stream',
      title: title ?? 'VAS FM Online',
      artist: artist ?? 'VAS FM Radio',
      artUri: artUrl != null && artUrl.isNotEmpty ? Uri.parse(artUrl) : null,
      duration: Duration.zero,
    ));

    await _player.setUrl(
      url,
      headers: {
        'User-Agent': 'VAS FM Radio App/1.1',
        'Icy-MetaData': '1',
      },
    );
    
    await play();
  }
}
