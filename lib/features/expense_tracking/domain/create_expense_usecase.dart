import 'package:dartz/dartz.dart';
import 'package:spend_wise/core/error/failure.dart';
import 'package:spend_wise/features/expense_tracking/domain/entities/expense_entity.dart';
import 'package:spend_wise/features/expense_tracking/domain/repo/expense_repo.dart';

class CreateExpenseUseCase {
  final ExpenseRepo repo;

  CreateExpenseUseCase(this.repo);

  Future<Either<Failure, void>> call(ExpenseEntity expense) async {
    return await repo.saveExpense(expense);
  }
}
