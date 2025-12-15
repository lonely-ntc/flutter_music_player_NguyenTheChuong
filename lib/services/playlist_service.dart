import 'package:on_audio_query/on_audio_query.dart' as audio_query;
import '../models/song_model.dart';

enum SongSortOption {
  title,
  artist,
  album,
  dateAdded,
}

class PlaylistService {
  final audio_query.OnAudioQuery _audioQuery =
      audio_query.OnAudioQuery();

  Future<List<SongModel>> getAllSongs({
    SongSortOption sort = SongSortOption.title,
  }) async {

    final hasPermission =
        await _audioQuery.permissionsStatus();
    if (!hasPermission) {
      await _audioQuery.permissionsRequest();
    }

    await _audioQuery.querySongs();

    audio_query.SongSortType sortType;

    switch (sort) {
      case SongSortOption.title:
        sortType = audio_query.SongSortType.TITLE;
        break;
      case SongSortOption.artist:
        sortType = audio_query.SongSortType.ARTIST;
        break;
      case SongSortOption.album:
        sortType = audio_query.SongSortType.ALBUM;
        break;
      case SongSortOption.dateAdded:
        sortType = audio_query.SongSortType.DATE_ADDED;
        break;
    }

    final songs = await _audioQuery.querySongs(
      sortType: sortType,
      orderType: audio_query.OrderType.ASC_OR_SMALLER,
      uriType: audio_query.UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs
        .map((audio) => SongModel.fromAudioQuery(audio))
        .toList();
  }

  Future<List<SongModel>> search(
    String query,
    List<SongModel> source,
  ) async {
    final q = query.toLowerCase();

    return source.where((song) {
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q) ||
          (song.album?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<SongModel> filterByArtist(
    String artist,
    List<SongModel> source,
  ) {
    return source.where((s) => s.artist == artist).toList();
  }

  List<SongModel> filterByAlbum(
    String album,
    List<SongModel> source,
  ) {
    return source.where((s) => s.album == album).toList();
  }
}
