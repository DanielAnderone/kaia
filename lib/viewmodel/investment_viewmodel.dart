import 'package:flutter/material.dart';
import '../model/investment.dart';
import '../service/investiment_service.dart';

class InvestmentViewModel extends ChangeNotifier {
  final InvestmentService _service = InvestmentService();

  List<Investment> investments = [];
  bool isLoading = false;
  int page = 1;
  int perPage = 10;
  int totalItems = 0;

  // filtros simples
  String? filterStatus;
  String? filterProject;
  DateTimeRange? filterRange;

  Future<void> loadInvestments({int pageIndex = 1}) async {
    isLoading = true;
    notifyListeners();

    try {
      page = pageIndex;
      final data = await _service.getAll();

      // aplicar filtros simples em memória
      var filtered = data;
      if (filterStatus != null && filterStatus!.isNotEmpty) {
        filtered = filtered.where((i) => i.status == filterStatus).toList();
      }
      if (filterProject != null && filterProject!.isNotEmpty) {
        filtered = filtered
            .where((i) => i.projectId.toString().contains(filterProject!))
            .toList();
      }
      if (filterRange != null) {
        filtered = filtered
            .where((i) =>
                i.createdAt.isAfter(
                    filterRange!.start.subtract(const Duration(days: 1))) &&
                i.createdAt
                    .isBefore(filterRange!.end.add(const Duration(days: 1))))
            .toList();
      }

      investments = filtered;
      totalItems = investments.length;
    } catch (e) {
      investments = []; // garante que a lista não fique nula
      debugPrint('Erro ao carregar investimentos: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters(
      {String? status, String? project, DateTimeRange? range}) async {
    filterStatus = status;
    filterProject = project;
    filterRange = range;
    await loadInvestments(pageIndex: 1);
  }

  Future<void> exportRelatorio() async {
    isLoading = true;
    notifyListeners();
    try {
      // await _service.exportReport();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
