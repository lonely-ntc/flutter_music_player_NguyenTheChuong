import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audio;
  final StorageService _storage;

  AudioProvider(this._audio, this._storage) {
    _init();
  }


  List<SongModel> _playlist = [];
  int _currentIndex = 0;

  bool _shuffle = false;
  LoopMode _loopMode = LoopMode.off;

  Timer? _sleepTimer;
  Timer? _fadeTimer;

  double _volume = 1.0;
  double _speed = 1.0;

  final Map<String, List<double>> _eqPresets = {
    'Normal': [0, 0, 0, 0, 0],
    'Bass Boost': [5, 3, 0, -1, -2],
    'Rock': [3, 2, -1, 2, 3],
    'Pop': [-1, 2, 4, 2, -1],
    'Jazz': [2, 3, 1, 2, 3],
  };

  String _currentPreset = 'Normal';
  List<double> _customEQ = [0, 0, 0, 0, 0];


  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  bool get isShuffleEnabled => _shuffle;
  LoopMode get loopMode => _loopMode;

  double get volume => _volume;
  double get speed => _speed;

  Map<String, List<double>> get eqPresets => _eqPresets;
  String get currentPreset => _currentPreset;
  List<double> get customEQ => _customEQ;

  Stream<PlaybackState> get playbackStateStream =>
      _audio.playbackStateStream;
  Stream<bool> get playingStream => _audio.playingStream;

  Future<void> _init() async {
    _shuffle = await _storage.loadShuffle();
    _loopMode = LoopMode.values[await _storage.loadRepeat()];
    _volume = await _storage.loadVolume();

    await _audio.setLoopMode(_loopMode);
    await _audio.setVolume(_volume);
    await _audio.setShuffle(_shuffle);
    _audio.positionStream.listen((pos) {
      _storage.saveLastPosition(pos);
    });
  }

  Future<void> restoreSession(List<SongModel> allSongs) async {
    final lastId = await _storage.loadLastSong();
    final lastPos = await _storage.loadLastPosition();

    if (lastId == null) return;

    final index = allSongs.indexWhere((s) => s.id == lastId);
    if (index == -1) return;

    _playlist = allSongs;
    _currentIndex = index;

    await _audio.setQueue(
      _playlist.map((s) => s.filePath).toList(),
      startIndex: index,
    );

    await _audio.seek(lastPos);
    notifyListeners();
  }

  Future<void> setPlaylist(List<SongModel> songs, int index) async {
    _playlist = songs;
    _currentIndex = index;

    await _audio.setQueue(
      songs.map((s) => s.filePath).toList(),
      startIndex: index,
    );

    await _audio.play();
    await _storage.saveLastSong(songs[index].id);
    notifyListeners();
  }

  Future<void> playPause() async {
    _audio.isPlaying ? await _audio.pause() : await _audio.play();
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_shuffle) {
      _currentIndex =
          DateTime.now().millisecondsSinceEpoch % _playlist.length;
      await setPlaylist(_playlist, _currentIndex);
    } else {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
        await _audio.next();
      } else if (_loopMode == LoopMode.all) {
        _currentIndex = 0;
        await setPlaylist(_playlist, 0);
      }
    }

    notifyListeners();
  }

  Future<void> previous() async {
    if (_audio.position.inSeconds > 3) {
      await _audio.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      await _audio.previous();
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = _playlist.length - 1;
      await setPlaylist(_playlist, _currentIndex);
    }

    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audio.seek(position);
  }


  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await _audio.setShuffle(_shuffle);
    await _storage.saveShuffle(_shuffle);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    _loopMode = LoopMode.values[(_loopMode.index + 1) % 3];
    await _audio.setLoopMode(_loopMode);
    await _storage.saveRepeat(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _audio.setVolume(_volume);
    await _storage.saveVolume(_volume);
    notifyListeners();
  }

  Future<void> setSpeed(double value) async {
    _speed = value.clamp(0.5, 2.0);
    await _audio.setSpeed(_speed);
    notifyListeners();
  }


  void startSleepTimer(Duration duration,
      {Duration fadeDuration = const Duration(seconds: 5)}) {
    cancelSleepTimer();
    _sleepTimer = Timer(duration, () {
      _fadeOutAndPause(fadeDuration);
    });
  }

  void _fadeOutAndPause(Duration fadeDuration) {
    double currentVol = _volume;
    const stepMs = 300;
    final steps =
        (fadeDuration.inMilliseconds / stepMs).ceil().clamp(1, 100);
    final delta = currentVol / steps;

    _fadeTimer?.cancel();
    _fadeTimer =
        Timer.periodic(const Duration(milliseconds: stepMs), (t) {
      currentVol -= delta;
      if (currentVol <= 0) {
        _audio.pause();
        _audio.setVolume(1.0);
        t.cancel();
      } else {
        _audio.setVolume(currentVol);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _sleepTimer = null;
    _fadeTimer = null;
  }

  void setPreset(String name) {
    if (!_eqPresets.containsKey(name)) return;
    _currentPreset = name;
    _customEQ = List<double>.from(_eqPresets[name]!);
    notifyListeners();
  }

  void setCustomBand(int index, double value) {
    if (index < 0 || index >= _customEQ.length) return;
    _customEQ[index] = value;
    _currentPreset = 'Custom';
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
