import 'package:flutter/foundation.dart';
import '../model/investor.dart';
import '../service/investor_service.dart';
import '../utils/token_manager.dart';

class InvestorViewModel extends ChangeNotifier {
  final InvestorService _service = InvestorService();

  List<Investor> _investors = [];
  List<Investor> get investors => _investors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Lista todos investidores
  Future<void> fetchInvestors({int limit = 10, int offset = 0}) async {
    _setLoading(true);
    try {
      final token = await SesManager.getJWTToken();
      if (token == null) throw Exception('Token não encontrado');

      final result = await _service.getAll(limit: limit, offset: offset);
      _investors = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _investors = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Cria um novo investidor
  Future<Investor?> createInvestor(Investor investor) async {
    _setLoading(true);
    try {
      final token = await SesManager.getJWTToken();
      if (token == null) throw Exception('Token não encontrado');

      final newInvestor = await _service.createInvestor(investor, token: token);
      _investors.add(newInvestor);
      notifyListeners();
      return newInvestor;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um investidor existente
  Future<Investor?> updateInvestor(Investor investor) async {
    if (investor.id == null) return null;

    _setLoading(true);
    try {
      final token = await SesManager.getJWTToken();
      if (token == null) throw Exception('Token não encontrado');

      final updated = await _service.updateInvestor(investor, token: token);
      final index = _investors.indexWhere((i) => i.id == updated.id);
      if (index != -1) _investors[index] = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Deleta um investidor
  Future<bool> deleteInvestor(int id) async {
    _setLoading(true);
    try {
      final token = await SesManager.getJWTToken();
      if (token == null) throw Exception('Token não encontrado');

      await _service.deleteInvestor(id, token: token);
      _investors.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém um investidor pelo ID
  Future<Investor?> getInvestorById(int id) async {
    _setLoading(true);
    try {
      final token = await SesManager.getJWTToken();
      if (token == null) throw Exception('Token não encontrado');

      final investor = await _service.getById(id, token: token);
      return investor;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém um investidor pelo telefone
  Future<Investor?> getInvestorByPhone(String phone) async {
    _setLoading(true);
    try {
      final token = await SesManager.getJWTToken();
      if (token == null) throw Exception('Token não encontrado');

      final investor = await _service.getByPhone(phone, token: token);
      return investor;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
