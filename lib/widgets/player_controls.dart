import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _shuffleButton(),
            _repeatButton(),
          ],
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _secondaryButton(
              icon: Icons.skip_previous,
              onTap: provider.previous,
            ),

            const SizedBox(width: 24),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (_, snapshot) {
                final isPlaying = snapshot.data ?? false;

                return GestureDetector(
                  onTap: provider.playPause,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, 
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 24),

            _secondaryButton(
              icon: Icons.skip_next,
              onTap: provider.next,
            ),
          ],
        ),
      ],
    );
  }

  Widget _shuffleButton() {
    final enabled = provider.isShuffleEnabled;

    return IconButton(
      icon: Icon(
        Icons.shuffle,
        color: enabled
            ? AppColors.primary
            : AppColors.textSecondary,
      ),
      onPressed: provider.toggleShuffle,
    );
  }

  Widget _repeatButton() {
    IconData icon;
    Color color = AppColors.textSecondary;

    switch (provider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = AppColors.primary;
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = AppColors.primary;
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: provider.toggleRepeat,
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onTap,
      ),
    );
  }
}
