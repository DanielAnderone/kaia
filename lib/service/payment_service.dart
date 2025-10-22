import 'dart:convert';
import 'package:http/http.dart' as http;
class PaymentRequest {
  final int id; // geralmente 0 para criar
  final int payerFromId;
  final int payerToId;
  final double paidAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentRequest({
    this.id = 0,
    required this.payerFromId,
    required this.payerToId,
    required this.paidAmount,
    required this.totalAmount,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        "id": id,
        "payer_from_id": payerFromId,
        "payer_to_id": payerToId,
        "paid_amount": paidAmount,
        "total_amount": totalAmount,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String() ?? createdAt.toIso8601String(),
      };
}

class PaymentService {
  final String baseUrl;
  final http.Client _client;
  PaymentService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  /// cria pagamento e retorna o corpo bruto do backend (map)
  Future<Map<String, dynamic>> createPayment(PaymentRequest req) async {
    final uri = Uri.parse('$baseUrl/payments/');
    // logs úteis
    // ignore: avoid_print
    print('POST $uri\npayload: ${jsonEncode(req.toJson())}');
    final res = await _client.post(
      uri,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(req.toJson()),
    );

    // ignore: avoid_print
    print('status: ${res.statusCode}\nbody: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {"ok": true};
    }

    String msg = 'Falha ao processar pagamento';
    try {
      final err = jsonDecode(res.body);
      if (err is Map && err['message'] is String) msg = err['message'];
    } catch (_) {}
    throw Exception(msg);
  }
}