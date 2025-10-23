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

  Future<Map<String, dynamic>?> login(String email, String password) async {
  _set(loading: true, error: null);
  try {
    final authResponse = await _service.login(
      AuthRequest(email: email.trim(), password: password),
    );

    _set(loading: false);

    // Supondo que authResponse tenha um método toJson()
    return authResponse.toJson();
  } catch (e) {
    _set(loading: false, error: e.toString().replaceFirst('Exception: ', ''));
    return null;
  }
}

  void _set({bool? loading, String? error}) {
    if (loading != null) _loading = loading;
    _error = error;
    notifyListeners();
  }
}
