import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';

class PlaylistScreen extends StatelessWidget {
  final List<SongModel> songs;

  const PlaylistScreen({
    super.key,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Playlists'),
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, _) {
          final playlists = provider.playlists;

          if (playlists.isEmpty) {
            return const Center(
              child: Text(
                'No playlists yet',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _createPlaylist(context),
                  child: const Text('Create Playlist'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return PlaylistCard(
                      playlist: playlist,
                      onTap: () {
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createPlaylist(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<PlaylistProvider>()
                  .createPlaylist(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
