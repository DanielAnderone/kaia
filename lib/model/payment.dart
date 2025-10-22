// lib/model/payment.dart
class Payment {
  final int id;
  final int payerFromId;
  final int payerToId;
  final double paidAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Payment({
    required this.id,
    required this.payerFromId,
    required this.payerToId,
    required this.paidAmount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: j['id'],
        payerFromId: j['payer_from_id'],
        payerToId: j['payer_to_id'],
        paidAmount: (j['paid_amount'] as num).toDouble(),
        createdAt: DateTime.parse(j['created_at']),
        updatedAt: j['updated_at'] == null ? null : DateTime.parse(j['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payer_from_id': payerFromId,
        'payer_to_id': payerToId,
        'paid_amount': paidAmount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
