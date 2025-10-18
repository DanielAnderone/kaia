import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/auth.dart';

class AuthService {
  final String baseUrl;
  AuthService({required this.baseUrl});

  /// LOGIN
  Future<AuthResponse> login(AuthRequest req) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/login');
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(req.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final auth = AuthResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', auth.token);
      await prefs.setString('user_email', auth.user.email);
      await prefs.setInt('user_id', auth.user.id);
      return auth;
    }

    String msg = 'Falha ao autenticar';
    try {
      final err = jsonDecode(res.body);
      if (err is Map && err['message'] is String) msg = err['message'];
    } catch (_) {}
    throw Exception(msg);
  }

  /// REGISTRO DE NOVO USUÁRIO
  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
    String? status, // ativo, inativo ou omitido
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/register');
    final payload = {
      "username": username.trim(),
      "email": email.trim(),
      "password": password,
      if (status != null) "status": status,
    };

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return true;

    String msg = 'Falha ao criar conta';
    try {
      final err = jsonDecode(res.body);
      if (err is Map && err['message'] is String) msg = err['message'];
    } catch (_) {}
    throw Exception(msg);
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }
}
