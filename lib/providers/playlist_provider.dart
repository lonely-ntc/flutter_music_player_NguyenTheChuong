import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  List<PlaylistModel> _playlists = [];

  List<PlaylistModel> get playlists => _playlists;

  PlaylistProvider() {
    _init();
  }


  Future<void> _init() async {
    await _load();
  }

  Future<void> _load() async {
    try {
      _playlists = await _storage.loadPlaylists();
    } catch (_) {
      _playlists = [];
    }
    notifyListeners();
  }


  PlaylistModel? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SongModel> getSongsOfPlaylist(
    String playlistId,
    List<SongModel> allSongs,
  ) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return [];

    return allSongs
        .where((s) => playlist.songIds.contains(s.id))
        .toList();
  }

  Future<void> createPlaylist(String name) async {
    if (name.trim().isEmpty) return;

    final playlist = PlaylistModel(
      id: _uuid.v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(playlist);
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSong(String playlistId, SongModel song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    if (playlist.songIds.contains(song.id)) return;

    _update(
      index,
      playlist.copyWith(
        songIds: [...playlist.songIds, song.id],
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeSong(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];

    _update(
      index,
      playlist.copyWith(
        songIds:
            playlist.songIds.where((id) => id != songId).toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> renamePlaylist(String id, String newName) async {
    if (newName.trim().isEmpty) return;

    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _update(
      index,
      _playlists[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      ),
    );
  }
  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    final songs = List<String>.from(playlist.songIds);

    if (oldIndex < 0 ||
        oldIndex >= songs.length ||
        newIndex < 0 ||
        newIndex > songs.length) return;

    if (newIndex > oldIndex) newIndex -= 1;

    final item = songs.removeAt(oldIndex);
    songs.insert(newIndex, item);

    _update(
      index,
      playlist.copyWith(
        songIds: songs,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> clearPlaylist(String playlistId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    _update(
      index,
      _playlists[index].copyWith(
        songIds: [],
        updatedAt: DateTime.now(),
      ),
    );
  }

  String exportPlaylist(String playlistId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return '{}';
    return jsonEncode(playlist.toJson());
  }


  Map<String, dynamic> getPlaylistStats(
    String playlistId,
    List<SongModel> allSongs,
  ) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) {
      return {
        'songCount': 0,
        'totalDuration': Duration.zero,
      };
    }

    final songs = allSongs
        .where((s) => playlist.songIds.contains(s.id))
        .toList();

    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + (s.duration ?? Duration.zero),
    );

    return {
      'songCount': songs.length,
      'totalDuration': totalDuration,
      'createdAt': playlist.createdAt,
      'updatedAt': playlist.updatedAt,
    };
  }

  Future<void> _update(int index, PlaylistModel playlist) async {
    _playlists[index] = playlist;
    await _storage.savePlaylists(_playlists);
    notifyListeners();
  }
}

extension PlaylistModelCopy on PlaylistModel {
  PlaylistModel copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverImage,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
