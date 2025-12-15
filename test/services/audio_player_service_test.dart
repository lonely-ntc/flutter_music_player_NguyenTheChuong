import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

import 'package:offline_music_player/services/audio_player_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerService Tests', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
    });

    test('Initial state is not playing', () {
      expect(service.isPlaying, false);
    });

    test('Set volume works correctly', () async {
      await service.setVolume(0.5);
      expect(service.volume, closeTo(0.5, 0.01));
    });

    test('Set playback speed does not throw', () async {
      await service.setSpeed(1.5);
      expect(true, true); // no exception
    });

    test('Loop mode can be set', () async {
      await service.setLoopMode(LoopMode.one);
      expect(true, true);
    });

    test('Seek does not throw', () async {
      await service.seek(const Duration(seconds: 10));
      expect(true, true);
    });

    test('Sleep timer can be started and cancelled', () async {
      service.startSleepTimer(
        duration: const Duration(seconds: 1),
      );

      service.cancelSleepTimer();
      expect(true, true);
    });

    tearDown(() {
      service.dispose();
    });
  });
}
