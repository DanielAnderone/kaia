// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/transaction.dart';

class TransactionService {
  final String baseUrl;           // ex: http://localhost:8080
  final String resourcePath;      // ex: /api/transactions
  String? _bearer;

  TransactionService({
    required this.baseUrl,
    this.resourcePath = '/transactions/',
  });

  void setAuthToken(String? token) => _bearer = token;

  Map<String, String> _headers() => {
        'Content-Type': 'application/json; charset=utf-8',
        if (_bearer != null && _bearer!.isNotEmpty) 'Authorization': 'Bearer $_bearer',
      };

  Uri _u([String suffix = '', Map<String, dynamic>? q]) {
    final qp = <String, String>{};
    q?.forEach((k, v) {
      if (v == null) return;
      qp[k] = v.toString();
    });
    return Uri.parse('$baseUrl$resourcePath$suffix').replace(queryParameters: qp.isEmpty ? null : qp);
  }

  // LISTAR
  Future<List<Transaction>> list({String? query, int? limit, int? offset}) async {
    final res = await http.get(_u('', {
      if (query != null && query.trim().isNotEmpty) 'q': query,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    }), headers: _headers());

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      final List data = body is List ? body : (body['data'] ?? []);
      return data.map((e) => Transaction.fromBackend(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Falha ao listar: ${res.statusCode} ${res.body}');
  }

  // OBTER POR ID
  Future<Transaction> getById(int id) async {
    final res = await http.get(_u('/$id'), headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      final Map<String, dynamic> j = body is Map<String, dynamic> ? body : {};
      return Transaction.fromBackend(j);
    }
    throw HttpException('Falha ao obter: ${res.statusCode} ${res.body}');
  }

  // CRIAR (usa payload no formato pedido)
  Future<Transaction> create(Transaction tx) async {
    final res = await http.post(_u(), headers: _headers(), body: json.encode(tx.toBackend()));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      return Transaction.fromBackend(body as Map<String, dynamic>);
    }
    throw HttpException('Falha ao criar: ${res.statusCode} ${res.body}');
  }

  // ATUALIZAR
  Future<Transaction> update(int id, Transaction tx) async {
    final res = await http.put(_u('/$id'), headers: _headers(), body: json.encode(tx.toBackend()));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      return Transaction.fromBackend(body as Map<String, dynamic>);
    }
    throw HttpException('Falha ao atualizar: ${res.statusCode} ${res.body}');
  }

  // REMOVER
  Future<void> delete(int id) async {
    final res = await http.delete(_u('/$id'), headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('Falha ao remover: ${res.statusCode} ${res.body}');
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
