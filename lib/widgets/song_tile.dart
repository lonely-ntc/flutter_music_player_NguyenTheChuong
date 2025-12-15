import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final VoidCallback? onAddToAlbum;
  final VoidCallback? onRemoveFromAlbum;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onLongPress,
    this.isFavorite = false,
    this.onAddToAlbum,
    this.onRemoveFromAlbum,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      leading: _albumArt(),

      title: Text(
        song.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(
        song.artist,
        style: const TextStyle(color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),

      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _albumArt() {
    return audio_query.QueryArtworkWidget(
      id: song.audioId,
      type: audio_query.ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      size: 200,
      artworkBorder: BorderRadius.circular(6),
      nullArtworkWidget: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.music_note, color: Colors.grey),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionTile(
              icon: Icons.play_arrow,
              title: 'Play now',
              onTap: () {
                Navigator.pop(context);
                _playNow(context);
              },
            ),

            _optionTile(
              icon: isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              title: isFavorite
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(context);
              },
            ),

            if (onAddToAlbum != null)
              _optionTile(
                icon: Icons.folder,
                title: 'Add to Album',
                onTap: () {
                  Navigator.pop(context);
                  onAddToAlbum!.call();
                },
              ),

            if (onRemoveFromAlbum != null)
              _optionTile(
                icon: Icons.remove_circle_outline,
                title: 'Remove from Album',
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromAlbum!.call();
                },
              ),

            _divider(),

            _optionTile(
              icon: Icons.person,
              title: 'View Artist',
              onTap: () {
                Navigator.pop(context);
                _viewArtist(context);
              },
            ),

            _optionTile(
              icon: Icons.share,
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                _shareSong();
              },
            ),

            _optionTile(
              icon: Icons.bar_chart,
              title: 'Song statistics',
              onTap: () {
                Navigator.pop(context);
                _showStats(context);
              },
            ),

            _optionTile(
              icon: Icons.code,
              title: 'Export song info (JSON)',
              onTap: () {
                Navigator.pop(context);
                _exportJson(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(color: Colors.grey);

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  void _playNow(BuildContext context) {
    context.read<AudioProvider>().setPlaylist([song], 0);
  }

  void _toggleFavorite(BuildContext context) {
    onLongPress?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Removed from Favorites'
              : 'Added to Favorites',
        ),
      ),
    );
  }

  void _viewArtist(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Artist: ${song.artist}'),
      ),
    );
  }

  void _shareSong() {
    Share.share(
      'Listening to "${song.title}" by ${song.artist}',
    );
  }

  void _showStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Song Statistics',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Title: ${song.title}\n'
          'Artist: ${song.artist}\n'
          'Duration: ${_format(song.duration)}\n'
          'File size: ${song.fileSize ?? 'Unknown'}\n\n'
          'Play count: ${_mockPlayCount()}',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _mockPlayCount() => song.id.hashCode % 100;

  String _format(Duration? d) {
    if (d == null) return '--:--';
    final m =
        d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s =
        d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _exportJson(BuildContext context) {
    final jsonStr = jsonEncode(song.toJson());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Export Song Info',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            jsonStr,
            style:
                const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Share.share(jsonStr);
              Navigator.pop(context);
            },
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
