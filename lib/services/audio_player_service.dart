import 'dart:async';
import 'package:flutter/foundation.dart'; 
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerService() {
    _configurePlayer();
  }

  void _configurePlayer() {
    _player.setAudioSource(
      ConcatenatingAudioSource(children: []),
      preload: true,
    );
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<PlaybackState> get playbackStateStream =>
      Rx.combineLatest3<Duration, Duration?, bool, PlaybackState>(
        positionStream,
        durationStream,
        playingStream,
        (position, duration, isPlaying) {
          return PlaybackState(
            position: position,
            duration: duration ?? Duration.zero,
            isPlaying: isPlaying,
          );
        },
      );


  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  double get volume => _player.volume;
  double get speed => _player.speed;
  LoopMode get loopMode => _player.loopMode;

  Future<void> loadAudio(String path) async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.file(path)),
        preload: true,
      );
    } catch (e) {
      debugPrint('Audio load error: $e');
    }
  }

  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();
  Future<void> stop() async => _player.stop();

  Future<void> seek(Duration position) async {
    if (duration == null) return;

    final safePosition = position > duration!
        ? duration!
        : position < Duration.zero
            ? Duration.zero
            : position;

    await _player.seek(safePosition);
  }

  Future<void> setQueue(List<String> paths, {int startIndex = 0}) async {
    final sources = paths
        .map((p) => AudioSource.uri(Uri.file(p)))
        .toList();

    final playlist = ConcatenatingAudioSource(children: sources);

    await _player.setAudioSource(
      playlist,
      initialIndex: startIndex,
      preload: true,
    );
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> previous() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Timer? _sleepTimer;
  Timer? _fadeTimer;

  void startSleepTimer({
    required Duration duration,
    Duration fadeDuration = const Duration(seconds: 5),
  }) {
    cancelSleepTimer();
    _sleepTimer = Timer(duration, () {
      _fadeOutAndPause(fadeDuration);
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _sleepTimer = null;
    _fadeTimer = null;
  }

  void _fadeOutAndPause(Duration fadeDuration) {
    double currentVolume = _player.volume;
    const stepMs = 300;

    final steps =
        (fadeDuration.inMilliseconds / stepMs).ceil().clamp(1, 100);
    final delta = currentVolume / steps;

    _fadeTimer = Timer.periodic(
      const Duration(milliseconds: stepMs),
      (timer) {
        currentVolume -= delta;
        if (currentVolume <= 0) {
          _player.setVolume(0);
          _player.pause();
          _player.setVolume(1.0);
          timer.cancel();
        } else {
          _player.setVolume(currentVolume);
        }
      },
    );
  }

  Future<void> normalizeVolume() async {
    await _player.setVolume(0.85);
  }

  void dispose() {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _player.dispose();
  }
}
