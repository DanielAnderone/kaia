class Investment {
  final String id;
  final String investorName;
  final String projectName;
  final double value;
  final String status; // e.g. "Completed", "Active", "Pending", "Failed"
  final String transactionRef;
  final DateTime date;

  Investment({
    required this.id,
    required this.investorName,
    required this.projectName,
    required this.value,
    required this.status,
    required this.transactionRef,
    required this.date,
  });
}
