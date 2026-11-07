import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final TransactionRepository _repository = TransactionRepository();

  bool _isLoading = true;
  TransactionModel? _transaction; // null if not found

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final transaction =
          await _repository.getTransactionById(widget.transactionId);

      if (!mounted) return;

      setState(() {
        _transaction = transaction;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load this transaction.')),
      );
    }
  }

  /// Opens the Edit screen, waits for it to close, then reloads
  /// so the details show the newly saved values.
  Future<void> _editTransaction() async {
    final transaction = _transaction;
    if (transaction == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );

    if (!mounted) return;
    _loadTransaction();
  }

  /// Asks for confirmation, then deletes. Cancel does nothing.
  Future<void> _deleteTransaction() async {
    final transaction = _transaction;
    if (transaction == null) return;

    final confirmed = await DeleteConfirmationDialog.show(context);

    // Stop if the user tapped Cancel (or left the screen meanwhile).
    if (!confirmed || !mounted) return;

    // Grab these before the next await (see Phase 5 notes).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await _repository.deleteTransaction(transaction.id!);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the transaction.')),
      );
      return;
    }

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Transaction deleted')),
    );
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.transactionDetails),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final transaction = _transaction;
    if (transaction == null) {
      return const EmptyState(
        title: 'Transaction not found',
        message: 'It may have been deleted.',
        icon: Icons.search_off,
      );
    }

    final bool isIncome = transaction.isIncome;
    final Color color = isIncome ? AppColors.income : AppColors.expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ----- Amount header -----
          Card(
            elevation: 2,
            color: color.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.formatSigned(
                        transaction.amount,
                        isIncome: isIncome,
                      ),
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ----- All details -----
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.title,
                    label: AppStrings.title,
                    value: transaction.title,
                  ),
                  const Divider(height: 1),
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: AppStrings.amount,
                    value: CurrencyFormatter.format(transaction.amount),
                  ),
                  const Divider(height: 1),
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: AppStrings.category,
                    value: transaction.category,
                  ),
                  const Divider(height: 1),
                  _DetailRow(
                    icon: Icons.swap_vert,
                    label: AppStrings.type,
                    value: isIncome ? AppStrings.income : AppStrings.expense,
                    valueColor: color,
                  ),
                  const Divider(height: 1),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: AppStrings.date,
                    value: DateFormatter.format(transaction.date),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ----- Actions -----
          FilledButton.icon(
            onPressed: _editTransaction,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.edit_outlined),
            label: const Text(AppStrings.edit),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _deleteTransaction,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: AppColors.expense,
              side: const BorderSide(color: AppColors.expense),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

/// One "icon | label | value" line inside the details card.
/// Private (starts with _) because only this file uses it.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          // Expanded + right alignment lets long titles wrap safely.
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}