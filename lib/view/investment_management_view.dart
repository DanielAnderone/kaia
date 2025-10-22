import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/investment_viewmodel.dart';
import '../model/investment.dart';
import 'package:intl/intl.dart';

class InvestmentManagementView extends StatelessWidget {
  const InvestmentManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InvestmentViewModel()..loadInvestments(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            'Gestão de Investimentos',
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: _InvestmentBody(),
        ),
      ),
    );
  }
}

class _InvestmentBody extends StatefulWidget {
  const _InvestmentBody();

  @override
  State<_InvestmentBody> createState() => _InvestmentBodyState();
}

class _InvestmentBodyState extends State<_InvestmentBody> {
  final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Consumer<InvestmentViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar para Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A64F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.investments.isEmpty
                  ? Center(
                  child: Text('Nenhum investimento encontrado.',
                      style: GoogleFonts.inter()))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: const [
                        _ColumnHeader(title: 'Investidor', width: 150),
                        _ColumnHeader(title: 'Projeto', width: 200),
                        _ColumnHeader(title: 'Valor', width: 100),
                        _ColumnHeader(title: 'Status', width: 100),
                        _ColumnHeader(
                            title: 'Ref. Transação', width: 150),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Lista de investimentos
                    SizedBox(
                      width: 800,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: vm.investments.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final inv = vm.investments[index];
                          return Row(
                            children: [
                              _ColumnCell(
                                  text: inv.investorName, width: 150),
                              _ColumnCell(
                                  text: inv.projectName, width: 200),
                              _ColumnCell(
                                  text: _formatCurrency(inv.value),
                                  width: 100),
                              _ColumnCell(
                                  child: _statusChip(inv.status),
                                  width: 100),
                              _ColumnCell(
                                  text: inv.transactionRef,
                                  width: 150,
                                  isMonospace: true),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(double v) {
    final f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return f.format(v);
  }

  Widget _statusChip(String status) {
    final color = status == 'Completed'
        ? Colors.green.shade600
        : status == 'Active'
        ? Colors.blue.shade600
        : status == 'Pending'
        ? Colors.orange.shade600
        : Colors.red.shade600;
    final label = _translateStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  String _translateStatus(String s) {
    switch (s) {
      case 'Completed':
        return 'Concluído';
      case 'Active':
        return 'Ativo';
      case 'Pending':
        return 'Pendente';
      case 'Failed':
        return 'Falhou';
      default:
        return s;
    }
  }
}

// ==========================
// Widgets de Coluna
// ==========================
class _ColumnHeader extends StatelessWidget {
  final String title;
  final double width;

  const _ColumnHeader({required this.title, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey)),
        color: Color(0xFFEFEFEF),
      ),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

class _ColumnCell extends StatelessWidget {
  final String? text;
  final Widget? child;
  final double width;
  final bool isMonospace;

  const _ColumnCell(
      {this.text, this.child, required this.width, this.isMonospace = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey)),
      ),
      child: child ??
          Text(
            text ?? '',
            style: TextStyle(
                fontFamily: isMonospace ? 'monospace' : null, fontSize: 13),
          ),
    );
  }
}
