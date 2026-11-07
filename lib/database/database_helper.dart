import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_strings.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  // Singleton: the whole app shares ONE DatabaseHelper instance.
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 1;
  static const String tableTransactions = 'transactions';

  // We store the Future (not the finished Database). The first call starts
  // opening the database; any other call made at the same time reuses the
  // same Future. So the database is never opened or created twice.
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
      // onCreate runs only the FIRST time, when the file doesn't exist yet.
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

  /// Inserts a transaction and returns the new row's id.
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert(tableTransactions, transaction.toMap());
  }

  /// Returns transactions, newest first. Pass [limit] to get only the
  /// latest few (used for the dashboard's recent list).
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

  /// Updates the row with the same id. Returns how many rows changed.
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

  /// Deletes the row with this id. Returns how many rows were deleted.
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
    // SUM() returns NULL when there are no rows; COALESCE turns that into 0.
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM $tableTransactions WHERE type = ?',
      [type],
    );
    return (result.first['total'] as num).toDouble();
  }
}