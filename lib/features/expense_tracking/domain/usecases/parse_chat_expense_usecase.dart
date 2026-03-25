import 'package:dartz/dartz.dart';
import 'package:spend_wise/core/error/failure.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_category.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
import 'package:uuid/uuid.dart';

class ParseChatExpenseUseCase {
  Either<Failure, ExpenseEntity> call(String message, ExpenseCategory category) {
    try {
      final trimmedMessage = message.trim();

      if (trimmedMessage.isEmpty) {
        return Left(InputFailure("Please type an expense."));
      }

      // ^([\d.]+) means "Must start with a number/decimal"
      // \s+for\s+ means "Must have the exact word 'for' surrounded by spaces"
      // (.+)$ means "Must end with some text for the title"

      final regex = RegExp(r'^([\d.]+)(?:\s+for\s+(.*))?$', caseSensitive: false);
      final match = regex.firstMatch(trimmedMessage);

      // If they didn't follow the exact rule, teach them!
      if (match == null) {
        return Left(InputFailure("Try this format: '200 for dinner'"));
      }

      // If we passed the rule, extract the exact pieces safely
      final amountString = match.group(1) ?? '';
      final titleString = match.group(2) ?? 'Quick Expense';

      final amount = double.tryParse(amountString);

      // Double check the number is valid
      if (amount == null) {
        return Left(InputFailure("I couldn't read any amount"));
      }

      String title = titleString.trim();

      final entity = ExpenseEntity(
        id: Uuid().v4(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        expenseCategory: category,
      );

      return Right(entity);
    } catch (e) {
      return Left(InputFailure("Failed to understand the message."));
    }
  }
}
