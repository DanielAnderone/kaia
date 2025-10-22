import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view/admin_dashboard_view.dart';
import 'view/investors_view.dart';
import 'view/admin_project_management_view.dart';
import 'view/investment_management_view.dart';
import 'view/admin_profile_screen.dart';
import 'view/admin_settings_view.dart';

import 'viewmodel/investor_viewmodel.dart';
import 'viewmodel/admin_settings_viewmodel.dart'; // Adicionado

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvestorViewModel()),
        ChangeNotifierProvider(
          create: (_) => AdminSettingsViewModel()..loadSettings(),
        ),
      ],
      child: const KaiaApp(),
    ),
  );
}

class KaiaApp extends StatelessWidget {
  const KaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<AdminSettingsViewModel>(context);
    final isDark = settingsViewModel.settings?.theme == 'dark';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaia Invest',
      theme: ThemeData(
        primaryColor: const Color(0xFF386641),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF386641),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF386641),
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const AdminDashboardView(),
        '/investidores': (context) => const InvestorsView(),
        '/adicionar-projeto': (context) => const AdminProjectManagementView(),
        '/investiment': (context) => const InvestmentManagementView(),
        '/admin-profile': (context) => const AdminProfileScreen(),
        '/configuracoes': (context) => const AdminSettingsView(),
      },
    );
  }
}
