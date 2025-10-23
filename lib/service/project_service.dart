import 'package:dio/dio.dart';
import 'package:kaia_app/utils/token_manager.dart';
import '../model/project.dart';
import 'api_client.dart';

class ProjectService {
  final Dio _dio = ApiClient.dio;

  /// Lista todos os projetos
  Future<List<Project>> listProjects() async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.get(
        '/projects/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (data is Map && data['projects'] is List) {
          return (data['projects'] as List)
              .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Formato inesperado do JSON');
        }
      } else {
        throw Exception('Erro ao carregar projetos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }

  /// Busca um projeto específico
  Future<Project> getProject(int id) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.get(
        '/projects/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return Project.fromJson(data);
        } else {
          throw Exception('Formato inesperado do JSON');
        }
      } else {
        throw Exception('Erro ao buscar projeto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }

  /// Cria um novo projeto (sem arquivo)
  Future<Project> addProject(Project project) async {
    try {
      final token = await SesManager.getJWTToken();
      final payload = await SesManager.getPayload();
      project.ownerId = payload.id;
      
      final response = await _dio.post(
        '/projects/',
        data: project.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Project.fromJson(response.data);
      } else {
        throw Exception('Erro ao criar projeto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }

  /// Cria projeto com upload de imagem
  Future<Project> addProjectWithImage(Project project, String imagePath) async {
    try {
      final token = await SesManager.getJWTToken();
      final formData = FormData.fromMap({
        ...project.toJson(),
        if (imagePath.isNotEmpty)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '/projects/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Project.fromJson(response.data);
      } else {
        throw Exception('Erro ao criar projeto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }

  /// Deleta projeto
  Future<void> deleteProject(int id) async {
    try {
      final token = await SesManager.getJWTToken();
      final response = await _dio.delete(
        '/projects/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao deletar projeto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de rede: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido: $e');
    }
  }
}
