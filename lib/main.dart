import 'package:flutter/material.dart';
import './view/project_view.dart'; // contém ProjectManagementPage

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaia',
      debugShowCheckedModeBanner: false,
      // Opção A: usar home
      home: const ProjectsView(),

      // Opção B: usar rotas (comente a linha "home" acima se preferir rotas)
      // routes: {
      //   '/': (_) => const ProjectManagementPage(),
      //   '/projects': (_) => const ProjectManagementPage(),
      // },
      // initialRoute: '/', // só se usar rotas
    );
  }
}
