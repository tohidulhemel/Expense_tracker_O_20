import 'package:expense_tracker_o_20/screens/transactions/transaction_details_screen.dart';
import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_item.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionRepository _repository = TransactionRepository();

  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  /// Loads all transactions. The database already returns them
  /// sorted by date, newest first.
  Future<void> _loadTransactions() async {
    try {
      final transactions = await _repository.getAllTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
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

  /// Opens the details screen, waits for the user to come back,
  /// then reloads the list (the transaction may have been edited or deleted).
  Future<void> _openDetails(TransactionModel transaction) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(
          transactionId: transaction.id!,
        ),
      ),
    );
    if (!mounted) return;
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.allTransactions),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return const EmptyState(
        title: AppStrings.noTransactions,
        message: AppStrings.noTransactionsHint,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      // ListView.builder only builds the rows that are on screen,
      // so it stays fast even with thousands of transactions.
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionItem(
            transaction: transaction,
            onTap: () => _openDetails(transaction),
          );
        },
      ),
    );
  }
}