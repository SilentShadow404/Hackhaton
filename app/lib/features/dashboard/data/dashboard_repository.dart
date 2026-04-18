import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../domain/dashboard_summary.dart';
import '../domain/forecast_point.dart';
import '../domain/payable_item.dart';
import '../domain/receivable_item.dart';
import '../domain/transaction_item.dart';

class DashboardRepository {
  final FirebaseAuth _auth;
  final http.Client _httpClient;

  DashboardRepository({FirebaseAuth? auth, http.Client? httpClient})
    : _auth = auth ?? FirebaseAuth.instance,
      _httpClient = httpClient ?? http.Client();

  Future<String> _requireToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not signed in.');
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Could not fetch auth token.');
    }

    return token;
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final token = await _requireToken();
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _postJson(String url, Map<String, dynamic> body) async {
    final token = await _requireToken();
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: ${response.body}');
    }
  }

  Future<String> _getWhatsappLink(String url) async {
    final token = await _requireToken();
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not generate WhatsApp link: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['waLink'] as String;
  }

  Future<String> bootstrapBusiness() async {
    final token = await _requireToken();
    final response = await _httpClient.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/v1/businesses/bootstrap'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to bootstrap business: ${response.body}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return jsonBody['businessId'] as String;
  }

  Future<DashboardSummary> getDashboardSummary(String businessId) async {
    final json = await _getJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/dashboard/summary',
    );
    return DashboardSummary.fromJson(json);
  }

  Future<List<ForecastPoint>> getCashForecast(
    String businessId, {
    int days = 7,
  }) async {
    final json = await _getJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/dashboard/forecast?days=$days',
    );

    final points = (json['points'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (p) => ForecastPoint(
            dayOffset: p['dayOffset'] as int,
            date: p['date'] as String,
            inflow: (p['inflow'] as num?)?.toDouble() ?? 0,
            outflow: (p['outflow'] as num?)?.toDouble() ?? 0,
            cash: (p['cash'] as num?)?.toDouble() ?? 0,
            isNegative: p['isNegative'] as bool? ?? false,
          ),
        )
        .toList();

    return points;
  }

  Future<void> addSale({
    required String businessId,
    required double amount,
    required String description,
  }) async {
    await _postJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/sales',
      {
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'description': description,
      },
    );
  }

  Future<void> addExpense({
    required String businessId,
    required double amount,
    required String category,
    required String description,
  }) async {
    await _postJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/expenses',
      {
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'category': category,
        'description': description,
      },
    );
  }

  Future<void> addReceivable({
    required String businessId,
    required String customerName,
    required String customerPhoneE164,
    required double amount,
    required DateTime dueDate,
    required String description,
  }) async {
    await _postJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/receivables',
      {
        'customerName': customerName,
        'customerPhoneE164': customerPhoneE164,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'description': description,
      },
    );
  }

  Future<void> addPayable({
    required String businessId,
    required String vendorName,
    required double amount,
    required DateTime dueDate,
    required String category,
    required String description,
  }) async {
    await _postJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/payables',
      {
        'vendorName': vendorName,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'category': category,
        'description': description,
      },
    );
  }

  Future<void> markReceivablePaid({
    required String businessId,
    required String receivableId,
  }) async {
    await _postJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/receivables/$receivableId/mark-paid',
      {},
    );
  }

  Future<void> markPayablePaid({
    required String businessId,
    required String payableId,
  }) async {
    await _postJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/payables/$payableId/mark-paid',
      {},
    );
  }

  Future<String> getReceivableWhatsappLink({
    required String businessId,
    required String receivableId,
  }) async {
    return _getWhatsappLink(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/receivables/$receivableId/whatsapp-link',
    );
  }

  Future<List<ReceivableItem>> listReceivables(String businessId) async {
    final json = await _getJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/receivables',
    );

    return (json['items'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (r) => ReceivableItem(
            id: r['id'] as String,
            customerName: r['customerName'] as String? ?? '',
            customerPhoneE164: r['customerPhoneE164'] as String? ?? '',
            amount: (r['amount'] as num?)?.toDouble() ?? 0,
            dueDate: r['dueDate'] != null
                ? DateTime.tryParse(r['dueDate'] as String)
                : null,
            description: r['description'] as String? ?? '',
            status: r['status'] as String? ?? 'pending',
          ),
        )
        .toList();
  }

  Future<List<PayableItem>> listPayables(String businessId) async {
    final json = await _getJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/payables',
    );

    return (json['items'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (p) => PayableItem(
            id: p['id'] as String,
            vendorName: p['vendorName'] as String? ?? '',
            amount: (p['amount'] as num?)?.toDouble() ?? 0,
            dueDate: p['dueDate'] != null
                ? DateTime.tryParse(p['dueDate'] as String)
                : null,
            category: p['category'] as String? ?? 'other',
            description: p['description'] as String? ?? '',
            status: p['status'] as String? ?? 'pending',
          ),
        )
        .toList();
  }

  Future<List<TransactionItem>> getRecentTransactions(String businessId) async {
    final salesJson = await _getJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/sales',
    );
    final expensesJson = await _getJson(
      '${AppConfig.apiBaseUrl}/api/v1/businesses/$businessId/expenses',
    );

    final salesItems = (salesJson['items'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (sale) => TransactionItem(
            id: sale['id'] as String,
            type: 'sale',
            amount: (sale['amount'] as num?)?.toDouble() ?? 0,
            date: sale['date'] != null
                ? DateTime.tryParse(sale['date'] as String)
                : null,
            label: sale['description'] as String? ?? 'Sale',
          ),
        )
        .toList();

    final expenseItems = (expensesJson['items'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map(
          (expense) => TransactionItem(
            id: expense['id'] as String,
            type: 'expense',
            amount: (expense['amount'] as num?)?.toDouble() ?? 0,
            date: expense['date'] != null
                ? DateTime.tryParse(expense['date'] as String)
                : null,
            label:
                '${expense['category'] ?? 'other'} - ${expense['description'] ?? 'Expense'}',
          ),
        )
        .toList();

    final merged = [...salesItems, ...expenseItems];
    merged.sort(
      (a, b) => (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)),
    );
    return merged.take(10).toList();
  }
}
