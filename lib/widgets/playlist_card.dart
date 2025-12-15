import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../utils/constants.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(Icons.queue_music,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "${playlist.songIds.length} songs",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
