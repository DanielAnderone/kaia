import 'package:flutter/material.dart';
import './view/login_view.dart';
import './view/signup_view.dart';
import 'view/project_view.dart';
import 'view/paymentView.dart';
import 'view/transactions_view.dart';

void main() => runApp(const KaiaApp());

class KaiaApp extends StatelessWidget {
  const KaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),

      // Login primeiro
      initialRoute: '/',

      routes: {
        '/': (_) => const LoginView(),              // tela de login
        '/signup': (_) => const SignUpView(),       // opcional se quiser via rota
        '/projects': (_) => const ProjectsView(),   // home após login
        '/pagamentos': (_) => const PaymentView(),
        '/transacao': (_) => const TransactionsView(),
        // stub opcional para evitar erro no botão "Forgot"
        '/forgot': (_) => const Scaffold(
              body: Center(child: Text('Recuperar senha (em breve)')),
            ),
      },

      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text(
              'Rota não encontrada.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
