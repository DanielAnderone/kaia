import 'package:dio/dio.dart';
import '../model/project.dart';
import 'api_client.dart';

class ProjectService {
  final Dio _dio = ApiClient.dio;

  Future<List<Project>> listProjects() async {
    final r = await _dio.get('/projects');
    if (r.statusCode == 200 && r.data is List) {
      return (r.data as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao carregar projetos');
  }

  Future<Project> getProject(int id) async {
    final r = await _dio.get('/projects/$id');
    return Project.fromJson(r.data as Map<String, dynamic>);
  }
}
