import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  // Change this one symbol to change the currency across the whole app.
  static const String symbol = '\৳';

  static final NumberFormat _numberFormat = NumberFormat('#,##0.00');

  /// Formats an amount, e.g. 1250.5 -> $1,250.50 (negative: -$50.00).
  static String format(double amount) {
    final sign = amount < 0 ? '-' : '';
    return '$sign$symbol${_numberFormat.format(amount.abs())}';
  }

  /// Formats an amount with a + (income) or - (expense) in front.
  static String formatSigned(double amount, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign$symbol${_numberFormat.format(amount.abs())}';
  }
}