import 'package:flutter/material.dart';
import '../model/investor.dart';
import '../service/investor_service.dart';
import '../utils/token_manager.dart';

class InvestorViewModel extends ChangeNotifier {
  final InvestorService _service = InvestorService();
  List<Investor> investors = [];
  bool isLoading = false;
  String? error;

  /// Carrega investidores com token de autenticação
  Future<void> loadInvestors() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception("Token não encontrado. Faça login novamente.");

      investors = await _service.fetchInvestors(token: token);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
