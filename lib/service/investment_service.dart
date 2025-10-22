import 'dart:async';
import '../model/investment.dart';

class InvestmentService {
  final List<Investment> _mock = [
    Investment(
      id: '1',
      investorName: 'João Silva',
      projectName: 'Sunrise Farms Lote A',
      value: 15000,
      status: 'Completed',
      transactionRef: 'TXN123456789',
      date: DateTime(2023, 10, 26),
    ),
    Investment(
      id: '2',
      investorName: 'Jane Smith',
      projectName: 'Green Pastures Lote 3',
      value: 25000,
      status: 'Active',
      transactionRef: 'TXN987654321',
      date: DateTime(2023, 11, 15),
    ),
    Investment(
      id: '3',
      investorName: 'Michael Johnson',
      projectName: 'Golden Egg Co-op',
      value: 10000,
      status: 'Pending',
      transactionRef: 'TXN456789123',
      date: DateTime(2024, 1, 5),
    ),
    Investment(
      id: '4',
      investorName: 'Emily Davis',
      projectName: 'Heritage Poultry Fund',
      value: 5000,
      status: 'Failed',
      transactionRef: 'TXN789123456',
      date: DateTime(2024, 2, 20),
    ),
    Investment(
      id: '5',
      investorName: 'Chris Brown',
      projectName: 'Featherweight Investments',
      value: 50000,
      status: 'Active',
      transactionRef: 'TXN321654987',
      date: DateTime(2024, 3, 10),
    ),
  ];

  /// Simula fetch de investimentos (poderá ser substituído por chamada HTTP)
  Future<List<Investment>> fetchInvestments({int page = 1, int perPage = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simples paginação em memória
    final start = (page - 1) * perPage;
    final end = (start + perPage).clamp(0, _mock.length);
    if (start >= _mock.length) return [];
    return _mock.sublist(start, end);
  }

  /// Simula export (apenas delay)
  Future<void> exportReport() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
