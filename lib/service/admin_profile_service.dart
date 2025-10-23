import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/admin_profile.dart';
import '../utils/token_manager.dart';

class AdminProfileService {
  final String baseUrl = 'https://api.seuprojeto.com'; // Troque pela sua API

  Future<AdminProfile> fetchAdminProfile() async {
    final token = await SesManager.getJWTToken();
    if (token == null) throw Exception('Token não encontrado. Faça login.');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return AdminProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar perfil do administrador');
    }
  }

  Future<void> updateAdminProfile(AdminProfile admin) async {
    final token = await SesManager.getJWTToken();
    if (token == null) throw Exception('Token não encontrado. Faça login.');

    final response = await http.put(
      Uri.parse('$baseUrl/admin/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(admin.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar perfil do administrador');
    }
  }
}
