class ReceivableItem {
  final String id;
  final String customerName;
  final String customerPhoneE164;
  final double amount;
  final DateTime? dueDate;
  final String description;
  final String status;

  const ReceivableItem({
    required this.id,
    required this.customerName,
    required this.customerPhoneE164,
    required this.amount,
    required this.dueDate,
    required this.description,
    required this.status,
  });
}
