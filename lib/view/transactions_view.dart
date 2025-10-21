// lib/view/transactions_view.dart
import 'package:flutter/material.dart';
import '../model/transaction.dart';
import '../widgts/app_bottom.dart';

class TransactionsView extends StatefulWidget {
  final List<Transaction> items;
  const TransactionsView({super.key, this.items = const []});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

enum _TxFilter { all, pending, processing, approved, failed, refunded }

class _TransactionsViewState extends State<TransactionsView> {
  // Cores do app
  static const green = Color(0xFF169C1D);
  static const red = Color(0xFFE53935);
  static const bgLight = Colors.white; // fundo branco
  static const bgDark = Color(0xFF101722);

  late List<Transaction> _all;

  final Map<int, double> paymentAmounts = {
    1: 150.00,
    2: 75.50,
    3: 2300.00,
    4: 99.90,
    5: 500.00
  };
  final Map<int, String> paymentCurrency = {
    1: 'MT',
    2: 'MT',
    3: 'MT',
    4: 'MT',
    5: 'MT'
  };

  _TxFilter _filter = _TxFilter.all;
  String _query = '';
  bool _loading = false;
  int _seed = 0; // só para variar o mock no refresh

  @override
  void initState() {
    super.initState();
    _all = widget.items.isNotEmpty ? widget.items : _mock();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    _seed++;
    setState(() {
      _all = _mock(); // aqui você pode trocar por chamada real de API
      _loading = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transações atualizadas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final list = _applyFilters();

    final total = list.fold<double>(0, (s, t) => s + (paymentAmounts[t.paymentId] ?? 0));
    final approvedCount = list.where((t) => _statusOf(t) == 'approved').length;
    final failedCount = list.where((t) => _statusOf(t) == 'failed').length;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transações',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: _loading
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: green))
              : Icon(Icons.sync, color: isDark ? Colors.white : Colors.black87),
          onPressed: _loading ? null : _refresh,
          tooltip: 'Atualizar',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list, color: green), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        color: green,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar por ID, referência...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _chipFilter('Todos', _TxFilter.all),
                      _chipFilter('Pendente', _TxFilter.pending),
                      _chipFilter('Aprovada', _TxFilter.approved),
                      _chipFilter('Falhada', _TxFilter.failed),
                      _chipFilter('Processando', _TxFilter.processing),
                      _chipFilter('Reembolsada', _TxFilter.refunded),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                _roundIcon(isDark, Icons.calendar_today),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _summaryCard('Total no período', _money(total), Colors.black87)),
                const SizedBox(width: 8),
                Expanded(child: _summaryCard('Aprovadas', '$approvedCount', green)),
                const SizedBox(width: 8),
                Expanded(child: _summaryCard('Falhadas', '$failedCount', red)),
              ],
            ),
            const SizedBox(height: 14),
            if (list.isEmpty)
              _empty()
            else
              ...list.map((t) => _txCard(context, t, isDark)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.transacao),
    );
  }

  // Empty state
  Widget _empty() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Sem transações no período', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Ajuste os filtros ou escolha outro período.', style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      );

  // Filtros
  Widget _chipFilter(String label, _TxFilter f) {
    final selected = _filter == f;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _filter = f),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? green.withOpacity(.12) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? green : const Color(0xFFE5E7EB)),
          ),
          child: Text(label, style: TextStyle(color: selected ? green : Colors.black87, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // Resumo
  Widget _summaryCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  // Item da lista
  Widget _txCard(BuildContext context, Transaction t, bool isDark) {
    final amount = paymentAmounts[t.paymentId] ?? 0;
    final curr = paymentCurrency[t.paymentId] ?? 'MT';
    final status = _statusOf(t);
    final (dot, color, label) = _statusVisual(status);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showDetails(context, t, amount, curr),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ]),
            Text(_money(amount, curr: curr),
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_mask(t.payerAccount), style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text(_short(t.transactionId), style: const TextStyle(color: Colors.black45, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }

  // Popup de detalhes (mantido)
  void _showDetails(BuildContext context, Transaction t, double amount, String curr) {
    final (dot, color, label) = _statusVisual(_statusOf(t));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
                ]),
                Text(_money(amount, curr: curr), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ]),
              const Divider(),
              _kv('Moeda', curr),
              _kv('Conta', t.payerAccount),
              _kv('Gateway Ref', t.gatewayRef),
              _kv('Transaction ID', t.transactionId),
              _kv('Criado em', _dt(t.createdAt, withTime: true)),
              _kv('Atualizado em', t.updatedAt == null ? '-' : _dt(t.updatedAt!, withTime: true)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _pillBtn(icon: Icons.copy, text: 'Copiar ID', onTap: () {})),
                const SizedBox(width: 8),
                Expanded(child: _solidBtn(icon: Icons.open_in_new, text: 'Ver no gateway', onTap: () {})),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Flexible(child: Text(v, textAlign: TextAlign.end)),
        ]),
      );

  Widget _pillBtn({required IconData icon, required String text, required VoidCallback onTap}) => SizedBox(
        height: 44,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: green),
          label: Text(text, style: const TextStyle(color: green, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: green),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );

  Widget _solidBtn({required IconData icon, required String text, required VoidCallback onTap}) => SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
          label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );

  Widget _roundIcon(bool isDark, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C2431) : Colors.white, borderRadius: BorderRadius.circular(999)),
      child: Icon(icon, color: green),
    );
  }

  List<Transaction> _applyFilters() {
    Iterable<Transaction> it = _all;
    if (_filter != _TxFilter.all) {
      final key = _filter.name;
      it = it.where((t) => _statusOf(t) == key);
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      it = it.where((t) =>
          t.transactionId.toLowerCase().contains(q) ||
          t.gatewayRef.toLowerCase().contains(q) ||
          t.payerAccount.toLowerCase().contains(q));
    }
    return it.toList();
  }

  // Regra de status provisória
  String _statusOf(Transaction t) {
    switch (t.paymentId) {
      case 1:
        return 'approved';
      case 2:
        return 'pending';
      case 3:
        return 'failed';
      case 4:
        return 'processing';
      case 5:
        return 'refunded';
      default:
        return 'pending';
    }
  }

  // Mock com variação mínima
  List<Transaction> _mock() {
    final now = DateTime.now();
    final shift = _seed % 2;
    return [
      Transaction(
        id: 1,
        paymentId: shift == 0 ? 1 : 4,
        investorId: 7,
        payerAccount: '258841231234',
        gatewayRef: 'REF123456789',
        transactionId: 'TXN456789123',
        createdAt: DateTime(now.year, now.month, now.day, 14, 30),
        updatedAt: DateTime(now.year, now.month, now.day, 14, 31),
      ),
      Transaction(
        id: 2,
        paymentId: 2,
        investorId: 7,
        payerAccount: '258848765678',
        gatewayRef: 'REF456789111',
        transactionId: 'TXN789222333',
        createdAt: DateTime(now.year, now.month, now.day, 12, 15),
        updatedAt: null,
      ),
      Transaction(
        id: 3,
        paymentId: 3,
        investorId: 7,
        payerAccount: '258849009012',
        gatewayRef: 'REF789000999',
        transactionId: 'TXN123000111',
        createdAt: DateTime(now.year, now.month, now.day - 1, 23, 59),
        updatedAt: DateTime(now.year, now.month, now.day - 1, 23, 59, 50),
      ),
      Transaction(
        id: 4,
        paymentId: 5,
        investorId: 7,
        payerAccount: '258847897890',
        gatewayRef: 'REFXYZ12345',
        transactionId: 'TXN111222333',
        createdAt: DateTime(now.year, now.month, now.day - 2, 10, 0),
        updatedAt: DateTime(now.year, now.month, now.day - 2, 11, 0),
      ),
    ];
  }

  // Formatação
  static String _money(num v, {String curr = 'MT'}) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final frac = parts[1];
    final b = StringBuffer();
    int c = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      b.write(intPart[i]);
      c++;
      if (c == 3 && i != 0) {
        b.write('.');
        c = 0;
      }
    }
    return '$curr ${b.toString().split('').reversed.join()},$frac';
  }

  static String _dt(DateTime d, {bool withTime = false}) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    if (!withTime) return '$dd/$mm/$yyyy';
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$mi:$ss';
  }

  static String _mask(String s) {
    if (s.length <= 4) return s;
    final last = s.substring(s.length - 4);
    return '•••• $last';
  }

  static String _short(String s) => s.length <= 7 ? s : '${s.substring(0, 6)}...';

  (Color dot, Color fg, String label) _statusVisual(String status) {
    // Verde para aprovadas, vermelho para falhas, neutro cinza para restantes
    switch (status) {
      case 'approved':
        return (green, green, 'Aprovada');
      case 'failed':
        return (red, red, 'Falhada');
      case 'pending':
        return (Colors.grey, Colors.grey, 'Pendente');
      case 'processing':
        return (Colors.grey, Colors.grey, 'Processando');
      case 'refunded':
        return (Colors.grey, Colors.grey, 'Reembolsada');
      default:
        return (Colors.grey, Colors.grey, status);
    }
  }
}
