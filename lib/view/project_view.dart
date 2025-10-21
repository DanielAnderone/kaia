import 'package:flutter/material.dart';
import '../model/project.dart';
import 'projectsdetail.dart';
import '../widgts/netimage.dart';
import '../widgts/app_bottom.dart';
import '../service/project_service.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final projCols = (width ~/ 180).clamp(2, 3);
    final service = ProjectService();

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: FutureBuilder<List<Project>>(
          future: service.listProjects(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erro ao carregar projetos'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => (context as Element).markNeedsBuild(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final projetos = snap.data ?? [];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(isDark, context)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Projetos',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsView(project: p),
                            ),
                          ),
                        );
                      },
                      childCount: projetos.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: projCols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 64)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.Inicio),
    );
  }

  // -------- Cabeçalho com perfil e notificações mock --------
  static Widget _header(bool isDark, BuildContext context) => Container(
        color: isDark ? bgDark : bgLight,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showMockProfile(context),
              child: const _Avatar(url: 'https://picsum.photos/seed/login-mock/80/80'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Olá',
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => _showMockNotifications(context),
            ),
          ],
        ),
      );

  // -------- MOCK Perfil --------
  static void _showMockProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Perfil (mock)',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://picsum.photos/seed/login-mock/120/120'),
            ),
            SizedBox(height: 12),
            Text('Nome: Usuário Demo', style: TextStyle(color: Colors.black87)),
            SizedBox(height: 4),
            Text('Email: demo@exemplo.com', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 4),
            Text('Plano: Básico', style: TextStyle(color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar', style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  // -------- MOCK Notificações --------
  static void _showMockNotifications(BuildContext context) {
    final items = [
      ('Pagamento aprovado', 'Seu investimento #103 foi confirmado.'),
      ('Projeto atualizado', 'Golden Egg Farms publicou um novo relatório.'),
      ('Depósito recebido', 'Depósito MT 2.500 creditado.'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Notificações (mock)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemBuilder: (_, i) {
                  final (title, body) = items[i];
                  return ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE7F5EA),
                        child: Icon(Icons.notifications, color: primary)),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(body),
                    trailing: const Text('agora',
                        style: TextStyle(color: Colors.black45, fontSize: 12)),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
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

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onOpen;
  const _ProjectCard({required this.project, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    const green = ProjectsView.primary;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[300]! : Colors.black87;

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
            )
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
                  Text(project.name ?? 'Sem nome',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Mín. investimento: MT ${project.minimumInvestment.toInt()}',
                      style: TextStyle(color: textSecondary, fontSize: 11)),
                  Text('Rentabilidade: ${project.profitabilityPercent.toStringAsFixed(0)}%',
                      style: TextStyle(color: textSecondary, fontSize: 11)),
                  Text('Estado: ${project.status}',
                      style: TextStyle(color: textSecondary, fontSize: 11)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: onOpen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
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
}
