class User {
  final int id;
  final String email;
  final String username;
  final int isWhite;
  final int? createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.isWhite = 0,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      isWhite: json['is_white'] ?? 0,
      createdAt: json['created_at'],
    );
  }
}

class AuthResult {
  final String accessToken;
  final int expiresIn;
  final User user;

  AuthResult({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['access_token'] ?? '',
      expiresIn: json['expires_in'] ?? 604800,
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
