import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../utils/constants.dart';

class AlbumArt extends StatelessWidget {

  final int? audioId;
  final String? path;
  final double size;
  const AlbumArt({
    super.key,
    this.audioId,
    this.path,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimens.albumRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.albumRadius),
        child: _buildArtwork(),
      ),
    );
  }

  Widget _buildArtwork() {
    if (audioId != null) {
      return QueryArtworkWidget(
        id: audioId!,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        nullArtworkWidget: _fallbackIcon(),
      );
    }

    if (path != null && File(path!).existsSync()) {
      return Image.file(
        File(path!),
        fit: BoxFit.cover,
      );
    }

    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(
        Icons.music_note,
        color: Colors.grey,
        size: 80,
      ),
    );
  }
}
