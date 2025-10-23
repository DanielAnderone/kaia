import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/admin_settings.dart';
import '../utils/token_manager.dart';

class AdminSettingsService {
  final String baseUrl = "https://kaia.loophole.site"; // URL base do seu backend

  /// 🔹 Busca configurações do administrador (mock ou API real)
  Future<AdminSettings> fetchAdminSettings() async {
    try {
      final token = await SesManager.getJWTToken();

      if (token == null) {
        await Future.delayed(const Duration(seconds: 1));
        return AdminSettings(
          pushNotifications: true,
          emailNotifications: true,
          theme: 'light',
          twoFactorEnabled: false,
        );
      }

      // ✅ Chamada real (quando backend estiver ativo)
      final response = await http.get(
        Uri.parse('$baseUrl/admin/settings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminSettings.fromJson(data);
      } else {
        throw Exception('Erro ao buscar configurações do admin');
      }
    } catch (e) {
      // 🔹 Fallback (caso ainda não haja backend)
      return AdminSettings(
        pushNotifications: true,
        emailNotifications: false,
        theme: 'light',
        twoFactorEnabled: false,
      );
    }
  }

  /// 🔹 Atualiza as configurações do administrador (mock ou API real)
  Future<AdminSettings> updateAdminSettings(AdminSettings settings) async {
    try {
      final token = await SesManager.getJWTToken();

      if (token == null) {
        // Simula atualização local
        await Future.delayed(const Duration(milliseconds: 500));
        return settings;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/admin/settings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(settings.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminSettings.fromJson(data);
      } else {
        throw Exception('Erro ao atualizar configurações');
      }
    } catch (e) {
      // Simula sucesso local caso não haja conexão
      await Future.delayed(const Duration(milliseconds: 500));
      return settings;
    }
  }
}
