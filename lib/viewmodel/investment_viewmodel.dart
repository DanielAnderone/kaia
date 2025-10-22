import 'package:flutter/material.dart';
import '../model/investment.dart';
import '../service/investment_service.dart';

class InvestmentViewModel extends ChangeNotifier {
  final InvestmentService _service = InvestmentService();

  List<Investment> investments = [];
  bool isLoading = false;
  int page = 1;
  int perPage = 10;
  int totalItems = 0; // opcional, para paginação

  // filtros simples (poderão ser expandidos)
  String? filterStatus;
  String? filterProject;
  DateTimeRange? filterRange;

  Future<void> loadInvestments({int pageIndex = 1}) async {
    isLoading = true;
    notifyListeners();
    page = pageIndex;
    final data = await _service.fetchInvestments(page: page, perPage: perPage);

    // aplicar filtros simples em memória (já que serviço é mock)
    var filtered = data;
    if (filterStatus != null && filterStatus!.isNotEmpty) {
      filtered = filtered.where((i) => i.status == filterStatus).toList();
    }
    if (filterProject != null && filterProject!.isNotEmpty) {
      filtered = filtered.where((i) => i.projectName.toLowerCase().contains(filterProject!.toLowerCase())).toList();
    }
    if (filterRange != null) {
      filtered = filtered.where((i) => i.date.isAfter(filterRange!.start.subtract(const Duration(days:1))) && i.date.isBefore(filterRange!.end.add(const Duration(days:1)))).toList();
    }

    investments = filtered;
    totalItems = investments.length; // no mock simples
    isLoading = false;
    notifyListeners();
  }

  Future<void> applyFilters({String? status, String? project, DateTimeRange? range}) async {
    filterStatus = status;
    filterProject = project;
    filterRange = range;
    await loadInvestments(pageIndex: 1);
  }

  Future<void> exportRelatorio() async {
    isLoading = true;
    notifyListeners();
    await _service.exportReport();
    isLoading = false;
    notifyListeners();
  }
}
