import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> addTransaction(TransactionModel transaction) {
    return _db.insertTransaction(transaction);
  }

  Future<List<TransactionModel>> getAllTransactions() {
    return _db.getAllTransactions();
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) {
    return _db.getAllTransactions(limit: limit);
  }

  Future<TransactionModel?> getTransactionById(int id) {
    return _db.getTransactionById(id);
  }

  Future<int> updateTransaction(TransactionModel transaction) {
    return _db.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) {
    return _db.deleteTransaction(id);
  }

  Future<double> getTotalIncome() {
    return _db.getTotalIncome();
  }

  Future<double> getTotalExpense() {
    return _db.getTotalExpense();
  }

  /// Current Balance = Total Income - Total Expense
  Future<double> getBalance() async {
    final income = await _db.getTotalIncome();
    final expense = await _db.getTotalExpense();
    return income - expense;
  }
}