import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';

class ExpenseEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory expenseCategory;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.expenseCategory,
  });
}
