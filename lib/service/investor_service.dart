import 'package:dio/dio.dart';
import '../model/investor.dart';

class InvestorService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'));

  Future<List<Investor>> fetchInvestors({required String token}) async {
    final res = await _dio.get(
      '/investors',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (res.data is List) {
      return (res.data as List).map((json) => Investor.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
