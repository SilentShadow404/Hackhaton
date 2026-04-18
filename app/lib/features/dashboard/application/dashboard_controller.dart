import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';
import '../domain/forecast_point.dart';
import '../domain/payable_item.dart';
import '../domain/receivable_item.dart';
import '../domain/transaction_item.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final businessIdProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.bootstrapBusiness();
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final businessId = await ref.watch(businessIdProvider.future);
  return repo.getDashboardSummary(businessId);
});

final cashForecastProvider = FutureProvider<List<ForecastPoint>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final businessId = await ref.watch(businessIdProvider.future);
  return repo.getCashForecast(businessId, days: 7);
});

final recentTransactionsProvider = FutureProvider<List<TransactionItem>>((
  ref,
) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final businessId = await ref.watch(businessIdProvider.future);
  return repo.getRecentTransactions(businessId);
});

final receivablesProvider = FutureProvider<List<ReceivableItem>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final businessId = await ref.watch(businessIdProvider.future);
  return repo.listReceivables(businessId);
});

final payablesProvider = FutureProvider<List<PayableItem>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  final businessId = await ref.watch(businessIdProvider.future);
  return repo.listPayables(businessId);
});

final dashboardActionProvider =
    StateNotifierProvider<DashboardActionController, AsyncValue<void>>(
      (ref) => DashboardActionController(ref),
    );

class DashboardActionController extends StateNotifier<AsyncValue<void>> {
  DashboardActionController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  void _refreshAll() {
    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(cashForecastProvider);
    _ref.invalidate(recentTransactionsProvider);
    _ref.invalidate(receivablesProvider);
    _ref.invalidate(payablesProvider);
  }

  Future<void> addSale({
    required double amount,
    required DateTime date,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(dashboardRepositoryProvider);
      final businessId = await _ref.read(businessIdProvider.future);
      await repo.addSale(
        businessId: businessId,
        amount: amount,
        date: date,
        description: description,
      );
      _refreshAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addExpense({
    required double amount,
    required DateTime date,
    required String category,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(dashboardRepositoryProvider);
      final businessId = await _ref.read(businessIdProvider.future);
      await repo.addExpense(
        businessId: businessId,
        amount: amount,
        date: date,
        category: category,
        description: description,
      );
      _refreshAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addReceivable({
    required String customerName,
    required String customerPhoneE164,
    required double amount,
    required DateTime dueDate,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(dashboardRepositoryProvider);
      final businessId = await _ref.read(businessIdProvider.future);
      await repo.addReceivable(
        businessId: businessId,
        customerName: customerName,
        customerPhoneE164: customerPhoneE164,
        amount: amount,
        dueDate: dueDate,
        description: description,
      );
      _refreshAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addPayable({
    required String vendorName,
    required double amount,
    required DateTime dueDate,
    required String category,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(dashboardRepositoryProvider);
      final businessId = await _ref.read(businessIdProvider.future);
      await repo.addPayable(
        businessId: businessId,
        vendorName: vendorName,
        amount: amount,
        dueDate: dueDate,
        category: category,
        description: description,
      );
      _refreshAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markReceivablePaid(String receivableId) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(dashboardRepositoryProvider);
      final businessId = await _ref.read(businessIdProvider.future);
      await repo.markReceivablePaid(
        businessId: businessId,
        receivableId: receivableId,
      );
      _refreshAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markPayablePaid(String payableId) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(dashboardRepositoryProvider);
      final businessId = await _ref.read(businessIdProvider.future);
      await repo.markPayablePaid(businessId: businessId, payableId: payableId);
      _refreshAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<String> getWhatsappLink(String receivableId) async {
    final repo = _ref.read(dashboardRepositoryProvider);
    final businessId = await _ref.read(businessIdProvider.future);
    return repo.getReceivableWhatsappLink(
      businessId: businessId,
      receivableId: receivableId,
    );
  }
}
