class DurationFormatter {
  static String format(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(duration.inMinutes.remainder(60));
    final s = two(duration.inSeconds.remainder(60));
    return "$m:$s";
  }
}
