import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('BASE_URL', defaultValue: 'https://kaia.loophole.site'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ))..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
}
