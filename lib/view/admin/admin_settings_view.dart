import 'package:flutter/material.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  bool _loading = true;
  String? _error;

  // Estado das configurações
  bool _pushNotifications = false;
  bool _emailNotifications = false;
  bool _twoFactorEnabled = false;
  String _theme = 'light';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Simula carregamento das configurações
  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Aqui você carregaria de uma API ou local storage
      _pushNotifications = true;
      _emailNotifications = true;
      _twoFactorEnabled = false;
      _theme = 'dark';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updatePushNotifications(bool value) => setState(() => _pushNotifications = value);
  void _updateEmailNotifications(bool value) => setState(() => _emailNotifications = value);
  void _updateTwoFactor(bool value) => setState(() => _twoFactorEnabled = value);
  void _updateTheme(String value) => setState(() => _theme = value);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Erro: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Administrador'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/admin/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notificações', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: _pushNotifications,
              onChanged: _updatePushNotifications,
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: _emailNotifications,
              onChanged: _updateEmailNotifications,
            ),
            const SizedBox(height: 16),
            const Text('Aparência', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ChoiceChip(label: const Text('Light'), selected: _theme == 'light', onSelected: (s) => _updateTheme('light')),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Dark'), selected: _theme == 'dark', onSelected: (s) => _updateTheme('dark')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Segurança', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Autenticação de Dois Fatores'),
              subtitle: const Text('Adicione uma camada extra de segurança à sua conta.'),
              value: _twoFactorEnabled,
              onChanged: _updateTwoFactor,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  // Aqui você faria a lógica real de logout
                  await Future.delayed(const Duration(milliseconds: 500));
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
  }
}
