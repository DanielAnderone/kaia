// import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/project.dart';
import '../service/project_service.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectService _service = ProjectService();

  final List<Project> _projects = [];
  List<Project> get projects => List.unmodifiable(_projects);

  bool isLoading = false;

  Future<void> fetchProjects() async {
    isLoading = true;
    notifyListeners();
    try {
      final list = await _service.listProjects();
      _projects
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint('Erro fetchProjects: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Retorna o Project criado (e adiciona apenas uma vez à lista local).
  Future<Project?> addProject(Project project, {dynamic imageFile}) async {
    try {
      final created = await _service.addProject(project);
      // garante que não haja duplicata (checa id)
      final exists = _projects.any((p) => p.id == created.id);
      if (!exists) {
        _projects.add(created);
        notifyListeners();
      }
      return created;
    } catch (e) {
      debugPrint('Erro addProject: $e');
      return null;
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _service.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro deleteProject: $e');
    }
  }
}
