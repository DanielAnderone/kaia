class Project {
  final int? id;
  final String name;
  final String description;
  final double totalBudget;
  final double projectBudget;
  final double roi;
  final String riskLevel;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imagePath;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.totalBudget,
    required this.projectBudget,
    required this.roi,
    required this.riskLevel,
    required this.status,
    this.startDate,
    this.endDate,
    this.imagePath,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      totalBudget: (json['total_budget'] ?? 0).toDouble(),
      projectBudget: (json['project_budget'] ?? 0).toDouble(),
      roi: (json['roi'] ?? 0).toDouble(),
      riskLevel: json['risk_level'] ?? '',
      status: json['status'] ?? '',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'total_budget': totalBudget,
      'project_budget': projectBudget,
      'roi': roi,
      'risk_level': riskLevel,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'image_path': imagePath,
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    double? totalBudget,
    double? projectBudget,
    double? roi,
    String? riskLevel,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? imagePath,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalBudget: totalBudget ?? this.totalBudget,
      projectBudget: projectBudget ?? this.projectBudget,
      roi: roi ?? this.roi,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
