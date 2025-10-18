import 'package:flutter/foundation.dart';
import '../model/auth.dart';            // <-- adicione
import '../service/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _service;
  LoginViewModel(this._service);

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _set(loading: true, error: null);
    try {
      await _service.login(
        AuthRequest(email: email.trim(), password: password), // <-- corrigido
      );
      _set(loading: false);
      return true;
    } catch (e) {
      _set(loading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  void _set({bool? loading, String? error}) {
    if (loading != null) _loading = loading;
    _error = error;
    notifyListeners();
  }
}
