import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final NumberFormat currencyFormat;
  final String userCurrency;
  final bool isAnomaly, isLast;
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.currencyFormat,
    required this.userCurrency,
    required this.isAnomaly,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        ListTile(
          leading: Text(expense.expenseCategory.displayIcon, style: text.titleMedium),
          title: Text(
            expense.title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.normal),
          ),
          subtitle: Text(
            "-$userCurrency${currencyFormat.format(expense.amount)}",
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          trailing: isAnomaly
              ? Icon(Icons.trending_up_rounded, size: 18, color: Colors.red.shade900)
              : const SizedBox.shrink(),
        ),
        isLast
            ? SizedBox.shrink()
            : Divider(
                indent: 55,
                height: 0,
                thickness: 0.5,
                color: color.outlineVariant.withValues(alpha: 0.2),
              ),
      ],
    );
  }
}
