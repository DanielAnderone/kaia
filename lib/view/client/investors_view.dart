import 'package:flutter/material.dart';
// import '../../viewmodel/investor_viewmodel.dart';
import '../../model/investor.dart';
import '../../service/investor_service.dart';
class InvestorsView extends StatefulWidget {
  const InvestorsView({super.key});

  @override
  State<InvestorsView> createState() => _InvestorsViewState();
}

class _InvestorsViewState extends State<InvestorsView> {
  final _svc = InvestorService();
  List<Investor> _investors = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvestors();
  }

  Future<void> _loadInvestors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _investors = await _svc.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _kycColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green.shade700;
      case 'Pending':
        return Colors.orange.shade700;
      case 'Rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investors')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : _investors.isEmpty
                  ? const Center(child: Text('Nenhum investidor encontrado'))
                  : RefreshIndicator(
                      onRefresh: _loadInvestors,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _investors.length,
                        itemBuilder: (context, index) {
                          final investor = _investors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(investor.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${investor.name}'),
                                  Text('Projeto: ${investor.identityCard ?? "Não informado"}'),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      // color: _kycColor(investor.status).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // child: Text(
                                      // // investor.status,
                                      // style: TextStyle(
                                      //   color: _kycColor(investor.status),
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    // ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
