import 'package:flutter/material.dart';
import 'package:kaia_app/utils/token_manager.dart';
import 'package:kaia_app/viewmodel/investor_viewmodel.dart';
import '../../model/project.dart';
import '../../model/investor.dart';
import '../../widgts/netImage.dart';
import '../../service/investor_service.dart';

class ProjectDetailsView extends StatelessWidget {
  final Project project;
  const ProjectDetailsView({super.key, required this.project});

  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(isDark, context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: NetImage(project.imageUrl ?? ''),
                    ),
                    _titleAndStatus(isDark),
                    _metricsGrid(isDark),
                    _description(isDark),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final w = MediaQuery.of(context).size.width;
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            color: isDark ? bgDark : bgLight,
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: w * 0.5,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        _showInvestorDialog(context, userIdProvider: () => 1),
                    child: const Text(
                      'Investir agora',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _appBar(bool isDark, BuildContext context) => Container(
        color: isDark ? bgDark : bgLight,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Detalhes do Projeto',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            IconButton(
              icon: Icon(Icons.share,
                  color: isDark ? Colors.white : Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
      );

  Widget _titleAndStatus(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name ?? 'Projeto',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                project.status ?? 'Em progresso',
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _metricsGrid(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 64,
          ),
          children: [
            _MetricCard(
              icon: Icons.attach_money,
              titulo: 'Mín. investimento',
              valor: _mt(project.minimumInvestment ?? 0),
            ),
            _MetricCard(
              icon: Icons.trending_up,
              titulo: 'Rentabilidade',
              valor:
                  '${(project.profitabilityPercent ?? 0).toStringAsFixed(0)}%',
            ),
            _MetricCard(
              icon: Icons.shield,
              titulo: 'Risco',
              valor: _riskLabel(project.riskLevel ?? ''),
            ),
            _MetricCard(
                icon: Icons.calendar_month,
                titulo: 'Período',
                valor: "" // _dateRange(project.startDate, project.endDate),
                ),
            _MetricCard(
              icon: Icons.account_balance_wallet,
              titulo: 'Arrecadado',
              valor: _mt(project.investmentAchieved ?? 0),
            ),
            if (project.totalProfit != null)
              _MetricCard(
                icon: Icons.ssid_chart,
                titulo: 'Lucro total',
                valor: _mt(project.totalProfit!),
              ),
          ],
        ),
      );

  Widget _description(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[900],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.description ?? 'Sem descrição disponível.',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.35,
              ),
            ),
          ],
        ),
      );

  Future<void> _showInvestorDialog(
    BuildContext context, {
    required int Function() userIdProvider,
  }) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    final identityCard = TextEditingController();
    final nuit = TextEditingController();
    final bornDateCtrl = TextEditingController();
    DateTime? bornDate;

    String? req(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

    Future<void> pickDate() async {
      final now = DateTime.now();
      final init = DateTime(now.year - 18, now.month, now.day);
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: now,
        initialDate: init,
        helpText: 'Selecione a data de nascimento',
        confirmText: 'OK',
        cancelText: 'Cancelar',
      );
      if (picked != null) {
        bornDate = picked;
        bornDateCtrl.text = _fmtDate(picked);
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cadastro de Investidor',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: name,
                    validator: req,
                    decoration:
                        const InputDecoration(labelText: 'Nome completo')),
                const SizedBox(height: 4),
                TextFormField(
                    controller: phone,
                    validator: req,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Telefone')),
                const SizedBox(height: 4),
                TextFormField(
                  controller: bornDateCtrl,
                  readOnly: true,
                  onTap: pickDate,
                  validator: (_) => bornDate == null ? 'Obrigatório' : null,
                  decoration: const InputDecoration(
                    labelText: 'Data de nascimento',
                    suffixIcon: Icon(Icons.event, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                    controller: identityCard,
                    validator: req,
                    decoration: const InputDecoration(
                        labelText: 'Bilhete de Identidade / Doc.')),
                const SizedBox(height: 4),
                TextFormField(
                    controller: nuit,
                    validator: req,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'NUIT')),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.black87)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.black54),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              var investor = Investor(
                userId: userIdProvider(),
                name: name.text.trim(),
                phone: phone.text.trim(),
                bornDate: bornDate!,
                identityCard: identityCard.text.trim(),
                nuit: nuit.text.trim(),
              );

              try {
                final payload = await SesManager.getPayload();
                Investor? created; // declarar fora do if

                if (payload.id == 0) {
                  final created = await InvestorViewModel().createInvestor(investor);
                  if (created == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao criar conta de investidor.')),
                      );
                    }
                    return; // interrompe se falhou
                  }
                  investor = created;
                } else {

                  investor = investor;
                }

                if (context.mounted) Navigator.pop(ctx);

                if (context.mounted && created == null) {
                  Navigator.pushNamed(
                    context,
                    '/investor/payments',
                    arguments: {'investor': created, 'project': project},
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao cadastrar investidor: $e')),
                  );
                }
              }
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  static String _riskLabel(String v) {
    switch (v.toLowerCase()) {
      case 'baixo':
        return 'Baixo';
      case 'medio':
        return 'Médio';
      case 'alto':
        return 'Alto';
      default:
        return v;
    }
  }

  static String _dateRange(DateTime? s, DateTime? e) {
    String f(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (s == null && e == null) return 'Sem datas';
    if (s != null && e == null) return 'Início: ${f(s)}';
    if (s == null && e != null) return 'Término: ${f(e)}';
    return '${f(s!)} → ${f(e!)}';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  const _MetricCard(
      {required this.icon, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: ProjectDetailsView.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(valor,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
