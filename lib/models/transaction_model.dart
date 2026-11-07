import '../constants/app_strings.dart';

class TransactionModel {
  // id is nullable: a new transaction has no id until SQLite creates one.
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type; // 'income' or 'expense'
  final DateTime date;

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  bool get isIncome => type == AppStrings.typeIncome;

  bool get isExpense => type == AppStrings.typeExpense;

  /// Converts a database row into a TransactionModel.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      // SQLite may return a whole number as int, so we convert safely.
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: map['type'] as String,
      // Dates are stored as ISO-8601 text, e.g. 2026-11-07T00:00:00.000
      date: DateTime.parse(map['date'] as String),
    );
  }

  /// Converts this object into a map that SQLite can store.
  Map<String, dynamic> toMap() {
    return {
      // Leave id out for new rows so AUTOINCREMENT can generate it.
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  /// Returns a copy with some fields changed (useful when editing).
  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}