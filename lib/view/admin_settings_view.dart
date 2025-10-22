import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_settings_viewmodel.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSettingsViewModel>(
      builder: (context, viewModel, child) {
        final settings = viewModel.settings;

        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.error != null) {
          return Scaffold(
            body: Center(
              child: Text('Erro: ${viewModel.error}'),
            ),
          );
        }

        if (settings == null) {
          return const Scaffold(
            body: Center(
              child: Text('Nenhuma configuração encontrada.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações do Administrador'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Volta para a tela anterior (dashboard)
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  value: settings.pushNotifications,
                  onChanged: viewModel.updatePushNotifications,
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  value: settings.emailNotifications,
                  onChanged: viewModel.updateEmailNotifications,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aparência',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Light'),
                      selected: settings.theme == 'light',
                      onSelected: (selected) {
                        if (selected) viewModel.updateTheme('light');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Dark'),
                      selected: settings.theme == 'dark',
                      onSelected: (selected) {
                        if (selected) viewModel.updateTheme('dark');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Segurança',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Autenticação de Dois Fatores'),
                  subtitle: const Text('Adicione uma camada extra de segurança à sua conta.'),
                  value: settings.twoFactorEnabled,
                  onChanged: viewModel.updateTwoFactor,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      await viewModel.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout realizado com sucesso!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
