// lib/model/transaction.dart
import 'package:flutter/foundation.dart';

@immutable
class Transaction {
  final int? id;
  final int paymentId;
  final int investorId;
  final String payerAccount;
  final String gatewayRef;     // Json manda número → guardo como string
  final String transactionId;  // Json manda número → guardo como string
  final double amount;
  // final DateTime? createdAt;
  // final DateTime? updatedAt;

  const Transaction({
    this.id,
    required this.paymentId,
    required this.investorId,
    required this.payerAccount,
    required this.gatewayRef,
    required this.transactionId,
    required this.amount,
    });

  // JSON → Modelo (aceita snake_case do Json)
  factory Transaction.fromJson(Map<String, dynamic> j) {
    // DateTime? parseDt(dynamic v) {
    //   if (v == null) return null;
    //   final s = v.toString();
    //   return DateTime.tryParse(s);
    // }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Transaction(
      id: j['id'] is String ? int.parse(j['id']) : (j['id'] ?? 0),
      paymentId: j['payment_id'] is String ? int.parse(j['payment_id']) : (j['payment_id'] ?? 0),
      investorId: j['investor_id'] is String ? int.parse(j['investor_id']) : (j['investor_id'] ?? 0),
      payerAccount: j['payer_account']?.toString() ?? '',
      gatewayRef: j['gateway_ref']?.toString() ?? '',
      transactionId: j['transaction_id']?.toString() ?? '',
      amount: parseDouble(j['amount']),
      // createdAt: parseDt(j['created_at']) ?? DateTime.now(),
      // updatedAt: parseDt(j['updated_at']),
    );
  }

  // Modelo → JSON (snake_case que o Json espera)
  Map<String, dynamic> toJson() => {
        'id': id,
        'payment_id': paymentId,
        'investor_id': investorId,
        'payer_account': payerAccount,
        'gateway_ref': int.tryParse(gatewayRef) ?? gatewayRef,
        'transaction_id': int.tryParse(transactionId) ?? transactionId,
        'amount': amount,
        // 'created_at': createdAt.toIso8601String(),
        // 'updated_at': updatedAt?.toIso8601String(),
      };

  Transaction copyWith({
    int? id,
    int? paymentId,
    int? investorId,
    String? payerAccount,
    String? gatewayRef,
    String? transactionId,
    double? amount,
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
      amount: amount ?? this.amount,
      // createdAt: createdAt ?? this.createdAt,
      // updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
