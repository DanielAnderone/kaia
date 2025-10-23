import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/auth.dart';

class SesManager {
  static const _jwtToken = 'jwt_token';
  static const _payload = 'payload';

  static Future<void> setPayload(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(user.toJson());
      await prefs.setString(_payload, jsonString);
    } catch (e) {
      throw Exception('Erro ao salvar payload: $e');
    }
  }

  static Future<User> getPayload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_payload);
      if (jsonString == null) throw Exception('Payload não encontrado');
      return User.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw Exception('Erro ao recuperar payload: $e');
    }
  }

  static Future<void> setJWTToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jwtToken, token);
    } catch (e) {
      throw Exception('Erro ao salvar token: $e');
    }
  }

  static Future<String?> getJWTToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_jwtToken);
    } catch (e) {
      throw Exception('Erro ao recuperar token: $e');
    }
  }

  static Future<void> delete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jwtToken);
      await prefs.remove(_payload);
    } catch (e) {
      throw Exception('Erro ao deletar dados: $e');
    }
  }
}
