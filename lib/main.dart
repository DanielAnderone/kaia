import 'package:flutter/material.dart';
import './view/login_view.dart';
import './view/new_project_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaia',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const LoginView(apiBaseUrl: 'http://localhost:8080'),
        '/home': (_) => const _Home(),
        '/forgot': (_) => const _Forgot(),
        '/signup': (_) => const _Signup(), // adicionada
        '/projectmanagement': () => const ProjectManagementPage(),
      },
      initialRoute: '/',
    );
  }
}

// Telas simples para rotas
class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}

class _Forgot extends StatelessWidget {
  const _Forgot();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Recuperar Senha')));
}

class _Signup extends StatelessWidget {
  const _Signup();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Criar Conta')));
}
