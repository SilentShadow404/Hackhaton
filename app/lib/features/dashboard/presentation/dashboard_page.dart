import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/brand_shell.dart';
import '../../auth/application/auth_controller.dart';
import '../application/dashboard_controller.dart';
import '../domain/forecast_point.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _showAddSaleDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) {
                return;
              }

              await ref
                  .read(dashboardActionProvider.notifier)
                  .addSale(amount: amount, description: descriptionController.text.trim());

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddExpenseDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final categoryController = TextEditingController(text: 'utilities');
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) {
                return;
              }

              await ref.read(dashboardActionProvider.notifier).addExpense(
                    amount: amount,
                    category: categoryController.text.trim().isEmpty ? 'other' : categoryController.text.trim(),
                    description: descriptionController.text.trim(),
                  );

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddReceivableDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Receivable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
              const SizedBox(height: 8),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone (+923...)')),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 8),
              TextField(controller: dueDateController, decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)')),
              const SizedBox(height: 8),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              final dueDate = DateTime.tryParse(dueDateController.text.trim());
              if (amount <= 0 || dueDate == null || nameController.text.trim().isEmpty) {
                return;
              }

              await ref.read(dashboardActionProvider.notifier).addReceivable(
                    customerName: nameController.text.trim(),
                    customerPhoneE164: phoneController.text.trim(),
                    amount: amount,
                    dueDate: dueDate,
                    description: descriptionController.text.trim(),
                  );

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPayableDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController(text: 'inventory');
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 5))),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Vendor Name')),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 8),
              TextField(controller: dueDateController, decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)')),
              const SizedBox(height: 8),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 8),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              final dueDate = DateTime.tryParse(dueDateController.text.trim());
              if (amount <= 0 || dueDate == null || nameController.text.trim().isEmpty) {
                return;
              }

              await ref.read(dashboardActionProvider.notifier).addPayable(
                    vendorName: nameController.text.trim(),
                    amount: amount,
                    dueDate: dueDate,
                    category: categoryController.text.trim().isEmpty ? 'other' : categoryController.text.trim(),
                    description: descriptionController.text.trim(),
                  );

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsappReminder(BuildContext context, WidgetRef ref, String receivableId) async {
    try {
      final link = await ref.read(dashboardActionProvider.notifier).getWhatsappLink(receivableId);
      final uri = Uri.parse(link);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Widget _buildForecastChart(List<ForecastPoint> points) {
    if (points.isEmpty) {
      return const Text('No forecast data');
    }

    final minY = points.map((e) => e.cash).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((e) => e.cash).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: points.length.toDouble() - 1,
          minY: minY - 5000,
          maxY: maxY + 5000,
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(points[index].date.substring(5), style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 46)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: 0, color: Colors.red.withValues(alpha: 0.4), strokeWidth: 1),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (final p in points) FlSpot(p.dayOffset.toDouble(), p.cash),
              ],
              isCurved: true,
              color: points.any((p) => p.isNegative) ? const Color(0xFFB33A3A) : const Color(0xFF1F7A4E),
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: points.any((p) => p.isNegative)
                    ? const Color(0xFFB33A3A).withValues(alpha: 0.15)
                    : const Color(0xFF1F7A4E).withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final forecastAsync = ref.watch(cashForecastProvider);
    final actionState = ref.watch(dashboardActionProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final receivablesAsync = ref.watch(receivablesProvider);
    final payablesAsync = ref.watch(payablesProvider);
    final amountFormat = NumberFormat('#,##0');

    return BrandShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('SME Cash Flow Dashboard'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Could not load summary: $error')),
          data: (summary) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Cash Position'),
                        const SizedBox(height: 6),
                        Text(
                          'INR ${amountFormat.format(summary.currentCash)}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text('Expected Cash: INR ${amountFormat.format(summary.expectedCash)}'),
                        const SizedBox(height: 6),
                        Text(
                          'Runway: ${summary.runwayDays == null ? 'N/A' : '${summary.runwayDays!.toStringAsFixed(0)} days'}',
                        ),
                        const SizedBox(height: 8),
                        Text('Logged in as ${user?.email ?? 'unknown'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: actionState.isLoading ? null : () => _showAddSaleDialog(context, ref),
                        icon: const Icon(Icons.add_card),
                        label: const Text('Add Sale'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: actionState.isLoading ? null : () => _showAddExpenseDialog(context, ref),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Add Expense'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: actionState.isLoading ? null : () => _showAddReceivableDialog(context, ref),
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text('Add Receivable'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: actionState.isLoading ? null : () => _showAddPayableDialog(context, ref),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Add Payable'),
                      ),
                    ),
                  ],
                ),
                if (actionState.hasError) ...[
                  const SizedBox(height: 10),
                  Text(actionState.error.toString(), style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                Text('Forecast (Red Zone Alert)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: forecastAsync.when(
                      loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                      error: (error, stackTrace) => Text('Could not load forecast: $error'),
                      data: _buildForecastChart,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pending Receivables', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: receivablesAsync.when(
                      loading: () => const LinearProgressIndicator(minHeight: 2),
                      error: (error, stackTrace) => Text('Could not load receivables: $error'),
                      data: (items) {
                        final pending = items.where((e) => e.status != 'paid').toList();
                        if (pending.isEmpty) {
                          return const Text('No pending receivables');
                        }

                        return Column(
                          children: pending.map((item) {
                            final due = item.dueDate == null ? 'No due date' : DateFormat('dd MMM').format(item.dueDate!);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.customerName),
                              subtitle: Text('Due: $due  |  ${item.status.toUpperCase()}'),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'WhatsApp Reminder',
                                    onPressed: () => _openWhatsappReminder(context, ref, item.id),
                                    icon: const Icon(Icons.message, color: Color(0xFF1F7A4E)),
                                  ),
                                  TextButton(
                                    onPressed: () => ref.read(dashboardActionProvider.notifier).markReceivablePaid(item.id),
                                    child: const Text('Mark Paid'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pending Payables', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: payablesAsync.when(
                      loading: () => const LinearProgressIndicator(minHeight: 2),
                      error: (error, stackTrace) => Text('Could not load payables: $error'),
                      data: (items) {
                        final pending = items.where((e) => e.status != 'paid').toList();
                        if (pending.isEmpty) {
                          return const Text('No pending payables');
                        }

                        return Column(
                          children: pending.map((item) {
                            final due = item.dueDate == null ? 'No due date' : DateFormat('dd MMM').format(item.dueDate!);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.vendorName),
                              subtitle: Text('Due: $due  |  ${item.status.toUpperCase()}'),
                              trailing: TextButton(
                                onPressed: () => ref.read(dashboardActionProvider.notifier).markPayablePaid(item.id),
                                child: const Text('Mark Paid'),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: recentAsync.when(
                      loading: () => const LinearProgressIndicator(minHeight: 2),
                      error: (error, stackTrace) => Text('Could not load recent transactions: $error'),
                      data: (items) {
                        if (items.isEmpty) {
                          return const Text('No transactions yet.');
                        }

                        return Column(
                          children: items.map((item) {
                            final isSale = item.type == 'sale';
                            final sign = isSale ? '+' : '-';
                            final color = isSale ? const Color(0xFF1F7A4E) : const Color(0xFFB33A3A);
                            final dateText = item.date == null ? 'No date' : DateFormat('dd MMM, hh:mm a').format(item.date!);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.12),
                                child: Icon(isSale ? Icons.trending_up : Icons.trending_down, color: color),
                              ),
                              title: Text(item.label),
                              subtitle: Text(dateText),
                              trailing: Text(
                                '$sign INR ${amountFormat.format(item.amount)}',
                                style: TextStyle(fontWeight: FontWeight.w700, color: color),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
