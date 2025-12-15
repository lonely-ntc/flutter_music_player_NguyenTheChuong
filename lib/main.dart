import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioService = AudioPlayerService();
  final storageService = StorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
