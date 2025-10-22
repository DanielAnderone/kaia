class Investor {
  final String name;
  final String email;
  final String kycStatus;
  final String? currentProject; // Projeto que o usuário está fazendo

  Investor({
    required this.name,
    required this.email,
    required this.kycStatus,
    this.currentProject,
  });

  factory Investor.fromJson(Map<String, dynamic> json) => Investor(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    kycStatus: json['kycStatus'] ?? 'Pending',
    currentProject: json['currentProject'],
  );
}
