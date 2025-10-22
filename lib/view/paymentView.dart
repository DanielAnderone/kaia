import 'package:flutter/material.dart';
import '../service/payment_service.dart';
import '../model/project.dart';
import '../model/investor.dart';

class PaymentView extends StatefulWidget {
  final String apiBaseUrl;
  final String? phone; // opcional, será sobrescrito se vier via arguments
  const PaymentView({
    super.key,
    this.apiBaseUrl = 'https://kaia.loophole.site',
    this.phone,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  static const Color primary = Color(0xFF169C1D);
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();
  bool _loading = false;

  // contexto vindo da navegação
  int? _payerFromId; // investor.id
  int? _payerToId;   // project.ownerId
  String? _phone;    // investor.phone

  late final PaymentService _service;

  @override
  void initState() {
    super.initState();
    _service = PaymentService(baseUrl: widget.apiBaseUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // lê argumentos: {'investor': Investor, 'project': Project}
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final inv = args['investor'];
      final proj = args['project'];
      if (inv is Investor) {
        _payerFromId = inv.id ?? inv.userId; // usa id se existir, senão userId
        _phone = inv.phone;
      }
      if (proj is Project) {
        _payerToId = proj.ownerId;
      }
    }
    _phone ??= widget.phone;
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF112112) : const Color(0xFFF6F8F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pagamentos',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _infoBox(isDark),
          const SizedBox(height: 12),
          _form(isDark),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _onPagar,
              icon: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.lock),
              label: const Text('Confirmar pagamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _kv('Telefone do investidor', _phone ?? '—'),
          _kv('De (payer_from_id)', _payerFromId?.toString() ?? '—'),
          _kv('Para (payer_to_id)', _payerToId?.toString() ?? '—'),
          _kv('Moeda', 'MT'),
          _kv('Processador', 'Backend KAIA'),
        ],
      ),
    );
  }

  Widget _form(bool isDark) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            TextFormField(
              initialValue: _phone ?? '',
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _valorCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor (MT)',
                prefixIcon: Icon(Icons.payments),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                final x = double.tryParse(v.replaceAll(',', '.'));
                if (x == null || x <= 0) return 'Valor inválido';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPagar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_payerFromId == null || _payerToId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IDs de pagamento ausentes')),
      );
      return;
    }

    final valor = double.parse(_valorCtrl.text.replaceAll(',', '.'));

    setState(() => _loading = true);
    try {
      // regra simples: envia total_amount igual ao valor informado
      final req = PaymentRequest(
        payerFromId: _payerFromId!,
        payerToId: _payerToId!,
        paidAmount: valor,
        totalAmount: valor,
      );

      final resp = await _service.createPayment(req);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pagamento criado: ${resp['id'] ?? 'ok'}')),
      );
      _showRecibo(
        _ReciboMock(
          id: '${resp['id'] ?? DateTime.now().millisecondsSinceEpoch}',
          phone: _phone ?? '',
          valor: valor,
          taxa: '0.00',
          total: valor.toStringAsFixed(2),
          criadoEm: DateTime.now(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao processar pagamento: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showRecibo(_ReciboMock r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Recibo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                _kv('ID', r.id),
                _kv('Telefone', r.phone.isEmpty ? '—' : r.phone),
                _kv('Valor', _mt(r.valor)),
                _kv('Taxa', _mt(double.parse(r.taxa))),
                const Divider(),
                _kv('Total', _mt(double.parse(r.total))),
                const Divider(),
                _kv('Criado em', _dt(r.criadoEm, withTime: true)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _pillBtn(icon: Icons.copy, text: 'Copiar ID', onTap: () {})),
                    const SizedBox(width: 10),
                    Expanded(child: _solidBtn(icon: Icons.share, text: 'Partilhar', onTap: () {})),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== helpers UI =====
  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            Flexible(child: Text(v, textAlign: TextAlign.end)),
          ],
        ),
      );

  static Widget _pillBtn({required IconData icon, required String text, required VoidCallback onTap}) => SizedBox(
        height: 44,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: primary),
          label: Text(text, style: const TextStyle(color: primary, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );

  static Widget _solidBtn({required IconData icon, required String text, required VoidCallback onTap}) => SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.share, color: Colors.white),
          label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );

  static String _mt(num v) {
    final s = v.toStringAsFixed(2);
    final p = s.split('.');
    final intPart = p[0];
    final frac = p[1];
    final b = StringBuffer();
    var c = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      b.write(intPart[i]);
      c++;
      if (c == 3 && i != 0) {
        b.write('.');
        c = 0;
      }
    }
    return 'MT ${b.toString().split('').reversed.join()},$frac';
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
}

// Mock de recibo para exibir comprovativo
class _ReciboMock {
  final String id;
  final String phone;
  final double valor;
  final String taxa;
  final String total;
  final DateTime criadoEm;
  _ReciboMock({
    required this.id,
    required this.phone,
    required this.valor,
    required this.taxa,
    required this.total,
    required this.criadoEm,
  });
}
