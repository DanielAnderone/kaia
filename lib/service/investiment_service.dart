import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/investment.dart';

class InvestmentService {
  final String baseUrl;       // ex: http://localhost:8080
  final String resourcePath;  // ex: /api/investments
  String? _bearer;

  InvestmentService({
    required this.baseUrl,
    this.resourcePath = '/investments',
  });

  void setAuthToken(String? token) => _bearer = token;

  Map<String, String> _headers() => {
        'Content-Type': 'application/json; charset=utf-8',
        if (_bearer != null && _bearer!.isNotEmpty) 'Authorization': 'Bearer $_bearer',
      };

  Uri _u([String suffix = '', Map<String, dynamic>? q]) {
    final qp = <String, String>{};
    q?.forEach((k, v) {
      if (v != null) qp[k] = v.toString();
    });
    return Uri.parse('$baseUrl$resourcePath$suffix')
        .replace(queryParameters: qp.isEmpty ? null : qp);
  }

  Future<List<Investment>> list({String? query, int? limit, int? offset}) async {
    final res = await http.get(_u('', {
      if (query != null && query.trim().isNotEmpty) 'q': query,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    }), headers: _headers());

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      final List data = body is List ? body : (body['data'] ?? []);
      return data.map((e) => Investment.fromBackend(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Falha ao listar: ${res.statusCode} ${res.body}');
  }

  Future<Investment> getById(int id) async {
    final res = await http.get(_u('/$id'), headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Investment.fromBackend(json.decode(res.body));
    }
    throw HttpException('Falha ao obter: ${res.statusCode} ${res.body}');
  }

  Future<Investment> create(Investment inv) async {
    final res = await http.post(_u(), headers: _headers(), body: json.encode(inv.toBackend()));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Investment.fromBackend(json.decode(res.body));
    }
    throw HttpException('Falha ao criar: ${res.statusCode} ${res.body}');
  }

  Future<Investment> update(int id, Investment inv) async {
    final res = await http.put(_u('/$id'), headers: _headers(), body: json.encode(inv.toBackend()));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Investment.fromBackend(json.decode(res.body));
    }
    throw HttpException('Falha ao atualizar: ${res.statusCode} ${res.body}');
  }

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
