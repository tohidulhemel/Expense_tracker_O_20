import 'package:expense_tracker_o_20/screens/transactions/transaction_details_screen.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_item.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionRepository _repository = TransactionRepository();

  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;
  List<TransactionModel> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Reads everything the dashboard needs from SQLite.
  Future<void> _loadData() async {
    try {
      final income = await _repository.getTotalIncome();
      final expense = await _repository.getTotalExpense();
      final recent = await _repository.getRecentTransactions(limit: 5);

      // The user may have left this screen while we were waiting.
      if (!mounted) return;

      setState(() {
        _totalIncome = income;
        _totalExpense = expense;
        // Current Balance = Total Income - Total Expense
        _balance = income - expense;
        _recentTransactions = recent;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your transactions.')),
      );
    }
  }

  // Each method below opens a screen, WAITS until the user comes back,
  // and then reloads the data so the dashboard is always up to date.

  Future<void> _openAddTransaction() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (!mounted) return;
    _loadData();
  }

  Future<void> _openTransactionList() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TransactionListScreen()),
    );
    if (!mounted) return;
    _loadData();
  }

  Future<void> _openDetails(TransactionModel transaction) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(
          transactionId: transaction.id!,
        ),
      ),
    );
    if (!mounted) return;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.appName),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        tooltip: AppStrings.addTransaction,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Pull down to reload manually.
              onRefresh: _loadData,
              child: ListView(
                // Lets pull-to-refresh work even when the list is short.
                physics: const AlwaysScrollableScrollPhysics(),
                // Extra bottom padding so the FAB never covers the last item.
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                children: [
                  // ----- Current Balance (full width, highlighted) -----
                  SummaryCard(
                    title: AppStrings.currentBalance,
                    amount: CurrencyFormatter.format(_balance),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.balance,
                    isHighlighted: true,
                  ),
                  const SizedBox(height: 12),

                  // ----- Income and Expense side by side -----
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: AppStrings.totalIncome,
                          amount: CurrencyFormatter.format(_totalIncome),
                          icon: Icons.arrow_downward,
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: AppStrings.totalExpense,
                          amount: CurrencyFormatter.format(_totalExpense),
                          icon: Icons.arrow_upward,
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ----- Section header with "View All" -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.recentTransactions,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _openTransactionList,
                        child: const Text(AppStrings.viewAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ----- Recent transactions or empty state -----
                  if (_recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyState(
                        title: AppStrings.noTransactions,
                        message: AppStrings.noTransactionsHint,
                      ),
                    )
                  else
                    // The "..." (spread) inserts every item into the list.
                    ..._recentTransactions.map(
                      (transaction) => TransactionItem(
                        transaction: transaction,
                        onTap: () => _openDetails(transaction),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}