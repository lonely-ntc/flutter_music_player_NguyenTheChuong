import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../utils/constants.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (_, provider, __) {
        final song = provider.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NowPlayingScreen(),
              ),
            );
          },
          child: Container(
            height: AppDimens.miniPlayerHeight, 
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
            ),
            decoration: const BoxDecoration(
              color: AppColors.card,
            ),
            child: Row(
              children: [
                _albumArt(song.audioId),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                StreamBuilder<bool>(
                  stream: provider.playingStream,
                  builder: (_, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: provider.playPause,
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: provider.next,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _albumArt(int audioId) {
    return audio_query.QueryArtworkWidget(
      id: audioId,
      type: audio_query.ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      artworkBorder:
          BorderRadius.circular(AppDimens.albumRadius),
      nullArtworkWidget: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius:
              BorderRadius.circular(AppDimens.albumRadius),
        ),
        child: const Icon(
          Icons.music_note,
          color: Colors.grey,
        ),
      ),
    );
  }
}
