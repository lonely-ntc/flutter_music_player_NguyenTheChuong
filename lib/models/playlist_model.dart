class PlaylistModel {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImage;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImage,
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverImage,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? List<String>.from(this.songIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImage: coverImage ?? this.coverImage,
    );
  }


  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'],
      name: json['name'],
      songIds: List<String>.from(json['songIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      coverImage: json['coverImage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'coverImage': coverImage,
      };
}
