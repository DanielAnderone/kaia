import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/investor.dart';

class InvestorService {
  // Ajuste a base conforme o seu backend.
  static const String _baseUrl = 'http://localhost:8080/api';

  Future<Investor> createInvestor(Investor investor) async {
    final uri = Uri.parse('$_baseUrl/investors');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(investor.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return Investor.fromJson(data);
    }
    throw Exception('Erro ao cadastrar investidor (${res.statusCode}): ${res.body}');
  }
}
