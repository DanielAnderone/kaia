class Project {
  final int? id;
  final int? ownerId;
  final String? description;
  final String? startDate;
  final String? endDate;
  final double profitabilityPercent;
  final double minimumInvestment;
  final String? riskLevel;
  final String? status;
  final String? mediaPath;
  final double? investmentAchieved;
  final double? totalProfit;
  final String? createdAt;
  final String? updatedAt;

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
    return 'https://kaia.loophole.site/projects/download/$id';
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int?,
      ownerId: json['owner_id'] as int?,
      description: json['description'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      profitabilityPercent: (json['profitability_percent'] as num?)?.toDouble() ?? 0.0,
      minimumInvestment: (json['minimum_investment'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String?,
      status: json['status'] as String?,
      mediaPath: json['media_path'] as String?,
      investmentAchieved: (json['investment_achieved'] as num?)?.toDouble(),
      totalProfit: (json['total_profit'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'profitability_percent': profitabilityPercent,
      'minimum_investment': minimumInvestment,
      'risk_level': riskLevel,
      'status': status,
      'media_path': mediaPath,
      'investment_achieved': investmentAchieved,
      'total_profit': totalProfit,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
