import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class AllSongsScreen extends StatelessWidget {
  final List<SongModel> songs;

  const AllSongsScreen({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Songs')),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (_, i) => SongTile(
          song: songs[i],
          onTap: () =>
              context.read<AudioProvider>().setPlaylist(songs, i),
        ),
      ),
    );
  }
}
