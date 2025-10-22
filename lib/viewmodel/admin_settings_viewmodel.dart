import 'package:flutter/material.dart';
import '../model/admin_settings.dart';
import '../service/admin_settings_service.dart';

class AdminSettingsViewModel extends ChangeNotifier {
  final AdminSettingsService _service;

  AdminSettingsViewModel({AdminSettingsService? service})
      : _service = service ?? AdminSettingsService();

  AdminSettings? settings;
  bool isLoading = false;
  String? error;

  /// Carrega configurações (modo offline ou mock)
  Future<void> loadSettings() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Carrega dados locais (mock)
      settings = await _service.fetchAdminSettings();
    } catch (e) {
      error = 'Erro ao carregar configurações: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Salva as configurações (localmente, por enquanto)
  Future<void> saveSettings() async {
    if (settings == null) return;
    isLoading = true;
    notifyListeners();

    try {
      // Atualiza mock localmente
      settings = await _service.updateAdminSettings(settings!);
    } catch (e) {
      error = 'Erro ao salvar configurações: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Métodos de atualização local
  void updatePushNotifications(bool value) {
    settings = settings?.copyWith(pushNotifications: value);
    notifyListeners();
  }

  void updateEmailNotifications(bool value) {
    settings = settings?.copyWith(emailNotifications: value);
    notifyListeners();
  }

  void updateTheme(String value) {
    settings = settings?.copyWith(theme: value);
    notifyListeners();
  }

  void updateTwoFactor(bool value) {
    settings = settings?.copyWith(twoFactorEnabled: value);
    notifyListeners();
  }

  /// Simula logout
  Future<void> logout() async {
    // Apenas limpa o estado, sem apagar token (pois não há token ainda)
    settings = null;
    notifyListeners();
  }
}
