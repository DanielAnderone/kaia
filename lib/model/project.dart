class Project {
  final int? id;
  int? ownerId;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double profitabilityPercent;
  final double minimumInvestment;
  final String? riskLevel;
  final String? status;
  final String? mediaPath;
  final double? investmentAchieved;
  final double? totalProfit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    this.id,
    this.ownerId,
    this.description,
    this.startDate,
    this.endDate,
    required this.profitabilityPercent,
    required this.minimumInvestment,
    this.riskLevel,
    this.status,
    this.mediaPath,
    this.investmentAchieved,
    this.totalProfit,
    this.createdAt,
    this.updatedAt,
  });

  // Propriedades auxiliares para compatibilidade com a UI
  String? get name => description;
  
  String? get imageUrl {
    if (mediaPath == null || mediaPath!.isEmpty || mediaPath == '//') {
      return 'https://picsum.photos/seed/${id ?? 0}/400/300';
    }
    // Ajuste a URL base conforme seu servidor
    if (mediaPath!.startsWith('http')) {
      return mediaPath;
    }
    return '0.0.0.0:8080/projects/download/$id';
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) =>
        dateStr != null ? DateTime.tryParse(dateStr) : null;

    return Project(
      id: json['id'] as int?,
      ownerId: json['owner_id'] as int?,
      description: json['description'] as String?,
      startDate: parseDate(json['start_date'] as String?),
      endDate: parseDate(json['end_date'] as String?),
      profitabilityPercent: (json['profitability_percent'] as num?)?.toDouble() ?? 0.0,
      minimumInvestment: (json['minimum_investment'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String?,
      status: json['status'] as String?,
      mediaPath: json['media_path'] as String?,
      investmentAchieved: (json['investment_achieved'] as num?)?.toDouble(),
      totalProfit: (json['total_profit'] as num?)?.toDouble(),
      createdAt: parseDate(json['created_at'] as String?),
      updatedAt: parseDate(json['updated_at'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDate(DateTime? dt) => dt?.toUtc().toIso8601String();

    return {
      'id': id,
      'owner_id': ownerId,
      'description': description,
      'start_date': formatDate(startDate),
      'end_date': formatDate(endDate),
      'profitability_percent': profitabilityPercent,
      'minimum_investment': minimumInvestment,
      'risk_level': riskLevel,
      'status': status,
      'media_path': mediaPath,
      'investment_achieved': investmentAchieved,
      'total_profit': totalProfit,
      'created_at': formatDate(createdAt),
      'updated_at': formatDate(updatedAt),
    };
  }
}
