import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/transaction_form.dart';

class EditTransactionScreen extends StatefulWidget {
  /// The transaction to edit. Its values pre-fill the form.
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TransactionRepository _repository = TransactionRepository();

  /// Called by the form after all fields passed validation.
  /// The transaction passed in already contains the original id.
  Future<void> _updateTransaction(TransactionModel updated) async {
    // Grab these before the await (same safe pattern as before).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Returns how many rows were changed. 0 means the row no longer exists.
    final rowsChanged = await _repository.updateTransaction(updated);

    if (!mounted) return;

    if (rowsChanged == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('This transaction no longer exists.')),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Transaction updated')),
    );

    // Go back to the details screen. "true" means "something changed".
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.editTransaction),
      body: SafeArea(
        child: TransactionForm(
          initialTransaction: widget.transaction,
          submitLabel: AppStrings.update,
          onSubmit: _updateTransaction,
        ),
      ),
    );
  }
}