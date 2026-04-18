class PayableItem {
  final String id;
  final String vendorName;
  final double amount;
  final DateTime? dueDate;
  final String category;
  final String description;
  final String status;

  const PayableItem({
    required this.id,
    required this.vendorName,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.description,
    required this.status,
  });
}
