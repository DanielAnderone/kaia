class Project {
  final int id;
  final int ownerId;
  final String name;                 // adicione no backend OU derive de description
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalProfit;
  final double profitabilityPercent; // %
  final double minimumInvestment;    // MT
  final String riskLevel;            // "baixo|medio|alto"
  final String status;               // "Ativo|Planeado|..."
  final int investmentAchieved;      // MT
  final String? imageUrl;

  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    this.totalProfit,
    required this.profitabilityPercent,
    required this.minimumInvestment,
    required this.riskLevel,
    required this.status,
    required this.investmentAchieved,
    this.imageUrl,
  });

  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'],
    ownerId: j['owner_id'],
    name: j['name'] ?? '',                 // se o backend ainda não tiver, preencha
    description: j['description'] ?? '',
    startDate: j['start_date'] == null ? null : DateTime.parse(j['start_date']),
    endDate: j['end_date'] == null ? null : DateTime.parse(j['end_date']),
    totalProfit: (j['total_profit'] as num?)?.toDouble(),
    profitabilityPercent: (j['profitability_percent'] as num).toDouble(),
    minimumInvestment: (j['minimum_investment'] as num).toDouble(),
    riskLevel: j['risk_level'] ?? 'medio',
    status: j['status'] ?? 'Ativo',
    investmentAchieved: j['investment_achieved'] ?? 0,
    imageUrl: j['image_url'],
  );
}
