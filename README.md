# Personal Expense Tracker

A Flutter (Android) app for managing daily income and expenses.
All data is stored locally on the device using SQLite (sqflite).

## Features

- Dashboard with Total Income, Total Expense and Current Balance
- Recent transactions list (newest first)
- Add, edit and delete transactions
- Transaction details screen
- Full transaction list (ListView.builder)
- Form validation (title, amount, category, type, date)
- Delete confirmation dialog
- Data persists after closing and reopening the app

## Tech Stack

- Flutter (Material 3)
- sqflite - local SQLite database
- path - database file path
- intl - date and currency formatting

## Project Structure

```
lib/
  main.dart, app.dart
  constants/     colors, strings, categories
  models/        transaction_model.dart
  database/      database_helper.dart
  repositories/  transaction_repository.dart
  screens/       dashboard/ and transactions/
  widgets/       reusable widgets
  utils/         date and currency formatters
```

Data flow: Screen -> Repository -> DatabaseHelper -> SQLite

## Database

- Database: `expense_tracker.db`
- Table: `transactions` (id, title, amount, category, type, date)
- `type` is stored as `income` or `expense`
- `date` is stored as ISO-8601 text

## How to Run

```bash
flutter pub get
flutter run
```

## How to Test

```bash
flutter analyze
flutter test
```