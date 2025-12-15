import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AudioProvider>(
        builder: (context, provider, _) {
          final song = provider.currentSong;
          if (song == null) {
            return const Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SafeArea(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < 0) {
                  provider.next();
                } else if (details.primaryVelocity! > 0) {
                  provider.previous();
                }
              },
              child: Column(
                children: [
                  _appBar(context, song),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimens.screenPadding,
                        ),
                        child: Column(
                          children: [
                            AlbumArt(
                              audioId: song.audioId,
                              path: song.albumArt, 
                              size: 260,
                            ),

                            const SizedBox(height: 32),

                            Text(
                              song.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Speed: ${provider.speed.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 24),

                            StreamBuilder(
                              stream: provider.playbackStateStream,
                              builder: (_, snapshot) {
                                final state = snapshot.data;
                                return ProgressBar(
                                  position:
                                      state?.position ?? Duration.zero,
                                  duration:
                                      state?.duration ?? Duration.zero,
                                  onSeek: provider.seek,
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            _mockVisualizer(),

                            const SizedBox(height: 24),

                            PlayerControls(provider: provider),

                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () =>
                                  _showLyrics(context),
                              child: const Text(
                                'Show Lyrics',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _appBar(BuildContext context, song) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Now Playing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share(
                'Listening to "${song.title}" by ${song.artist}',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLyrics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Lyrics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Lyrics are not available for this song.\n\n'
              'This feature will be supported in future versions:\n'
              '• Manual lyrics input\n'
              '• Synced lyrics\n'
              '• Online lyrics',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _mockVisualizer() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          16,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 4,
            height: 8 + (index % 5) * 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
