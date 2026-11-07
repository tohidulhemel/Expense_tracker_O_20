import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Needed when we run async code (like opening the database)
  // before runApp() is called.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}