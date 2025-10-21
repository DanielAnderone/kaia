class Investment {
  final int id;
  final int projectId;
  final int investorId;
  final double investedAmount;
  final DateTime applicationDate;
  final double estimatedProfit;
  final double actualProfit;
  final String? note;

  /// status vindo do backend: "active" | "completed" | etc.
  final String status;

  const Investment({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.investedAmount,
    required this.applicationDate,
    required this.estimatedProfit,
    required this.actualProfit,
    this.note,
    required this.status,
  });

  /// Conveniência para filtros já usados na UI
  bool get isActive => status.toLowerCase() == 'active';

  factory Investment.fromJson(Map<String, dynamic> j) => Investment(
    id: j['id'],
    projectId: j['project_id'],
    investorId: j['investor_id'],
    investedAmount: (j['invested_amount'] as num).toDouble(),
    applicationDate: DateTime.parse(j['application_date']),
    estimatedProfit: (j['estimated_profit'] as num).toDouble(),
    actualProfit: (j['actual_profit'] as num).toDouble(),
    note: j['note'],
    status: j['status'] ?? 'active',
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
    'status': status,
  };
}
