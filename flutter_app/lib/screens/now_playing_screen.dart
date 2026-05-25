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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6A229C),
              const Color(0xFF5A1D87),
              const Color(0xFF371348),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error icon with animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.radio_rounded,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Error message
                  Text(
                    'Unable to Connect',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Retry button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Standalone mode - just restart the app
                      print('🔄 Restarting player...');
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart Player'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A229C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Help text
                  Text(
                    'Check your internet connection and try again',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerUI extends StatefulWidget {
  final RadioProvider radioProvider;

  const _PlayerUI({required this.radioProvider});

  @override
  State<_PlayerUI> createState() => _PlayerUIState();
}

class _PlayerUIState extends State<_PlayerUI> {
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
        child: RefreshIndicator(
          onRefresh: () async {
            // Standalone mode - no config reload needed
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Player refreshed (standalone mode)'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header with Connection Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Connection Status Indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.radioProvider.error == null
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (widget.radioProvider.error == null
                                        ? Colors.green
                                        : Colors.red)
                                    .withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.radioProvider.error == null
                              ? 'Online'
                              : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.radioProvider.error == null
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
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
                const SizedBox(height: 16),
                // Now Playing Title
                Text(
                  'Now Playing',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6A229C),
                      ),
                ),
                const SizedBox(height: 24),
                // Album Art
              Expanded(
                flex: 3,
                child: _AlbumArt(
                  key: ValueKey(widget.radioProvider.config?.albumArtUrl),
                  albumArtUrl: widget.radioProvider.config?.albumArtUrl,
                ),
              ),
              const SizedBox(height: 40),
              // Station Info
              Text(
                widget.radioProvider.config?.stationName ?? 'Unknown Station',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6A229C),
                    ),
                textAlign: TextAlign.center,
              ),
              if (widget.radioProvider.config?.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.radioProvider.config!.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF34380E),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              // Play/Pause Button
              _PlayPauseButton(radioProvider: widget.radioProvider),
              const SizedBox(height: 16),
              // Sleep Timer Button
              Center(
                child: TextButton.icon(
                  onPressed: () => _showSleepTimerDialog(context),
                  icon: Icon(
                    widget.radioProvider.isSleepTimerActive
                        ? Icons.timer_off
                        : Icons.timer,
                    size: 20,
                  ),
                  label: Text(
                    widget.radioProvider.isSleepTimerActive
                        ? 'Stop Timer'
                        : 'Sleep Timer',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6A229C),
                  ),
                ),
              ),
            ],  // Close Column children
          ),  // Close Column
        ),  // Close Padding
      ),  // Close RefreshIndicator
    ),  // Close SafeArea
  );  // Close Container
}
  
  void _showSleepTimerDialog(BuildContext context) {
    if (widget.radioProvider.isSleepTimerActive) {
      // Stop timer
      widget.radioProvider.stopSleepTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ Sleep timer stopped'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Show timer options
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Set Sleep Timer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              _buildTimerOption(context, Duration(minutes: 15), '15 Minutes'),
              _buildTimerOption(context, Duration(minutes: 30), '30 Minutes'),
              _buildTimerOption(context, Duration(minutes: 45), '45 Minutes'),
              _buildTimerOption(context, Duration(minutes: 60), '1 Hour'),
              _buildTimerOption(context, Duration(minutes: 90), '1.5 Hours'),
              _buildTimerOption(context, Duration(minutes: 120), '2 Hours'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildTimerOption(BuildContext context, Duration duration, String label) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        widget.radioProvider.startSleepTimer(duration);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏰ Sleep timer set for $label'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final String? albumArtUrl;

  const _AlbumArt({super.key, this.albumArtUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
                width: double.infinity,
                height: double.infinity,
                memCacheWidth: 800,
                memCacheHeight: 800,
                maxWidthDiskCache: 800,
                maxHeightDiskCache: 800,
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
