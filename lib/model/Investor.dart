// lib/model/investor.dart
class Investor {
  final int? id;
  final int userId;           // id do usuário autenticado
  final String name;
  final String phone;
  final DateTime bornDate;
  final String identityCard;  // BI/Doc
  final String nuit;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Investor({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.bornDate,
    required this.identityCard,
    required this.nuit,
    this.createdAt,
    this.updatedAt,
  });

  factory Investor.fromJson(Map<String, dynamic> j) => Investor(
        id: j['id'],
        userId: j['user_id'],
        name: j['name'],
        phone: j['phone'],
        bornDate: DateTime.parse(j['born_date']),
        identityCard: j['identity_card'],
        nuit: j['nuit'],
        createdAt: j['created_at'] == null ? null : DateTime.parse(j['created_at']),
        updatedAt: j['updated_at'] == null ? null : DateTime.parse(j['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'name': name,
        'phone': phone,
        'born_date': bornDate.toIso8601String(),
        'identity_card': identityCard,
        'nuit': nuit,
      };
}
