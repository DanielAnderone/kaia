import 'package:flutter/foundation.dart';

@immutable
class Investment {
  final int id;
  final int projectId;
  final int investorId;
  final double investedAmount;
  final DateTime applicationDate;
  final double estimatedProfit;
  final double actualProfit;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Derivados para sua UI atual
  String get status => actualProfit > 0 ? 'completed' : 'active';
  bool get isActive => status == 'active';

  const Investment({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.investedAmount,
    required this.applicationDate,
    required this.estimatedProfit,
    required this.actualProfit,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> j) {
    double toD(v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
    int toI(v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    DateTime? toDt(v) => v == null ? null : DateTime.tryParse(v.toString());

    return Investment(
      id: toI(j['id']),
      projectId: toI(j['project_id']),
      investorId: toI(j['investor_id']),
      investedAmount: toD(j['invested_amount']),
      applicationDate: toDt(j['application_date']) ?? DateTime.now(),
      estimatedProfit: toD(j['estimated_profit']),
      actualProfit: toD(j['actual_profit']),
      note: j['note']?.toString(),
      createdAt: toDt(j['created_at']) ?? DateTime.now(),
      updatedAt: toDt(j['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'investor_id': investorId,
        'invested_amount': investedAmount,
        'application_date': applicationDate.toIso8601String(),
        'estimated_profit': estimatedProfit,
        'actual_profit': actualProfit,
        'note': note,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
