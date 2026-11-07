import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_categories.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/transaction_model.dart';
import '../utils/date_formatter.dart';

class TransactionForm extends StatefulWidget {
  /// null when adding; the existing transaction when editing.
  final TransactionModel? initialTransaction;

  /// Text on the button: "Save" or "Update".
  final String submitLabel;

  /// Called with the validated transaction. The screen saves it.
  final Future<void> Function(TransactionModel transaction) onSubmit;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _type;
  String? _category;
  late DateTime _date;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.initialTransaction;

    // When editing, fill every field with the saved values.
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(2),
    );
    _type = existing?.type ?? AppStrings.typeExpense;
    _category = existing?.category;

    // Default date is today (time of day removed).
    final now = DateTime.now();
    _date = existing?.date ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    // Controllers must be disposed to free memory.
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Categories depend on the selected type.
  List<String> get _categories => _type == AppStrings.typeIncome
      ? AppCategories.incomeCategories
      : AppCategories.expenseCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    // validate() runs every field's validator and shows error messages.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final transaction = TransactionModel(
      id: widget.initialTransaction?.id, // keep the id when editing
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category!,
      type: _type,
      date: _date,
    );

    try {
      await widget.onSubmit(transaction);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
      }
    } finally {
      // The screen may already have closed after a successful save.
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety: only preselect a category that exists in the current list.
    final String? selectedCategory =
        _categories.contains(_category) ? _category : null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----- Transaction type -----
            const Text(
              AppStrings.type,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: AppStrings.typeIncome,
                  label: Text(AppStrings.income),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment<String>(
                  value: AppStrings.typeExpense,
                  label: Text(AppStrings.expense),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  // The old category may not exist for the new type.
                  if (!_categories.contains(_category)) {
                    _category = null;
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            // ----- Title -----
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: AppStrings.title,
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ----- Amount -----
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              // Allows digits and one dot, with up to 2 decimal places.
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: AppStrings.amount,
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Please enter an amount';
                final amount = double.tryParse(text);
                if (amount == null) return 'Please enter a valid number';
                if (amount <= 0) return 'Amount must be greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ----- Category -----
            // The key changes with the type, which rebuilds the dropdown so
            // it shows the correct list and clears the old selection.
            DropdownButtonFormField<String>(
              key: ValueKey(_type),
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: AppStrings.category,
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // ----- Date -----
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: AppStrings.date,
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(DateFormatter.format(_date)),
              ),
            ),
            const SizedBox(height: 28),

            // ----- Save / Update button -----
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}