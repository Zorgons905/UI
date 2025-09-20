class User {
  final int? id;
  final int userId;
  final String username;
  final String language;
  final String colorTheme;
  final String randomAvatar;
  final String createdAt;

  User({
    this.id,
    required this.userId,
    required this.username,
    required this.language,
    required this.colorTheme,
    required this.randomAvatar,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      userId: map['user_id'],
      username: map['username'],
      language: map['language'],
      colorTheme: map['color_preference'],
      randomAvatar: map['random_avatar'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'language': language,
      'color_theme': colorTheme,
      'random_avatar': randomAvatar,
      'created_at': createdAt,
    };
  }
}
