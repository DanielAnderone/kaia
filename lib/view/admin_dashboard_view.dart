import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../viewmodel/admin_viewmodel.dart';
import '../model/admin_stats.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel()..loadDashboardData(),
      child: Consumer<AdminViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            drawer: MediaQuery.of(context).size.width <= 800
                ? const _SidebarDrawer()
                : null,
            appBar: MediaQuery.of(context).size.width <= 800
                ? AppBar(
              backgroundColor: const Color(0xFF386641),
              title: Text("Painel Administrativo",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            )
                : null,
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
              children: [
                if (MediaQuery.of(context).size.width > 800)
                  const _Sidebar(),
                Expanded(
                  child: _DashboardContent(
                    stats: vm.stats,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Sidebar fixa para web
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Symbols.egg, color: Color(0xFF386641), size: 32),
              const SizedBox(width: 8),
              Text("Kaia Invest",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _SidebarButton(icon: Symbols.dashboard, label: "Painel", selected: true),
          _SidebarButton(
            icon: Symbols.group,
            label: "Investidores",
            onTap: () {
              Navigator.pushNamed(context, '/investidores');
            },
          ),
          _SidebarButton(
            icon: Symbols.folder,
            label: "Projetos de Investimento",
            onTap: () {
              Navigator.pushNamed(context, '/projetos');
            },
          ),
          _SidebarButton(
            icon: Symbols.settings,
            label: "Configurações",
            onTap: () {
              Navigator.pushNamed(context, '/configuracoes');
            },
          ),
          const Spacer(),
          _SidebarButton(
            icon: Symbols.logout,
            label: "Sair",
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

// Drawer para mobile/tablet
class _SidebarDrawer extends StatelessWidget {
  const _SidebarDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF386641)),
            child: Row(
              children: [
                const Icon(Symbols.egg, color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text("Kaia Invest",
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          _SidebarButton(icon: Symbols.dashboard, label: "Painel", selected: true, onTap: () {
            Navigator.pop(context);
          }),
          _SidebarButton(
            icon: Symbols.group,
            label: "Investidores",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/investidores');
            },
          ),
          _SidebarButton(
            icon: Symbols.folder,
            label: "Gestao de investimentos",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/investiment');
            },
          ),
          _SidebarButton(
            icon: Symbols.settings,
            label: "Configurações",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/configuracoes');
            },
          ),
          const Spacer(),
          _SidebarButton(
            icon: Symbols.logout,
            label: "Sair",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: selected ? const Color(0xFF386641) : Colors.grey[600]),
        title: Text(label,
            style: GoogleFonts.inter(
              color: selected ? const Color(0xFF386641) : Colors.grey[700],
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            )),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final List<AdminStats> stats;

  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (MediaQuery.of(context).size.width > 800)
                Text("Painel Administrativo",
                    style: GoogleFonts.inter(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/admin-profile');
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black87),
                ),
              ),

            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: stats.map((s) => _StatCard(stat: s)).toList(),
          ),
          const SizedBox(height: 24),
          const _QuickActions(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final AdminStats stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: Color(0xFFF2C46D), size: 28),
          const SizedBox(height: 8),
          Text(stat.title,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(stat.value,
              style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final buttons = [
      {
        "label": "Ver Investidores",
        "route": "/investidores",
      },
      {
        "label": "Adicionar Projeto",
        "route": "/adicionar-projeto",
      },
      {
        "label": "Gestao de investimentos",
        "route": "/investiment",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ações Rápidas",
            style:
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (final btn in buttons)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, btn["route"]!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386641),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(btn["label"]!,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}
