import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/investor_viewmodel.dart';

class InvestorsView extends StatelessWidget {
  const InvestorsView({super.key});

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
      body: Consumer<InvestorViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.error != null) return Center(child: Text('Error: ${vm.error}'));
          if (vm.investors.isEmpty) return const Center(child: Text('No investors found'));

          return RefreshIndicator(
            onRefresh: vm.loadInvestors,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.investors.length,
              itemBuilder: (context, index) {
                final investor = vm.investors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    // leading removido
                    title: Text(investor.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${investor.email}'),
                        Text('Projeto: ${investor.currentProject ?? "Não informado"}'),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kycColor(investor.kycStatus).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            investor.kycStatus,
                            style: TextStyle(
                              color: _kycColor(investor.kycStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
