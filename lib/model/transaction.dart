// lib/model/transaction.dart
class Transaction {
  final int id;
  final int paymentId;
  final int investorId;
  final String payerAccount;
  final String gatewayRef;
  final String transactionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    required this.paymentId,
    required this.investorId,
    required this.payerAccount,
    required this.gatewayRef,
    required this.transactionId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as int,
        paymentId: j['payment_id'] as int,
        investorId: j['investor_id'] as int,
        payerAccount: (j['payer_account'] ?? '') as String,
        gatewayRef: (j['gateway_ref'] ?? '') as String,
        transactionId: (j['transaction_id'] ?? '') as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: j['updated_at'] == null
            ? null
            : DateTime.parse(j['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payment_id': paymentId,
        'investor_id': investorId,
        'payer_account': payerAccount,
        'gateway_ref': gatewayRef,
        'transaction_id': transactionId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  Transaction copyWith({
    int? id,
    int? paymentId,
    int? investorId,
    String? payerAccount,
    String? gatewayRef,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      investorId: investorId ?? this.investorId,
      payerAccount: payerAccount ?? this.payerAccount,
      gatewayRef: gatewayRef ?? this.gatewayRef,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
