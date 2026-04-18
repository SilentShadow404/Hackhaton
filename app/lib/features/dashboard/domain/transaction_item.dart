class TransactionItem {
  final String id;
  final String type;
  final double amount;
  final DateTime? date;
  final String label;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.label,
  });
}
