import 'package:expense_tracker_o_20/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_expense_tracker/app.dart';

void main() {
  testWidgets('App starts and shows the Expense Tracker title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}