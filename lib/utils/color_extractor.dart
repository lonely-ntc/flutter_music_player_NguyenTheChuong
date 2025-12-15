import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color> getDominantColor(String? imagePath) async {
    try {
      if (imagePath == null || !File(imagePath).existsSync()) {
        return const Color(0xFF191414); 
      }

      final PaletteGenerator palette =
          await PaletteGenerator.fromImageProvider(
        FileImage(File(imagePath)),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

      return palette.dominantColor?.color ??
          const Color(0xFF191414);
    } catch (_) {
      return const Color(0xFF191414);
    }
  }

  static Future<Color> getAccentColor(String? imagePath) async {
    try {
      if (imagePath == null || !File(imagePath).existsSync()) {
        return const Color(0xFF1DB954); 
      }

      final PaletteGenerator palette =
          await PaletteGenerator.fromImageProvider(
        FileImage(File(imagePath)),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

      return palette.vibrantColor?.color ??
          const Color(0xFF1DB954);
    } catch (_) {
      return const Color(0xFF1DB954);
    }
  }
  
}
