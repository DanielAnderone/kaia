// lib/model/project.dart
class Project {
  final int id;
  final int ownerId;
  final String? name; // backend pode não enviar; deixo opcional
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalProfit;
  final double profitabilityPercent;
  final double minimumInvestment;
  final String riskLevel;
  final String status;
  final double investmentAchieved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? imageUrl; // só no app

  const Project({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.profitabilityPercent,
    required this.minimumInvestment,
    required this.riskLevel,
    required this.status,
    required this.investmentAchieved,
    this.name,
    this.startDate,
    this.endDate,
    this.totalProfit,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });

  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'],
    ownerId: j['owner_id'],
    name: j['name'], // se vier
    description: j['description'] ?? '',
    startDate: _dt(j['start_date']),
    endDate: _dt(j['end_date']),
    totalProfit: (j['total_profit'] as num?)?.toDouble(),
    profitabilityPercent: (j['profitability_percent'] as num).toDouble(),
    minimumInvestment: (j['minimum_investment'] as num).toDouble(),
    riskLevel: j['risk_level'] ?? '',
    status: j['status'] ?? '',
    investmentAchieved: (j['investment_achieved'] as num).toDouble(),
    createdAt: _dt(j['created_at']),
    updatedAt: _dt(j['updated_at']),
    imageUrl: j['image_url'], // opcional
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'name': name,
    'description': description,
    'start_date': startDate?.toUtc().toIso8601String(),
    'end_date': endDate?.toUtc().toIso8601String(),
    'total_profit': totalProfit,
    'profitability_percent': profitabilityPercent,
    'minimum_investment': minimumInvestment,
    'risk_level': riskLevel,
    'status': status,
    'investment_achieved': investmentAchieved,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
    'image_url': imageUrl,
  };

  static DateTime? _dt(dynamic v) => v == null ? null : DateTime.parse(v as String);
}
