import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/brand_shell.dart';
import '../../auth/application/auth_controller.dart';
import '../application/dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<DateTime?> _pickDate(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    return picked;
  }

  Future<void> _showAddSaleDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Sale'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await _pickDate(context, selectedDate);
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;
                if (amount <= 0) {
                  return;
                }

                await ref
                    .read(dashboardActionProvider.notifier)
                    .addSale(
                      amount: amount,
                      date: selectedDate,
                      description: descriptionController.text.trim(),
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Sale'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddExpenseDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final amountController = TextEditingController();
    final categoryController = TextEditingController(text: 'utilities');
    final descriptionController = TextEditingController();
    var selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await _pickDate(context, selectedDate);
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;
                if (amount <= 0) {
                  return;
                }

                await ref
                    .read(dashboardActionProvider.notifier)
                    .addExpense(
                      amount: amount,
                      date: selectedDate,
                      category: categoryController.text.trim().isEmpty
                          ? 'other'
                          : categoryController.text.trim(),
                      description: descriptionController.text.trim(),
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReceivableDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController(
      text: DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().add(const Duration(days: 7))),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Receivable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone (+923...)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              final dueDate = DateTime.tryParse(dueDateController.text.trim());
              if (amount <= 0 ||
                  dueDate == null ||
                  nameController.text.trim().isEmpty) {
                return;
              }

              await ref
                  .read(dashboardActionProvider.notifier)
                  .addReceivable(
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

  Future<void> _showAddPayableDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController(text: 'inventory');
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController(
      text: DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().add(const Duration(days: 5))),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Vendor Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              final dueDate = DateTime.tryParse(dueDateController.text.trim());
              if (amount <= 0 ||
                  dueDate == null ||
                  nameController.text.trim().isEmpty) {
                return;
              }

              await ref
                  .read(dashboardActionProvider.notifier)
                  .addPayable(
                    vendorName: nameController.text.trim(),
                    amount: amount,
                    dueDate: dueDate,
                    category: categoryController.text.trim().isEmpty
                        ? 'other'
                        : categoryController.text.trim(),
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

  Future<void> _openWhatsappReminder(
    BuildContext context,
    WidgetRef ref,
    String receivableId,
  ) async {
    try {
      final link = await ref
          .read(dashboardActionProvider.notifier)
          .getWhatsappLink(receivableId);
      final uri = Uri.parse(link);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final actionState = ref.watch(dashboardActionProvider);
    final receivablesAsync = ref.watch(receivablesProvider);
    final payablesAsync = ref.watch(payablesProvider);
    final userEmail = user?.email;
    final amountFormat = NumberFormat.currency(
      symbol: 'INR ',
      decimalDigits: 0,
    );

    return BrandShell(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cashflow Dashboard'),
          actions: [
            if (userEmail != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Chip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(userEmail),
                  ),
                ),
              ),
            IconButton(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Could not load summary: $error')),
          data: (summary) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1024;

                Widget metricCard({
                  required String label,
                  required String value,
                  required Color accent,
                  required IconData icon,
                }) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withValues(alpha: 0.24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, color: accent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Widget actionButton({
                  required IconData icon,
                  required String label,
                  required VoidCallback onTap,
                }) {
                  return SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: actionState.isLoading ? null : onTap,
                      icon: Icon(icon),
                      label: Text(label),
                    ),
                  );
                }

                final receivablesCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: receivablesAsync.when(
                      loading: () =>
                          const LinearProgressIndicator(minHeight: 3),
                      error: (error, stackTrace) =>
                          Text('Could not load receivables: $error'),
                      data: (items) {
                        final pending = items
                            .where((e) => e.status != 'paid')
                            .toList();
                        if (pending.isEmpty) {
                          return const Text('No pending receivables.');
                        }

                        return Column(
                          children: pending.map((item) {
                            final due = item.dueDate == null
                                ? 'No due date'
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(item.dueDate!);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(item.customerName),
                                subtitle: Text(
                                  '${amountFormat.format(item.amount)}  |  Due $due',
                                ),
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      tooltip: 'WhatsApp Reminder',
                                      onPressed: () => _openWhatsappReminder(
                                        context,
                                        ref,
                                        item.id,
                                      ),
                                      icon: const Icon(
                                        Icons.message,
                                        color: Color(0xFF1F7A4E),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => ref
                                          .read(
                                            dashboardActionProvider.notifier,
                                          )
                                          .markReceivablePaid(item.id),
                                      child: const Text('Mark Paid'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                );

                final payablesCard = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: payablesAsync.when(
                      loading: () =>
                          const LinearProgressIndicator(minHeight: 3),
                      error: (error, stackTrace) =>
                          Text('Could not load payables: $error'),
                      data: (items) {
                        final pending = items
                            .where((e) => e.status != 'paid')
                            .toList();
                        if (pending.isEmpty) {
                          return const Text('No pending payables.');
                        }

                        return Column(
                          children: pending.map((item) {
                            final due = item.dueDate == null
                                ? 'No due date'
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(item.dueDate!);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(item.vendorName),
                                subtitle: Text(
                                  '${amountFormat.format(item.amount)}  |  Due $due',
                                ),
                                trailing: TextButton(
                                  onPressed: () => ref
                                      .read(dashboardActionProvider.notifier)
                                      .markPayablePaid(item.id),
                                  child: const Text('Mark Paid'),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: const Color(0xFF0E4A4A),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Simple Cash Summary',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              amountFormat.format(summary.currentCash),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Current Cash = (Starting Balance + Sales) - Expenses',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  label: Text(
                                    'Expected Cash: ${amountFormat.format(summary.expectedCash)}',
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    'Runway: ${summary.runwayDays == null ? 'N/A' : '${summary.runwayDays!.toStringAsFixed(0)} days'}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: metricCard(
                            label: 'Total Sales (This Month)',
                            value: amountFormat.format(summary.totalSales),
                            accent: const Color(0xFF1F7A4E),
                            icon: Icons.trending_up,
                          ),
                        ),
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: metricCard(
                            label: 'Total Expenses (This Month)',
                            value: amountFormat.format(summary.totalExpenses),
                            accent: const Color(0xFFB42318),
                            icon: Icons.trending_down,
                          ),
                        ),
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: metricCard(
                            label: 'Pending Receivables',
                            value: amountFormat.format(
                              summary.pendingReceivables,
                            ),
                            accent: const Color(0xFF1F7A4E),
                            icon: Icons.account_balance_wallet,
                          ),
                        ),
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: metricCard(
                            label: 'Pending Payables',
                            value: amountFormat.format(summary.pendingPayables),
                            accent: const Color(0xFFB42318),
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: actionButton(
                            icon: Icons.add_card,
                            label: 'Add Sale',
                            onTap: () => _showAddSaleDialog(context, ref),
                          ),
                        ),
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: actionButton(
                            icon: Icons.receipt_long,
                            label: 'Add Expense',
                            onTap: () => _showAddExpenseDialog(context, ref),
                          ),
                        ),
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: actionButton(
                            icon: Icons.account_balance_wallet,
                            label: 'Add Receivable',
                            onTap: () => _showAddReceivableDialog(context, ref),
                          ),
                        ),
                        SizedBox(
                          width: wide
                              ? (constraints.maxWidth - 42) / 2
                              : constraints.maxWidth,
                          child: actionButton(
                            icon: Icons.payments_outlined,
                            label: 'Add Payable',
                            onTap: () => _showAddPayableDialog(context, ref),
                          ),
                        ),
                      ],
                    ),
                    if (actionState.hasError) ...[
                      const SizedBox(height: 10),
                      Text(
                        actionState.error.toString(),
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'Pending Receivables',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    receivablesCard,
                    const SizedBox(height: 18),
                    Text(
                      'Pending Payables',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    payablesCard,
                    const SizedBox(height: 10),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
