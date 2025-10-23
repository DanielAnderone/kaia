import 'package:flutter/material.dart';
import 'package:kaia_app/view/client/profile_view.dart';
import './view/login_view.dart';
import './view/signup_view.dart';
import 'view/client/project_view.dart';
import 'view/client/paymentView.dart';
import 'view/client/investmentview.dart';
import 'view/client/transactions_view.dart';
import 'view/admin/admin_dashboard_view.dart';
import 'view/admin/admin_profile_screen.dart';
import 'view/admin/admin_project_management_view.dart';
import 'view/admin/admin_settings_view.dart';
import 'view/admin/investment_management_view.dart';
import 'view/client/investors_view.dart';

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
        '/investor/projects': (_) => const ProjectsView(),   // home após login
        '/investor/payments': (_) => const PaymentView(),
        '/investor/transactions': (_) => const TransactionsView(),
        '/investor/profile': (_) => const AccountView(),
        '/investor/investiments': (_) => const InvestmentsView(),
        '/admin/investiments': (context) => const InvestmentManagementView(),
        '/admin/dashboard': (context) => const AdminDashboardView(),
        '/admin/pgmanagement': (context) => const AdminProjectManagementView(),
        '/admin/investors': (context) => const InvestorsView(),
        '/admin/profile': (context) => const AdminProfileScreen(),
        '/admin/settings': (context) => const AdminSettingsView(),
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
