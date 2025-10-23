// lib/widgts/app_bottom.dart
import 'package:flutter/material.dart';
const _primary = Color(0xFF169C1D);

enum AppTab { Inicio, investments, transacao, profile }

class AppBottomNav extends StatelessWidget {
  final AppTab current;
  const AppBottomNav({super.key, required this.current});

  Future<void> _go(BuildContext context, AppTab tab) async {
    if (tab == current) return;

    String route;
    switch (tab) {
      case AppTab.Inicio:
        route = '/investor/projects';
        break;
      case AppTab.investments:
        route = '/investor/investiments';
        break;
      case AppTab.transacao:
        route = '/investor/transactions';
        break;
      case AppTab.profile:
        route = '/investor/profile';
        break;
    }

    // Loader compacto
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (_) => const Center(child: _GalaxyLoader()),
    );
    await Future.delayed(const Duration(milliseconds: 250));

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // fecha loader

    // Navegação estável por rota nomeada
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
          ),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            label: 'Início',
            icon: Icons.home,
            selected: current == AppTab.Inicio,
            onTap: () => _go(context, AppTab.Inicio),
          ),
          _NavItem(
            label: 'Investimentos',
            icon: Icons.pie_chart,
            selected: current == AppTab.investments,
            onTap: () => _go(context, AppTab.investments),
          ),
          _NavItem(
            label: 'Transações',
            icon: Icons.receipt_long,
            selected: current == AppTab.transacao,
            onTap: () => _go(context, AppTab.transacao),
          ),
          _NavItem(
            label: 'Perfil',
            icon: Icons.person,
            selected: current == AppTab.profile,
            onTap: () => _go(context, AppTab.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _primary : Colors.grey[500];
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalaxyLoader extends StatelessWidget {
  const _GalaxyLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3.3,
          color: Colors.white,
        ),
      ),
    );
  }
}
