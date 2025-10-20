// lib/model/investment.dart
class Investment {
  final int id;
  final int projectId;
  final int investorId;
  final double investedAmount;
  final DateTime applicationDate;
  final double estimatedProfit; // do backend
  final double actualProfit;    // pode ser 0 enquanto não liquidado
  final String? note;

  const Investment({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.investedAmount,
    required this.applicationDate,
    required this.estimatedProfit,
    required this.actualProfit,
    this.note,
  });

  factory Investment.fromJson(Map<String, dynamic> j) => Investment(
        id: j['id'] as int,
        projectId: j['project_id'] as int,
        investorId: j['investor_id'] as int,
        investedAmount: (j['invested_amount'] as num).toDouble(),
        applicationDate: DateTime.parse(j['application_date'] as String),
        estimatedProfit: (j['estimated_profit'] as num).toDouble(),
        actualProfit: (j['actual_profit'] as num).toDouble(),
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'investor_id': investorId,
        'invested_amount': investedAmount,
        'application_date': applicationDate.toIso8601String(),
        'estimated_profit': estimatedProfit,
        'actual_profit': actualProfit,
        'note': note,
      };

  bool get isActive => actualProfit == 0; // regra simples: sem lucro realizado => ativo
}
