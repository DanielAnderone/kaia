import 'package:flutter/material.dart';
import '../model/admin_profile.dart';
import '../service/admin_profile_service.dart';

class AdminProfileViewModel extends ChangeNotifier {
  final AdminProfileService _service = AdminProfileService();

  AdminProfile? admin;
  bool isLoading = false;
  String? error;

  /// Carrega perfil do admin
  Future<void> loadAdminProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      admin = await _service.fetchAdminProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza perfil do admin
  Future<void> updateAdminProfile(AdminProfile updatedAdmin) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.updateAdminProfile(updatedAdmin);
      admin = updatedAdmin;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
