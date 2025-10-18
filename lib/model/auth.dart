// lib/model/auth.dart

class AuthRequest {
  final String email;
  final String password;
  AuthRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    "email": email.trim(),
    "password": password,
  };
}

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String status;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.status,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j["id"] as int,
    username: j["username"] as String,
    email: j["email"] as String,
    role: (j["role"] ?? "user") as String,
    status: (j["status"] ?? "active") as String,
    lastLogin: j["last_login"] != null ? DateTime.parse(j["last_login"]) : null,
    createdAt: DateTime.parse(j["created_at"]),
    updatedAt: DateTime.parse(j["updated_at"]),
  );
}

class AuthResponse {
  final String token; // JWT
  final User user;
  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> j) =>
      AuthResponse(token: j["token"], user: User.fromJson(j["user"]));
}
