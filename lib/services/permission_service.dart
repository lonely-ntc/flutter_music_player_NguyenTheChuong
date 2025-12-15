import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMusicPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.isGranted) return true;

      final status = await Permission.audio.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;

      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestAll() async {
    if (Platform.isAndroid) {
      final audio = await requestMusicPermission();
      final storage = await requestStoragePermission();
      return audio || storage;
    }
    return true;
  }
}
