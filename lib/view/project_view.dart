// lib/view/projects_view.dart
import 'package:flutter/material.dart';
import '../model/project.dart';
import 'projectsdetail.dart';
import '../widgts/netimage.dart';
import 'investmentview.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    final statCols = (width ~/ 150).clamp(2, 3);
    final projCols = (width ~/ 180).clamp(2, 3);

    // Mock alinhado ao backend
    final projetos = <Project>[
      Project(
        id: 1,
        ownerId: 10,
        name: 'Fazenda Hen Haven',
        description: 'Expansão de aviários com eficiência energética.',
        startDate: DateTime(2025, 1, 10),
        endDate: DateTime(2025, 11, 10),
        totalProfit: 3200,
        profitabilityPercent: 25,
        minimumInvestment: 10000,
        riskLevel: 'medio',
        status: 'Ativo',
        investmentAchieved: 6200,
        imageUrl: 'https://picsum.photos/seed/henhaven/1200/800',
      ),
      Project(
        id: 2,
        ownerId: 11,
        name: 'Sunrise Poultry',
        description: 'Lote concluído. Próxima fase com certificações.',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 11, 1),
        totalProfit: 2900,
        profitabilityPercent: 18,
        minimumInvestment: 15000,
        riskLevel: 'baixo',
        status: 'Financiado',
        investmentAchieved: 15000,
        imageUrl: 'https://picsum.photos/seed/sunrise/1200/800',
      ),
      Project(
        id: 3,
        ownerId: 12,
        name: 'Golden Egg Farms',
        description: 'Automação de coleta e cadeia fria.',
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2026, 2, 1),
        totalProfit: 0,
        profitabilityPercent: 22,
        minimumInvestment: 20000,
        riskLevel: 'alto',
        status: 'Ativo',
        investmentAchieved: 9800,
        imageUrl: 'https://picsum.photos/seed/golden/1200/800',
      ),
    ];

    final ativos = projetos.where((p) => p.status == 'Ativo').length;
    final total = projetos.length;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Container(
                color: isDark ? bgDark : bgLight,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const _Avatar(url: 'https://picsum.photos/seed/avatar/80/80'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Olá',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Métricas topo
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate.fixed([
                  _StatCard(title: 'Projetos Ativos', value: '$ativos'),
                  _StatCard(title: 'Total Projetos', value: '$total'),
                  _StatCard(
                    title: 'Invest. Total (mock)',
                    value: _mt(projetos.fold<num>(0, (a, b) => a + b.investmentAchieved)),
                  ),
                ]),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: statCols,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 84,
                ),
              ),
            ),

            // Título
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Projetos',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            ),

            // Grid de projetos
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = projetos[i];
                    return _ProjectCard(
                      project: p,
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProjectDetailsView(project: p)),
                      ),
                    );
                  },
                  childCount: projetos.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: projCols,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 64)),
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
          ),
        ),
        child: Row(
          children: [
            const _NavItem(label: 'Início', icon: Icons.space_dashboard, selected: true),
            const _NavItem(label: 'Projetos', icon: Icons.business_center),
            _NavItem(
              label: 'Investimentos',
              icon: Icons.pie_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyInvestmentsView(
                      investments: [], // preencha com dados do backend
                    ),
                  ),
                );
              },
            ),
            const _NavItem(label: 'Perfil', icon: Icons.person),
          ],
        ),
      ),
    );
  }

  static String _mt(num v) {
    final s = v.toInt().toString();
    final b = StringBuffer();
    var c = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      b.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        b.write('.');
        c = 0;
      }
    }
    return 'MT ${b.toString().split('').reversed.join()}';
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: NetImage(url, width: 40, height: 40, fit: BoxFit.cover),
    );
    }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onOpen;

  const _ProjectCard({required this.project, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    const green = ProjectsView.primary;
    const black = Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: NetImage(project.imageUrl ?? ''),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Line(label: 'Mín. investimento', value: _fmtMt(project.minimumInvestment)),
                  _Line(label: 'Rentabilidade', value: '${project.profitabilityPercent.toStringAsFixed(0)}%'),
                  _Line(label: 'Estado', value: project.status),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onOpen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      child: const Text('Ver detalhes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtMt(num v) {
    final s = v.toInt().toString();
    final b = StringBuffer();
    var c = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      b.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        b.write('.');
        c = 0;
      }
    }
    return 'MT ${b.toString().split('').reversed.join()}';
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.black87, fontSize: 11.5),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? ProjectsView.primary : Colors.grey[500];
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
