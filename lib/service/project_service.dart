import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../model/project.dart';

class ProjectService {
  final List<Project> _projects = [];

  /// Simula busca de backend
  Future<List<Project>> fetchProjects() async {
    await Future.delayed(const Duration(milliseconds: 250));
    // retorna cópia para evitar referência externa direta
    return List<Project>.from(_projects);
  }

  /// Simula criação no backend. Retorna o objeto criado (com id).
  /// imageFile pode ser XFile (web) ou File (mobile) — aqui usamos apenas o path.
  Future<Project> addProject(Project project, {dynamic imageFile}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // extrai path da imagem conforme tipo
    String? imagePath;
    if (imageFile != null) {
      if (kIsWeb) {
        // em web, XFile.path normalmente contém uma url de dados (ok para preview)
        imagePath = imageFile.path;
      } else {
        // mobile: se fornecer XFile (image_picker) usa .path, se File também .path
        imagePath = (imageFile is String) ? imageFile : (imageFile?.path);
      }
    }

    // cria id único simples
    final newId = DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000);

    final created = Project(
      id: newId,
      name: project.name,
      description: project.description,
      totalBudget: project.totalBudget,
      projectBudget: project.projectBudget,
      roi: project.roi,
      riskLevel: project.riskLevel,
      status: project.status,
      startDate: project.startDate,
      endDate: project.endDate,
      imagePath: imagePath ?? project.imagePath,
    );

    _projects.add(created);
    return created;
  }

  /// Simula exclusão no backend
  Future<void> deleteProject(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _projects.removeWhere((p) => p.id == id);
  }
}
