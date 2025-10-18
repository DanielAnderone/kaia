import 'package:flutter/foundation.dart';
import '../service/auth_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _auth;
  bool loading = false;
  String? error;

  SignUpViewModel(this._auth);

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    String? status, // pode enviar 'active' ou 'inactive', opcional
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final ok = await _auth.registerUser(
        username: username,
        email: email,
        password: password,
        status: status,
      );
      return ok;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
