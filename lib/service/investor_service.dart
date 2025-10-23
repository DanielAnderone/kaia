import 'package:dio/dio.dart';
import 'package:kaia_app/utils/token_manager.dart';
import '../model/investor.dart';
import 'api_client.dart';

class InvestorService {
  final Dio _dio = ApiClient.dio;
  final String resourcePath;

  InvestorService({this.resourcePath = "/investors/"});

  /// Cria um novo investidor
  Future<Investor> createInvestor(Investor investor, {required String token}) async {
    try {
      final response = await _dio.post(
        resourcePath,
        data: investor.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao criar investidor: $msg');
    }
  }

  /// Obtém um investidor pelo ID
  Future<Investor> getById(int id, {required String token}) async {
    try {
      final response = await _dio.get(
        '$resourcePath$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar investidor por ID: $msg');
    }
  }

  /// Obtém um investidor pelo telefone
  Future<Investor> getByPhone(String phone, {required String token}) async {
    try {
      final response = await _dio.get(
        '$resourcePath/phone/$phone',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao buscar investidor por telefone: $msg');
    }
  }

  /// Lista investidores com paginação
  Future<List<Investor>> getAll({int limit = 10, int offset = 0}) async {
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
        return data.map((e) => Investor.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao listar investidores: $msg');
    }
  }

  /// Atualiza um investidor pelo ID
  Future<Investor> updateInvestor(Investor investor, {required String token}) async {
    if (investor.id == null) throw Exception('ID do investidor é obrigatório para atualizar');

    try {
      final response = await _dio.put(
        '$resourcePath${investor.id}',
        data: investor.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return Investor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response != null
          ? 'Status: ${e.response!.statusCode}, Body: ${e.response!.data}'
          : e.message;
      throw Exception('Erro ao atualizar investidor: $msg');
    }
  }

  /// Deleta um investidor pelo ID
  Future<void> deleteInvestor(int id, {required String token}) async {
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
      throw Exception('Erro ao deletar investidor: $msg');
    }
  }
}
