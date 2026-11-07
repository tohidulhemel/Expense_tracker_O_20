class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'Expense Tracker';

  // Dashboard
  static const String totalIncome = 'Total Income';
  static const String totalExpense = 'Total Expense';
  static const String currentBalance = 'Current Balance';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';

  // Screens
  static const String addTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String transactionDetails = 'Transaction Details';
  static const String allTransactions = 'All Transactions';

  // Form
  static const String title = 'Title';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String type = 'Type';
  static const String date = 'Date';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String save = 'Save';
  static const String update = 'Update';

  // Actions
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';

  // Messages
  static const String noTransactions = 'No transactions yet';
  static const String noTransactionsHint =
      'Tap the + button to add your first transaction.';
  static const String deleteTitle = 'Delete Transaction';
  static const String deleteMessage =
      'Are you sure you want to delete this transaction? This cannot be undone.';

  // Database values (stored in the "type" column)
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';
}