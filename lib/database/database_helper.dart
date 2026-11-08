import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_strings.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 1;
  static const String tableTransactions = 'transactions';


  Future<Database>? _database;

  Future<Database> get database {
    _database ??= _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        category TEXT,
        type TEXT,
        date TEXT
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert(tableTransactions, transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions({int? limit}) async {
    final db = await database;
    final rows = await db.query(
      tableTransactions,
      // If two transactions share a date, the newer one (higher id) is first.
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map((row) => TransactionModel.fromMap(row)).toList();
  }

  /// Returns one transaction, or null if no row has this id.
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransactionModel.fromMap(rows.first);
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Cannot update a transaction without an id.');
    }
    final db = await database;
    return db.update(
      tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(
      tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() => _getTotalByType(AppStrings.typeIncome);

  Future<double> getTotalExpense() => _getTotalByType(AppStrings.typeExpense);

  Future<double> _getTotalByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM $tableTransactions WHERE type = ?',
      [type],
    );
    return (result.first['total'] as num).toDouble();
  }
}