import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();
  final PlaylistService _playlistService = PlaylistService();

  List<SongModel> _allSongs = [];
  List<SongModel> _visibleSongs = [];

  bool _loading = true;
  bool _hasPermission = false;

  SongSortOption _sort = SongSortOption.title;
  bool _showFavoritesOnly = false;
  final Set<String> _favoriteIds = {};
  final Map<String, Set<String>> _userAlbums = {};
  String? _selectedUserAlbum;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLibrary();
    }
  }

  Future<void> _init() async {
    setState(() => _loading = true);

    _hasPermission = await _permissionService.requestAll();
    if (_hasPermission) {
      await _refreshLibrary(restoreSession: true);
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshLibrary({bool restoreSession = false}) async {
    final result =
        await _playlistService.getAllSongs(sort: _sort);

    _allSongs = List<SongModel>.from(result);
    _applyFilters();

    if (restoreSession && mounted) {
      await context
          .read<AudioProvider>()
          .restoreSession(_allSongs);
    }

    if (mounted) setState(() {});
  }

  void _applyFilters() {
    List<SongModel> result = List.from(_allSongs);

    if (_showFavoritesOnly) {
      result =
          result.where((s) => _favoriteIds.contains(s.id)).toList();
    }

    if (_sort == SongSortOption.album && _selectedUserAlbum != null) {
      final ids = _userAlbums[_selectedUserAlbum] ?? {};
      result = result.where((s) => ids.contains(s.id)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            (s.album ?? '').toLowerCase().contains(q);
      }).toList();
    }

    _visibleSongs = result;
  }

  Future<void> _onSort(SongSortOption option) async {
    setState(() {
      _sort = option;
      _selectedUserAlbum = null;
    });
    await _refreshLibrary();
  }

  Future<void> _addSongToAlbum(SongModel song) async {
    final controller = TextEditingController();

    final selectedAlbum = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add to Album'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_userAlbums.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView(
                    children: _userAlbums.keys.map((album) {
                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(album),
                        subtitle: Text(
                          '${_userAlbums[album]!.length} songs',
                        ),
                        onTap: () =>
                            Navigator.pop(context, album),
                      );
                    }).toList(),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No albums yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              const Divider(),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Create new album',
                  hintText: 'Album name',
                  prefixIcon: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (selectedAlbum == null || selectedAlbum.isEmpty) return;

    setState(() {
      _userAlbums.putIfAbsent(selectedAlbum, () => <String>{});
      _userAlbums[selectedAlbum]!.add(song.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to album "$selectedAlbum"'),
      ),
    );
  }

  void _removeSongFromAlbum(SongModel song) {
    if (_selectedUserAlbum == null) return;

    setState(() {
      _userAlbums[_selectedUserAlbum]!.remove(song.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            _sortBar(),
            _searchBar(),
            Expanded(child: _content()),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: Row(
        children: [
          const Text(
            'My Music',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
                  _showFavoritesOnly ? Colors.redAccent : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
                _applyFilters();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _sortChip('Title', SongSortOption.title),
          _sortChip('Artist', SongSortOption.artist),
          _sortChip('Album', SongSortOption.album),
          _sortChip('Date', SongSortOption.dateAdded),
        ],
      ),
    );
  }

  Widget _sortChip(String label, SongSortOption option) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _sort == option,
        onSelected: (_) => _onSort(option),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search song, artist, album',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: UnderlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return const Center(
        child: Text(
          'Permission required',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (_sort == SongSortOption.album &&
        _selectedUserAlbum == null) {
      if (_userAlbums.isEmpty) {
        return const Center(
          child: Text(
            'No albums created',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return ListView(
        children: _userAlbums.keys.map((album) {
          final ids = _userAlbums[album]!;
          return ListTile(
            leading:
                const Icon(Icons.folder, color: Colors.white),
            title: Text(album,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${ids.length} songs',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              setState(() {
                _selectedUserAlbum = album;
                _applyFilters();
              });
            },
            onLongPress: () {
              context.read<AudioProvider>().setPlaylist(
                    _allSongs
                        .where((s) => ids.contains(s.id))
                        .toList(),
                    0,
                  );
            },
          );
        }).toList(),
      );
    }

    return ListView.builder(
      itemCount: _visibleSongs.length,
      itemBuilder: (_, i) {
        final song = _visibleSongs[i];

        return SongTile(
          song: song,
          isFavorite: _favoriteIds.contains(song.id),
          onTap: () {
            context
                .read<AudioProvider>()
                .setPlaylist(_visibleSongs, i);
          },
          onLongPress: () {
            setState(() {
              _favoriteIds.contains(song.id)
                  ? _favoriteIds.remove(song.id)
                  : _favoriteIds.add(song.id);
            });
          },
          onAddToAlbum: () => _addSongToAlbum(song),
          onRemoveFromAlbum:
              _selectedUserAlbum != null
                  ? () => _removeSongFromAlbum(song)
                  : null,
        );
      },
    );
  }
}
