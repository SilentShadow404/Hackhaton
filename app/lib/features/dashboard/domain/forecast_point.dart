class ForecastPoint {
  final int dayOffset;
  final String date;
  final double inflow;
  final double outflow;
  final double cash;
  final bool isNegative;

  const ForecastPoint({
    required this.dayOffset,
    required this.date,
    required this.inflow,
    required this.outflow,
    required this.cash,
    required this.isNegative,
  });
}
