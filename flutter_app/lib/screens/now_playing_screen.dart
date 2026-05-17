import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import 'about_screen.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RadioProvider>(
        builder: (context, radioProvider, child) {
          // Show loading state
          if (radioProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error state
          if (radioProvider.error != null) {
            return _ErrorState(error: radioProvider.error!);
          }

          // Show player UI
          return _PlayerUI(radioProvider: radioProvider);
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RadioProvider>().fetchConfig(
                        const String.fromEnvironment(
                          'API_URL',
                          defaultValue: 'http://172.20.10.3:3000',
                        ),
                      );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerUI extends StatelessWidget {
  final RadioProvider radioProvider;

  const _PlayerUI({required this.radioProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6A229C).withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.4],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Now Playing',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6A229C),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Album Art
              Expanded(
                flex: 3,
                child: _AlbumArt(albumArtUrl: radioProvider.config?.albumArtUrl),
              ),
              const SizedBox(height: 40),
              // Station Info
              Text(
                radioProvider.config?.stationName ?? 'Unknown Station',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6A229C),
                    ),
                textAlign: TextAlign.center,
              ),
              if (radioProvider.config?.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  radioProvider.config!.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF34380E),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              // Play/Pause Button
              _PlayPauseButton(radioProvider: radioProvider),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final String? albumArtUrl;

  const _AlbumArt({this.albumArtUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: albumArtUrl != null && albumArtUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: albumArtUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => _PlaceholderArt(),
              )
            : _PlaceholderArt(),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: const Color(0xFF6A229C).withOpacity(0.5),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final RadioProvider radioProvider;

  const _PlayPauseButton({required this.radioProvider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => radioProvider.togglePlayPause(),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFCDE2B),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFCDE2B).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: _buildPlayPauseIcon(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseIcon(BuildContext context) {
    if (radioProvider.isBuffering) {
      return const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A229C)),
        ),
      );
    }

    return Icon(
      radioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
      size: 50,
      color: const Color(0xFF6A229C),
    );
  }
}
