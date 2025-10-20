import 'package:flutter/material.dart';
import './view/login_view.dart';
import './view/signup_view.dart';
import './view/project_view.dart'; // tela de projetos

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
        '/signup': (_) => const SignUpView(apiBaseUrl:'https://kaia.loophole.site'),
        '/projects': (_) => const ProjectsView(),
        '/forgot': (_) => const _Forgot(),
      },
      initialRoute: '/',
    );
  }
}

class _Forgot extends StatelessWidget {
  const _Forgot();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Recuperar Senha')));
}
