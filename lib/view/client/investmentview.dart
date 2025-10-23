// lib/view/my_investments_view.dart
import 'package:flutter/material.dart';
import '../../model/investment.dart';
import '../../widgts/app_bottom.dart';
import '../../service/investiment_service.dart';

class InvestmentsView extends StatefulWidget {
  final String Function(int projectId)? projectNameOf;
  final List<Investment> investments;

  const InvestmentsView({ super.key, this.projectNameOf, this.investments = const [] });

  @override
  State<InvestmentsView> createState() => _InvestmentsViewState();
}

enum _Filter { active, inactive }

class _InvestmentsViewState extends State<InvestmentsView> {
  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  late List<Investment> _items;
  late final InvestmentService _service;

  _Filter _filter = _Filter.active;
  String _query = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _items = widget.investments.isNotEmpty ? widget.investments : [];
    _service = InvestmentService();
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getAll();
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = _mock());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao carregar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final active = _items.where((i) => i.isActive).toList();
    final inactive = _items.where((i) => !i.isActive).toList();
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
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primary))
                : Icon(Icons.sync, color: isDark ? Colors.white : Colors.black87),
            onPressed: _loading ? null : _loadFromApi,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: _loadFromApi,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) {
                      _query = v;
                      _loadFromApi();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar investimentos',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      enabledBorder: OutlineInputBorder(
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
            if (_loading && _items.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (list.isEmpty)
              _Empty(message: _filter == _Filter.active ? 'Sem investimentos ativos.' : 'Sem investimentos não ativos.')
            else
              ...list.map(
                (i) => _InvestmentRow(
                  title: titleOf(i),
                  invested: i.investedAmount,
                  profitLabel: _filter == _Filter.active ? 'Estimado:' : 'Real:',
                  profitValue: _filter == _Filter.active ? i.estimatedProfit : i.actualProfit,
                  date: i.applicationDate,
                  statusChip: _filter == _Filter.active
                      ? _chip('Active', const Color(0xFFE8F8EE), primary)
                      : _chip('Completed', const Color(0xFFE9F0FF), const Color(0xFF3B82F6)),
                  onTap: () => _showDetails(context, i, titleOf(i)),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.investments),
    );
  }

  // Popup de detalhes
  void _showDetails(BuildContext context, Investment i, String title) {
    final isActive = i.isActive;
    final profitLabel = isActive ? 'Retorno estimado' : 'Retorno real';
    final profitValue = isActive ? i.estimatedProfit : i.actualProfit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                    ),
                    _chip(isActive ? 'Active' : 'Completed', isActive ? const Color(0xFFE8F8EE) : const Color(0xFFE9F0FF),
                        isActive ? primary : const Color(0xFF3B82F6)),
                  ],
                ),
                const SizedBox(height: 12),
                _kv('Investido', _mt(i.investedAmount)),
                _kv(profitLabel, _mt(profitValue)),
                _kv('Aplicado em', _fmtDate(i.applicationDate)),
                if ((i.note ?? '').isNotEmpty) _kv('Nota', i.note!),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: primary),
                          label: const Text('Fechar', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mock compatível com o modelo atual (status é derivado)
  List<Investment> _mock() {
    final now = DateTime.now();
    return [
      Investment(
        id: 1,
        projectId: 101,
        investorId: 1,
        investedAmount: 5000,
        applicationDate: DateTime(now.year, 6, 15),
        estimatedProfit: 1250,
        actualProfit: 0,
        note: 'Lote 12',
        createdAt: DateTime(now.year, 6, 15),
        updatedAt: null,
      ),
      Investment(
        id: 2,
        projectId: 102,
        investorId: 1,
        investedAmount: 3000,
        applicationDate: DateTime(now.year, 5, 20),
        estimatedProfit: 750,
        actualProfit: 0,
        note: 'Lote 08',
        createdAt: DateTime(now.year, 5, 20),
        updatedAt: null,
      ),
      Investment(
        id: 3,
        projectId: 103,
        investorId: 1,
        investedAmount: 10000,
        applicationDate: DateTime(now.year, 4, 10),
        estimatedProfit: 0,
        actualProfit: 2800,
        note: 'Lote 05',
        createdAt: DateTime(now.year, 4, 10),
        updatedAt: DateTime(now.year, 9, 30),
      ),
    ];
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

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Flexible(child: Text(v, textAlign: TextAlign.end)),
        ]),
      );

  static String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
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
                  Row(children: [
                    Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                    ),
                    statusChip,
                  ]),
                  const SizedBox(height: 6),
                  Text('Invested: ${_InvestmentsViewState._mt(invested)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('$profitLabel ', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      Text(_InvestmentsViewState._mt(profitValue),
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
