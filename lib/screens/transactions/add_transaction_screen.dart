import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/transaction_form.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionRepository _repository = TransactionRepository();

  /// Called by the form after all fields passed validation.
  Future<void> _saveTransaction(TransactionModel transaction) async {
    // The messenger belongs to the whole app, so a SnackBar shown through it
    // stays visible after this screen closes (on the dashboard).
    final messenger = ScaffoldMessenger.of(context);

    await _repository.addTransaction(transaction);

    // The user could have left the screen while we were saving.
    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Transaction saved')),
    );

    // Go back. "true" means "something changed".
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.addTransaction),
      body: SafeArea(
        child: TransactionForm(
          submitLabel: AppStrings.save,
          onSubmit: _saveTransaction,
        ),
      ),
    );
  }
}