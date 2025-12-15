class PlaybackState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  PlaybackState({
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  double get progress =>
      duration.inMilliseconds == 0
          ? 0
          : position.inMilliseconds / duration.inMilliseconds;
}
