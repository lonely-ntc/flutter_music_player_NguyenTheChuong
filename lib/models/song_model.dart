class SongModel {
  final int audioId;
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final int? fileSize;
  final String? albumArt;
  bool isFavorite;
  String? lyrics;

  SongModel({
    required this.audioId,
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.albumArt,
    this.fileSize,
    this.isFavorite = false,
    this.lyrics,
  });


  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      audioId: json['audioId'],
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      filePath: json['filePath'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      albumArt: json['albumArt'],
      fileSize: json['fileSize'],

      isFavorite: json['isFavorite'] ?? false,
      lyrics: json['lyrics'],
    );
  }

  Map<String, dynamic> toJson() => {
        'audioId': audioId,
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'filePath': filePath,
        'duration': duration?.inMilliseconds,
        'albumArt': albumArt,
        'fileSize': fileSize,
        'isFavorite': isFavorite,
        'lyrics': lyrics,
      };


  factory SongModel.fromAudioQuery(dynamic audio) {
    return SongModel(
      audioId: audio.id,             
      id: audio.id.toString(),           
      title: audio.title,
      artist: audio.artist ?? 'Unknown Artist',
      album: audio.album,
      filePath: audio.data,
      duration: Duration(milliseconds: audio.duration ?? 0),
      fileSize: audio.size,
      isFavorite: false,
      lyrics: null,
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  bool get hasLyrics =>
      lyrics != null && lyrics!.trim().isNotEmpty;
}
