import 'package:dio/dio.dart';
import 'package:kaia_app/utils/token_manager.dart';
import '../model/transaction.dart';
import 'api_client.dart';

class TransactionService {
  final Dio _dio = ApiClient.dio;
  final String resourcePath;

  TransactionService({this.resourcePath = "/transactions/"});

  /// Cria uma nova transação
  Future<Transaction> createTransaction(Transaction tx) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.post(
        resourcePath,
        data: tx.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Transaction.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao criar transação: $msg');
    }
  }

  /// Busca uma transação por ID
  Future<Transaction> getById(int id) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.get(
        '$resourcePath$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Transaction.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar transação por ID: $msg');
    }
  }

  /// Busca todas as transações (paginadas)
  Future<List<Transaction>> getAll({int limit = 10, int offset = 0}) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.get(
        resourcePath,
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      if (data is List) {
        return data.map((e) => Transaction.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao listar transações: $msg');
    }
  }

  /// Busca transações por payment_id
  Future<List<Transaction>> getByPaymentId(int paymentId, {int limit = 10, int offset = 0}) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.get(
        '${resourcePath}payment/$paymentId',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      if (data is List) {
        return data.map((e) => Transaction.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar transações por payment_id: $msg');
    }
  }

  /// Busca transações por payer_account
  Future<List<Transaction>> getByPayerAccount(String payerAccount, {int limit = 10, int offset = 0}) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.get(
        '${resourcePath}payer/$payerAccount',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      if (data is List) {
        return data.map((e) => Transaction.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar transações por payer_account: $msg');
    }
  }

  /// Atualiza uma transação pelo ID
  Future<Transaction> updateTransaction(Transaction tx) async {
    if (tx.id == null) throw Exception('ID da transação é obrigatório para atualizar');
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.put(
        '$resourcePath${tx.id}',
        data: tx.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Transaction.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao atualizar transação: $msg');
    }
  }

  /// Deleta uma transação pelo ID
  Future<void> deleteTransaction(int id) async {
    try {
      final token = await SesManager.getJWTToken();
      await _dio.delete(
        '$resourcePath$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao deletar transação: $msg');
    }
  }
}
