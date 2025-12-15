import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds
        .clamp(0, max > 0 ? max : 0)
        .toDouble();

    if (max <= 0) {
      return const SizedBox(height: 24);
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey.shade800,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.3),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: max,
            onChanged: (v) {
              onSeek(Duration(milliseconds: v.toInt()));
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeText(position),
              _timeText(duration),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeText(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return Text(
      '$m:$s',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    );
  }
}
