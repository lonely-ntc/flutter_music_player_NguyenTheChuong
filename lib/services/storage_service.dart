import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist_model.dart';

class StorageService {
  static const _playlistKey = 'playlists';
  static const _lastSongKey = 'last_song';
  static const _lastPositionKey = 'last_position';
  static const _shuffleKey = 'shuffle';
  static const _repeatKey = 'repeat';
  static const _volumeKey = 'volume';
  static const _recentKey = 'recent_songs';

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final data = playlists.map((e) => e.toJson()).toList();
    await prefs.setString(_playlistKey, jsonEncode(data));
  }

  Future<List<PlaylistModel>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistKey);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => PlaylistModel.fromJson(e)).toList();
  }

  Future<void> saveLastSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSongKey, songId);
  }

  Future<String?> loadLastSong() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSongKey);
  }

  Future<void> saveLastPosition(Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
  }

  Future<Duration> loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return Duration(
      milliseconds: prefs.getInt(_lastPositionKey) ?? 0,
    );
  }

  Future<void> saveShuffle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, value);
  }

  Future<bool> loadShuffle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeat(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode);
  }

  Future<int> loadRepeat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatKey) ?? 0;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  Future<void> addRecent(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentKey) ?? [];
    list.remove(songId);
    list.insert(0, songId);
    if (list.length > 20) list.removeLast();
    await prefs.setStringList(_recentKey, list);
  }

  Future<List<String>> loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? [];
  }
}
