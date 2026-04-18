class DashboardSummary {
  final String businessId;
  final String monthKey;
  final double startingBalance;
  final double totalSales;
  final double totalExpenses;
  final double pendingReceivables;
  final double pendingPayables;
  final double currentCash;
  final double expectedCash;
  final double? runwayDays;

  const DashboardSummary({
    required this.businessId,
    required this.monthKey,
    required this.startingBalance,
    required this.totalSales,
    required this.totalExpenses,
    required this.pendingReceivables,
    required this.pendingPayables,
    required this.currentCash,
    required this.expectedCash,
    required this.runwayDays,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;

    return DashboardSummary(
      businessId: json['businessId'] as String,
      monthKey: json['monthKey'] as String,
      startingBalance: asDouble(json['startingBalance']),
      totalSales: asDouble(json['totalSales']),
      totalExpenses: asDouble(json['totalExpenses']),
      pendingReceivables: asDouble(json['pendingReceivables']),
      pendingPayables: asDouble(json['pendingPayables']),
      currentCash: asDouble(json['currentCash']),
      expectedCash: asDouble(json['expectedCash']),
      runwayDays: (json['runwayDays'] as num?)?.toDouble(),
    );
  }
}
