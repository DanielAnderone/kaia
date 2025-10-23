import 'package:dio/dio.dart';
import 'package:kaia_app/utils/token_manager.dart';
import '../model/investment.dart';
import 'api_client.dart';

class InvestmentService {
  final Dio _dio = ApiClient.dio;
  final String resourcePath;

  InvestmentService({this.resourcePath = "/investments/"});

  /// Cria um novo investimento
  Future<Investment> createInvestment(Investment inv, {required String token}) async {
    try {
      final response = await _dio.post(
        resourcePath,
        data: inv.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao criar investimento: $msg');
    }
  }

  /// Busca investimento pelo ID
  Future<Investment> getById(int id, {required String token}) async {
    try {
      final response = await _dio.get(
        '$resourcePath$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar investimento por ID: $msg');
    }
  }

  /// Lista todos os investimentos
  Future<List<Investment>> getAll({int limit = 10, int offset = 0}) async {
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
        return data.map((e) => Investment.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao listar investimentos: $msg');
    }
  }

  /// Lista investimentos por projeto
  Future<List<Investment>> getByProjectID(int projectId, {required String token, int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '$resourcePath/project/$projectId',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      final data = response.data;
      if (data is List) {
        return data.map((e) => Investment.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar investimentos por projeto: $msg');
    }
  }

  /// Lista investimentos por investidor
  Future<List<Investment>> getByInvestorID(int investorId, {required String token, int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '$resourcePath/investor/$investorId',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      final data = response.data;
      if (data is List) {
        return data.map((e) => Investment.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar investimentos por investidor: $msg');
    }
  }

  /// Atualiza um investimento pelo ID
  Future<Investment> updateInvestment(Investment inv, {required String token}) async {
    if (inv.id == 0) throw Exception('ID do investimento é obrigatório para atualizar');

    try {
      final response = await _dio.put(
        '$resourcePath${inv.id}',
        data: inv.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao atualizar investimento: $msg');
    }
  }

  /// Deleta um investimento pelo ID
  Future<void> deleteInvestment(int id, {required String token}) async {
    try {
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
      throw Exception('Erro ao deletar investimento: $msg');
    }
  }
}
