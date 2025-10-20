// lib/view/my_investments_view.dart
import 'package:flutter/material.dart';
import '../model/investment.dart';

class MyInvestmentsView extends StatefulWidget {
  final String Function(int projectId)? projectNameOf;
  final List<Investment> investments;

  const MyInvestmentsView({
    super.key,
    required this.investments,
    this.projectNameOf,
  });

  @override
  State<MyInvestmentsView> createState() => _MyInvestmentsViewState();
}

enum _Filter { active, inactive }

class _MyInvestmentsViewState extends State<MyInvestmentsView> {
  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  _Filter _filter = _Filter.active;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final active = widget.investments.where((i) => i.isActive).toList();
    final inactive = widget.investments.where((i) => !i.isActive).toList();
    var list = _filter == _Filter.active ? active : inactive;

    String titleOf(Investment i) =>
        widget.projectNameOf?.call(i.projectId) ?? 'Projeto #${i.projectId}';

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((i) => titleOf(i).toLowerCase().contains(q)).toList();
    }

    final totalCount = list.length;
    final totalInvested = list.fold<double>(0, (s, i) => s + i.investedAmount);
    final totalProfit = list.fold<double>(
      0,
      (s, i) => s + (_filter == _Filter.active ? i.estimatedProfit : i.actualProfit),
    );

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Meus Investimentos',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // Linha de busca + filtro verde à direita
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar investimentos',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<_Filter>(
                  value: _filter,
                  isDense: true,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  iconEnabledColor: Colors.white,
                  iconDisabledColor: Colors.white,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: primary,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primary),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primary, width: 1.2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: _Filter.active,
                      child: Text('Ativos', style: TextStyle(color: Colors.black87)),
                    ),
                    DropdownMenuItem(
                      value: _Filter.inactive,
                      child: Text('Não ativos', style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filter = v ?? _filter),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3 cards em linha
          Row(
            children: [
              Expanded(child: _SummaryCard(title: 'Investimentos', value: '$totalCount')),
              const SizedBox(width: 8),
              Expanded(child: _SummaryCard(title: 'Investido', value: _mt(totalInvested))),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryCard(
                  title: _filter == _Filter.active ? 'Retorno estimado' : 'Retorno real',
                  value: _mt(totalProfit),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lista “como na imagem”: cartões brancos, chip à direita, linhas investido/lucro/data
          if (list.isEmpty)
            _Empty(message: _filter == _Filter.active ? 'Sem investimentos ativos.' : 'Sem investimentos não ativos.')
          else
            ...list.map(
              (i) => _InvestmentRow(
                title: titleOf(i),
                invested: i.investedAmount,
                profitLabel: _filter == _Filter.active ? 'Profit:' : 'Profit:',
                profitValue: _filter == _Filter.active ? i.estimatedProfit : i.actualProfit,
                date: i.applicationDate,
                statusChip: _filter == _Filter.active
                    ? _chip('Active', const Color(0xFFE8F8EE), primary)
                    : _chip('Completed', const Color(0xFFE9F0FF), const Color(0xFF3B82F6)),
                onTap: _filter == _Filter.inactive ? () => _showInvested(context, i) : null,
              ),
            ),
        ],
      ),
    );
  }

  static void _showInvested(BuildContext context, Investment i) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Valor investido', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_mt(i.investedAmount),
                style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if ((i.note ?? '').isNotEmpty)
              Text('Nota: ${i.note!}', style: const TextStyle(color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar', style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  static Widget _chip(String t, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(t, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  static String _mt(num v) {
    final s = v.toInt().toString();
    final b = StringBuffer();
    var c = 0;
    for (var i = s.length - 1; i >= 0; i--) { b.write(s[i]); c++; if (c == 3 && i != 0) { b.write('.'); c = 0; } }
    return 'MT ${b.toString().split('').reversed.join()}';
  }
}

// ===== widgets =====
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _InvestmentRow extends StatelessWidget {
  final String title;
  final double invested;
  final String profitLabel;
  final double profitValue;
  final DateTime date;
  final Widget statusChip;
  final VoidCallback? onTap;

  const _InvestmentRow({
    required this.title,
    required this.invested,
    required this.profitLabel,
    required this.profitValue,
    required this.date,
    required this.statusChip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // título + chip à direita
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                      ),
                      statusChip,
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Invested: ${_MyInvestmentsViewState._mt(invested)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('$profitLabel ',
                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      Text(_MyInvestmentsViewState._mt(profitValue),
                          style: const TextStyle(color: Color(0xFF169C1D), fontSize: 12, fontWeight: FontWeight.w700)),
                      const Text(' ↑', style: TextStyle(color: Color(0xFF169C1D), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(_fmtDate(date), style: const TextStyle(color: Colors.black45, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _iconBox() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: const Color(0xFFEFF2FF), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.payments, color: Color(0xFF4F46E5)),
    );
  }

  static String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: const TextStyle(color: Colors.black54)),
    );
  }
}
